setup() {
  cd "$BATS_TEST_DIRNAME/.."
}

@test "detects a surviving mutant in a weakly tested script" {
  run ./shmutate --run "bats examples/test" examples/greet.sh
  [ "$status" -ne 0 ]
  [[ "$output" == *"SURVIVED  examples/greet.sh:9"* ]]
  [[ "$output" == *"1 survived"* ]]
}

@test "aborts when the baseline suite is already failing" {
  run ./shmutate --run "false" examples/greet.sh
  [ "$status" -eq 1 ]
  [[ "$output" == *"baseline suite is failing"* ]]
}

@test "reports nothing to do when there are no mutable operators" {
  local tmp="$BATS_TEST_TMPDIR/plain.sh"
  printf '#!/usr/bin/env bash\necho hello\n' > "$tmp"
  run ./shmutate --run "true" "$tmp"
  [ "$status" -eq 0 ]
  [[ "$output" == *"no mutable operators"* ]]
}

@test "restores the target file after a run" {
  local before after
  before=$(sha1sum examples/greet.sh)
  run ./shmutate --run "bats examples/test" examples/greet.sh
  after=$(sha1sum examples/greet.sh)
  [ "$before" = "$after" ]
}
