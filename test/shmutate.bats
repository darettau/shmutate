setup() {
  cd "$BATS_TEST_DIRNAME/.."
  SHM="$PWD/shmutate"
}

@test "detects a surviving mutant in a weakly tested script" {
  run "$SHM" --run "bats examples/test" examples/greet.sh
  [ "$status" -ne 0 ]
  [[ "$output" == *"SURVIVED  examples/greet.sh:9"* ]]
  [[ "$output" == *"1 survived"* ]]
}

@test "aborts when the baseline suite is already failing" {
  run "$SHM" --run "false" examples/greet.sh
  [ "$status" -eq 1 ]
  [[ "$output" == *"baseline suite is failing"* ]]
}

@test "reports nothing to do when there are no mutable operators" {
  local tmp="$BATS_TEST_TMPDIR/plain.sh"
  printf '#!/usr/bin/env bash\necho hello\n' > "$tmp"
  run "$SHM" --run "true" "$tmp"
  [ "$status" -eq 0 ]
  [[ "$output" == *"no mutable operators"* ]]
}

@test "restores the target file after a run" {
  local before after
  before=$(sha1sum examples/greet.sh)
  run "$SHM" --run "bats examples/test" examples/greet.sh
  after=$(sha1sum examples/greet.sh)
  [ "$before" = "$after" ]
}

@test "operators inside strings and comments are not mutated" {
  local dir="$BATS_TEST_TMPDIR/q"
  mkdir -p "$dir/test"
  cat > "$dir/lib.sh" <<'SH'
check() {
  local x=$1
  local msg="pass -eq to compare"   # -ne is only mentioned here
  if [ "$x" -eq 1 ]; then echo one; else echo other; fi
}
SH
  cat > "$dir/test/lib.bats" <<'SH'
setup() { source "$BATS_TEST_DIRNAME/../lib.sh"; }
@test "one"   { run check 1; [ "$output" = one ]; }
@test "other" { run check 2; [ "$output" = other ]; }
SH
  cd "$dir"
  run "$SHM" --run "bats test" lib.sh
  [ "$status" -eq 0 ]
  [[ "$output" != *"SURVIVED"* ]]
}

@test "arithmetic <= is found and mutated" {
  local dir="$BATS_TEST_TMPDIR/a"
  mkdir -p "$dir/test"
  cat > "$dir/lib.sh" <<'SH'
inrange() {
  if (( $1 <= 10 )); then echo yes; else echo no; fi
}
SH
  cat > "$dir/test/lib.bats" <<'SH'
setup() { source "$BATS_TEST_DIRNAME/../lib.sh"; }
@test "low"  { run inrange 5;  [ "$output" = yes ]; }
@test "high" { run inrange 20; [ "$output" = no ]; }
SH
  cd "$dir"
  run "$SHM" --run "bats test" lib.sh
  [[ "$output" == *"1 mutants across"* ]]
  [ "$status" -eq 0 ]
}
