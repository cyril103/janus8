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

echo "native syntax mutation: rejected"
