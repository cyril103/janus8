#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
core=$root/src/chip8/core.janus
core_tests=$root/tests/core.janus
opcode_tests=$root/tests/opcodes.janus

if grep -Eq 'byteAnd|byteOr|byteXor|spriteBit' "$core"; then
  echo "legacy arithmetic bit helpers are still present" >&2
  exit 1
fi

for spelling in \
  'opcode >> usize(12)' \
  '(opcode >> usize(8)) & uint(0xF)' \
  '(opcode >> usize(4)) & uint(0xF)' \
  'opcode & uint(0xFF)' \
  'opcode & uint(0xFFF)' \
  'opcode & uint(0xF)' \
  'vx | vy' \
  'vx & vy' \
  'vx ^ vy'; do
  grep -Fq "$spelling" "$core" || {
    echo "missing native spelling: $spelling" >&2
    exit 1
  }
done

grep -Fq 'uint(0x60FE)' "$core_tests"
grep -Fq 'uint(0xA20A)' "$opcode_tests"
grep -Fq 'byte(0b1111_0000)' "$core"

echo "native Janus syntax: ok"
