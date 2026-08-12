#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/janus8 native mutation.XXXXXX")
trap 'rm -rf "$work"' 0 INT TERM

mkdir -p "$work/src/chip8" "$work/tests"
cp "$root/src/chip8/core.janus" "$work/src/chip8/core.janus"
cp "$root/tests/core.janus" "$work/tests/core.janus"
cp "$root/tests/opcodes.janus" "$work/tests/opcodes.janus"
cp "$root/tests/check_native_syntax.py" "$work/tests/check_native_syntax.py"
cp "$root/tests/native_syntax.sh" "$work/tests/native_syntax.sh"

python3 - "$work/src/chip8/core.janus" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
source = path.read_text()
native = "else if sub == uint(1) { registers.set(x, vx | vy) }"
legacy = (
    "else if sub == uint(1) { "
    "registers.set(x, truncatingCast[byte](unsignedByte(vx) + "
    "unsignedByte(vy) - unsignedByte(vx & vy))) }"
)
if source.count(native) != 1:
    raise SystemExit("native OR implementation not found exactly once")
path.write_text(source.replace(native, legacy) + "\n// structural-gate decoy: vx | vy\n")
PY

diagnostic=$work/diagnostic.txt
expected=$work/expected.txt
printf '%s\n' 'missing native syntax: 8XY1 native OR branch' >"$expected"
if "$work/tests/native_syntax.sh" >"$diagnostic" 2>&1; then
  echo "native syntax gate accepted a comment decoy" >&2
  exit 1
fi
if ! cmp -s "$expected" "$diagnostic"; then
  echo "native syntax gate failed for the wrong reason:" >&2
  cat "$diagnostic" >&2
  exit 1
fi

cp "$root/src/chip8/core.janus" "$work/src/chip8/core.janus"
python3 - "$work/src/chip8/core.janus" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
source = path.read_text()
native = "else if sub == uint(1) { registers.set(x, vx | vy) }"
legacy = (
    "else if sub == uint(1) { "
    "registers.set(x, truncatingCast[byte](unsignedByte(vx) + "
    "unsignedByte(vy) - unsignedByte(vx & vy))) }"
)
dead = "\n            else if sub == uint(1) { registers.set(x, vx | vy) }"
anchor = (
    "\n            else if sub == uint(14) { registers.set(usize(15), "
    "truncatingCast[byte]((unsignedByte(vx) >> usize(7)) & uint(0x1))) "
    "registers.set(x, truncatingCast[byte](unsignedByte(vx) << usize(1))) }"
    "\n            else { return Result.Error[bool, Chip8Error](Chip8Error.UnsupportedOpcode) }"
)
replacement = anchor.replace("\n            else {", dead + "\n            else {")
if source.count(native) != 1:
    raise SystemExit("native OR implementation not found exactly once")
if source.count(anchor) != 1:
    raise SystemExit("8XY fallback not found exactly once")
path.write_text(source.replace(native, legacy).replace(anchor, replacement))
PY

printf '%s\n' 'duplicate opcode sub-branch: uint(1)' >"$expected"
if "$work/tests/native_syntax.sh" >"$diagnostic" 2>&1; then
  echo "native syntax gate accepted an unreachable duplicate branch" >&2
  exit 1
fi
if ! cmp -s "$expected" "$diagnostic"; then
  echo "native syntax gate rejected dead code for the wrong reason:" >&2
  cat "$diagnostic" >&2
  exit 1
fi

cp "$root/src/chip8/core.janus" "$work/src/chip8/core.janus"
python3 - "$work/src/chip8/core.janus" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
source = path.read_text()
anchor = "\n            else { return Result.Error[bool, Chip8Error](Chip8Error.UnsupportedOpcode) }"
dead = "\n            else if sub == uint(0x1) { registers.set(x, vx | vy) }"
position = source.find(anchor, source.find("if family == uint(0x8)"))
if position < 0:
    raise SystemExit("8XY fallback not found")
path.write_text(source[:position] + dead + source[position:])
PY

if "$work/tests/native_syntax.sh" >"$diagnostic" 2>&1; then
  echo "native syntax gate accepted a hexadecimal duplicate branch" >&2
  exit 1
fi
printf '%s\n' 'duplicate opcode sub-branch: uint(1)' >"$expected"
if ! cmp -s "$expected" "$diagnostic"; then
  echo "native syntax gate rejected hexadecimal dead code for the wrong reason:" >&2
  cat "$diagnostic" >&2
  exit 1
fi

cp "$root/src/chip8/core.janus" "$work/src/chip8/core.janus"
python3 - "$work/src/chip8/core.janus" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
source = path.read_text()
anchor = "\n        if family == uint(0x9)"
outside = "\n        if sub == uint(1) { registers.set(x, vx | vy) }"
if source.count(anchor) != 1:
    raise SystemExit("post-8XY family branch not found exactly once")
path.write_text(source.replace(anchor, outside + anchor))
PY

if ! "$work/tests/native_syntax.sh" >"$diagnostic" 2>&1; then
  echo "native syntax gate included code outside the 8XY block:" >&2
  cat "$diagnostic" >&2
  exit 1
fi
printf '%s\n' 'native Janus syntax: ok' >"$expected"
if ! cmp -s "$expected" "$diagnostic"; then
  echo "native syntax gate emitted an unexpected success diagnostic:" >&2
  cat "$diagnostic" >&2
  exit 1
fi

echo "native syntax mutations: rejected"
