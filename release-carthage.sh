#!/bin/bash

function output () {
	echo "$@"
}

function output_error () {
	>&2 echo "$@"
}

function fail () {
    >&2 echo "$@"
    exit 1
}

function usage {
    fail "Usage: $BASH_SOURCE <version>"
}

function real_base_name () {
  target=$1

  (
  while true; do
    cd "$(dirname "$target")"
    target=$(basename "$target")
    link=$(readlink "$target")
    test "$link" || break
    target=$link
  done

  echo "$(pwd -P)"
  )
}

if [ "$#" -ne 1 ]; then
	usage
fi

RAW_VERSION="$1"
SCRIPT_DIR=$(real_base_name "$0")
VERSION="${RAW_VERSION}+nsoperations"
TEMP_DIR=$(mktemp -d)

FORMULA_FILE="$SCRIPT_DIR/Formula/carthage.rb"

trap "rm -rf ${TEMP_DIR}" INT TERM EXIT

output "Using temporary directory $TEMP_DIR"

pushd "$TEMP_DIR" > /dev/null || fail "Could not change directories to $TEMP_DIR"

git clone https://github.com/nsoperations/carthage carthage || fail "Could not clone nsoperations/carthage from github"

pushd carthage > /dev/null

git checkout master || fail "Could not checkout master branch"

git tag -a -m "Tagged version $VERSION" "$VERSION" || fail "Could not tag version $VERSION"
git push --tags

COMMIT_HASH=$(git rev-parse HEAD)

output "Tagged version $VERSION with commit hash $COMMIT_HASH"

pushd > /dev/null
pushd > /dev/null

sed -i.bak -E "s/^(.*:tag[[:space:]]*=>[[:space:]]*\")(.*)(\".*)$/\1${VERSION}\3/g" "$FORMULA_FILE"
sed -i.bak -E "s/^(.*:version[[:space:]]*=>[[:space:]]*\")(.*)(\".*)$/\1${RAW_VERSION}\3/g" "$FORMULA_FILE"
sed -i.bak -E "s/^(.*:revision[[:space:]]*=>[[:space:]]*\")(.*)(\".*)$/\1${COMMIT_HASH}\3/g" "$FORMULA_FILE"

cd "$SCRIPT_DIR"

brew install --root-url "https://dl.bintray.com/nsoperations/bottles-formulas" --build-from-source --build-bottle "$FORMULA_FILE" || fail "Build bottle failed"
brew bottle "$FORMULA_FILE" || fail "Export of bottle failed"
