#!/bin/sh
set -eu
output=${1:-tests/fixtures/sprite-loop.ch8}
printf '\242\012\140\077\141\037\320\025\022\010\300' > "$output"
