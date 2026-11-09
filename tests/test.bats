#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  # Override this variable for your add-on:
  export GITHUB_REPO=e0ipso/ddev-atlassian-cli

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p "${HOME}/tmp"
  export TESTDIR="$(mktemp -d "${HOME}/tmp/${PROJNAME}.XXXXXX")"
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  export CI=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
  run ddev start -y
  assert_success
}

health_checks() {
  # twg is installed and reachable through `ddev twg`.
  run ddev twg -v
  assert_success
  assert_output --regexp '^[0-9]+\.[0-9]+\.[0-9]+'

  # It is on the default PATH too, for `ddev ssh` and `ddev exec`.
  run ddev exec 'command -v twg'
  assert_success
  assert_output "/usr/local/bin/twg"
}

# Checks for the persistent login. The release test skips them until a release
# ships it.
login_checks() {
  # The twg config directory is in the project, so the login survives a restart.
  run ddev exec 'echo "$TWG_CONFIG_DIR"'
  assert_success
  assert_output "/var/www/html/.ddev/twg"
  run ddev exec 'twg env --list | grep -A3 "^  TWG_CONFIG_DIR"'
  assert_success
  assert_output --partial 'current: "/var/www/html/.ddev/twg"'

  # A file twg would write there outlives the container. Writing auth.conf
  # directly avoids a real login or recording consent to Atlassian's terms.
  run ddev exec 'echo probe > "$TWG_CONFIG_DIR/auth.conf"'
  assert_success
  run ddev restart -y
  assert_success
  run ddev exec 'cat "$TWG_CONFIG_DIR/auth.conf"'
  assert_success
  assert_output "probe"

  # git ignores what twg writes there, but not the ignore file itself.
  run git -C "${TESTDIR}" init -q
  assert_success
  run git -C "${TESTDIR}" check-ignore -q .ddev/twg/auth.conf
  assert_success
  run git -C "${TESTDIR}" check-ignore -q .ddev/twg/.gitignore
  assert_failure
}

removal_checks() {
  run ddev add-on remove atlassian-cli
  assert_success
  assert_dir_not_exists "${TESTDIR}/.ddev/twg"
  assert_file_not_exists "${TESTDIR}/.ddev/docker-compose.atlassian-cli.yaml"
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1
  # Persist TESTDIR if running inside GitHub Actions. Useful for uploading test result artifacts
  # See example at https://github.com/ddev/github-action-add-on-test#preserving-artifacts
  if [ -n "${GITHUB_ENV:-}" ]; then
    [ -e "${GITHUB_ENV:-}" ] && echo "TESTDIR=${HOME}/tmp/${PROJNAME}" >> "${GITHUB_ENV}"
  else
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
  fi
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
  login_checks
  removal_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}
