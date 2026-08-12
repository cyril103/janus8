#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
exec python3 "$root/tests/check_native_syntax.py" \
  "$root/src/chip8/core.janus" \
  "$root/tests/core.janus" \
  "$root/tests/opcodes.janus"
