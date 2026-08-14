#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/janus8 native mutation.XXXXXX")
trap 'rm -rf "$work"' 0 INT TERM

mkdir -p "$work/src/chip8" "$work/tests"
cp "$root/tests/core.janus" "$work/tests/core.janus"
cp "$root/tests/opcodes.janus" "$work/tests/opcodes.janus"
cp "$root/tests/check_native_syntax.py" "$work/tests/check_native_syntax.py"
cp "$root/tests/native_syntax.sh" "$work/tests/native_syntax.sh"

diagnostic=$work/diagnostic.txt
expected=$work/expected.txt

reset_core() {
  cp "$root/src/chip8/core.janus" "$work/src/chip8/core.janus"
}

expect_rejection() {
  expected_message=$1
  scenario=$2
  printf '%s\n' "$expected_message" >"$expected"
  if "$work/tests/native_syntax.sh" >"$diagnostic" 2>&1; then
    echo "native syntax gate accepted $scenario" >&2
    exit 1
  fi
  if ! cmp -s "$expected" "$diagnostic"; then
    echo "native syntax gate rejected $scenario for the wrong reason:" >&2
    cat "$diagnostic" >&2
    exit 1
  fi
}

reset_core
python3 - "$work/src/chip8/core.janus" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
source = path.read_text()
native = "uint(1) => this.set8xy(x, vx | vy),"
legacy = (
    "uint(1) => this.set8xy(x, truncatingCast[byte](unsignedByte(vx) + "
    "unsignedByte(vy) - unsignedByte(vx & vy))),"
)
if source.count(native) != 1:
    raise SystemExit("native OR pattern not found exactly once")
path.write_text(source.replace(native, legacy) + "\n// structural-gate decoy: uint(1) => this.set8xy(x, vx | vy),\n")
PY
expect_rejection 'missing native syntax: 8XY1 native OR pattern' 'a comment decoy for the 8XY1 pattern'

reset_core
python3 - "$work/src/chip8/core.janus" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
source = path.read_text()
native = "uint(4) => this.add8xy(x, vx, vy),"
corrupted = "uint(4) => this.subtract8xy(x, vx, vy),"
if source.count(native) != 1:
    raise SystemExit("8XY4 addition pattern not found exactly once")
path.write_text(source.replace(native, corrupted) + "\n// decoy: uint(4) => this.add8xy(x, vx, vy),\n")
PY
expect_rejection 'missing native syntax: 8XY4 addition pattern' 'a corrupted 8XY4 mapping with a comment decoy'

reset_core
python3 - "$work/src/chip8/core.janus" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
source = path.read_text()
anchor = "                _ => false"
duplicate = "                uint(0x1) => this.set8xy(x, vx | vy),\n"
if source.count(anchor) != 1:
    raise SystemExit("8XY wildcard not found exactly once")
path.write_text(source.replace(anchor, duplicate + anchor))
PY
expect_rejection 'duplicate opcode sub-pattern: uint(1)' 'a hexadecimal duplicate 8XY pattern'

reset_core
python3 - "$work/src/chip8/core.janus" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
source = path.read_text()
old = "val font : Array[byte] = ["
new = "val fontBytes : Array[byte] = ["
if source.count(old) != 1:
    raise SystemExit("typed font array literal not found exactly once")
source = source.replace(old, new).replace("delete font", "delete fontBytes")
source = source.replace("font.size()", "fontBytes.size()").replace("font.get(offset)", "fontBytes.get(offset)")
path.write_text(source + "\n// structural-gate decoy: val font : Array[byte] = [ byte(0b1111_0000) ]\n")
PY
expect_rejection 'missing native syntax: CHIP-8 font typed array literal' 'a comment decoy for the font array literal'

reset_core
python3 - "$work/src/chip8/core.janus" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
source = path.read_text()
literal = re.search(r"(val font\s*:\s*Array\[byte\]\s*=\s*\[)(.*?)(\]\s*defer delete font)", source, re.S)
if literal is None:
    raise SystemExit("font literal not found")
tokens = list(re.finditer(r"byte\(0b[01_]+\)", literal.group(2)))
if len(tokens) != 80:
    raise SystemExit(f"unexpected baseline font length: {len(tokens)}")
token = tokens[37]
mutated = literal.group(2)[:token.start()] + "byte(0b0010_0001)" + literal.group(2)[token.end():]
path.write_text(source[:literal.start()] + literal.group(1) + mutated + literal.group(3) + source[literal.end():])
PY
expect_rejection 'unexpected CHIP-8 font byte at index 37: 0x21 (expected 0x20)' 'a modified interior font byte'

reset_core
python3 - "$work/src/chip8/core.janus" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
source = path.read_text()
needle = "byte(0b1111_0000), byte(0b1001_0000),"
if source.count(needle) < 1:
    raise SystemExit("font prefix not found")
path.write_text(source.replace(needle, "byte(0b1001_0000),", 1))
PY
expect_rejection 'unexpected CHIP-8 font length: 79 (expected 80)' 'a missing font byte'

reset_core
python3 - "$work/src/chip8/core.janus" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
source = path.read_text()
needle = "    defer delete font\n"
if source.count(needle) != 1:
    raise SystemExit("font cleanup not found exactly once")
path.write_text(source.replace(needle, ""))
PY
expect_rejection 'missing native syntax: font cleanup' 'a removed font cleanup'

reset_core
python3 - "$work/src/chip8/core.janus" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
source = path.read_text()
needle = "result.set(usize(0x50) + offset, font.get(offset))"
if source.count(needle) != 1:
    raise SystemExit("font copy base not found exactly once")
path.write_text(source.replace(needle, "result.set(usize(0x51) + offset, font.get(offset))"))
PY
expect_rejection 'missing native syntax: font copy range' 'an incorrect font copy base'

reset_core
python3 - "$work/src/chip8/core.janus" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
source = path.read_text()
anchor = "\n        if family == uint(0x8) {"
interceptor = (
    "\n        if family == uint(0x8) { "
    "return Result.Error[bool, Chip8Error](Chip8Error.UnsupportedOpcode) }"
)
if source.count(anchor) != 1:
    raise SystemExit("canonical 8XY family branch not found exactly once")
path.write_text(source.replace(anchor, interceptor + anchor))
PY
expect_rejection 'duplicate opcode family branch: uint(8)' 'an intercepting 8XY family branch'

echo "native syntax mutations: rejected"
