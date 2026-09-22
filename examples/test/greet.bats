setup() {
  source "$BATS_TEST_DIRNAME/../greet.sh"
}

@test "zero" {
  run classify 0
  [ "$status" -eq 0 ]
  [ "$output" = zero ]
}

@test "positive" {
  run classify 7
  [ "$output" = positive ]
}
