#!/usr/bin/env bats

load 'test_helper.bash'

setup() {
  TMPBIN="$(mktemp -d)"
  mkdir -p "$TMPBIN/bin"
}

teardown() {
  rm -rf "$TMPBIN"
}

# Helper to create fake commands
create_fake() {
  local name="$1"
  shift
  cat > "$TMPBIN/bin/$name" <<'EOF'
#!/usr/bin/env bash
case "$0" in
  *git) echo "git version 2.40.0" ; exit 0 ;;
  *node) echo "v20.0.0" ; exit 0 ;;
  *npm) echo "10.0.0" ; exit 0 ;;
  *) exit 0 ;;
esac
EOF
  chmod +x "$TMPBIN/bin/$name"
}

@test "validate-agents returns OK when required commands exist (minimal)" {
  create_fake git
  create_fake node
  create_fake npm
  PATH="$TMPBIN/bin:$PATH" run bash -c 'bash "$BATS_TEST_DIRNAME/../../scripts/validate-agents.sh" --minimal --json'
  [ "$status" -eq 0 ]
  # Expect JSON contains failures: 0 and total 3
  echo "$output" | grep -q '"failures":0'
  echo "$output" | grep -q '"total":3'
}

@test "validate-agents reports missing component" {
  create_fake git
  create_fake npm
  PATH="$TMPBIN/bin:$PATH" run bash -c 'bash "$BATS_TEST_DIRNAME/../../scripts/validate-agents.sh" --minimal --json'
  [ "$status" -ne 0 ]
  echo "$output" | grep -q '"failures":1'
  echo "$output" | grep -q '"name":"node"'
}