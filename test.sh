#!/usr/bin/env bash
# Test script for CSE 131 WI17 P1.
# Requires reference executable p1exe.

# Color utility
color() {
  c="$1"
  shift
  echo -e "\e[${c}m${@}\e[0m"
}

# Pad output
pad() {
  sed 's/^/      /'
}

# Check if we have the reference program
if [ ! -x ./p1exe ]; then
  echo
  color 31 "Reference executable \e[4mp1exe\e[24m required for tests to run."
  color 34 "See \e[4mhttps://piazza.com/class/iv2mq9imkj260t?cid=91\e[24m for details."
  echo
  exit 1
fi

echo
color 34 "Building ./glc..."
make_out="$(make 2>&1)"
make_status="$?"
pad <<< "$make_out"
if [ "$make_status" != 0 ]; then
  color 31 "Build failed."
  echo
  exit 1
fi
echo

# Counters
pass=0
total=0

for f in samples/*.glsl; do
  ((total++))
  trim="${f%%.*}"  # Path without extension
  name="${trim##*/}"  # Name of test
  out="${trim}.out"  # Expected outupt
  cmd="./glc < \"$f\""  # Command to run
  ref="./p1exe < \"$f\"" # Reference output

  delta="$(diff -wu --label "\$ $cmd" <(eval "$cmd" 2>&1) \
                    --label "\$ $ref" <(eval "$ref" 2>&1) 2>&1)"

  if [ "$delta" ]; then
    color 31 "FAIL: $name"
    pad <<< "$delta"
  else
    color 32 "PASS: $name"
    ((pass++))
  fi
done

echo
color 34 "SCORE: $pass/$total"
echo

[ "$pass" == "$total" ] && exit 0 || exit 1
