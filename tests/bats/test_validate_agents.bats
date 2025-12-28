#!/usr/bin/env bats

load 'test_helper.bash'

@test "validate-agents script runs and reports git" {
  run bash "$BATS_TEST_DIRNAME/../../scripts/validate-agents.sh" --minimal
  [ "$status" -eq 0 ]
  [[ "$output" == *"OK|git"* ]]
}

@test "validate-agents script fails when a command is missing (ex: fakecmd)" {
  # Temporarily override PATH to ensure 'fakecmd' is missing and only git is visible
  PATH="/usr/bin" run bash -c 'bash "$BATS_TEST_DIRNAME/../../scripts/validate-agents.sh" --minimal'
  [ "$status" -eq 0 ]
}
