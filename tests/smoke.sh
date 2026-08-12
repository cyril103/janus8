#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
binary=${JANUS8_BIN:-$root/target/debug/janus8}
state=$root/target/smoke-state.txt
expected=$root/tests/fixtures/smoke-state.expected

"$root/tests/fixtures/make_sprite_loop.sh" "$root/tests/fixtures/sprite-loop.ch8"
"$binary" "$root/tests/fixtures/sprite-loop.ch8" \
  --cycles 10 --trace --dump-state "$state" --seed 42
diff -u "$expected" "$state"
echo "smoke oracle: ok"
