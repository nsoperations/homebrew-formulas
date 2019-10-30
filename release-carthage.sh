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

if [ -z "$BINTRAY_API_KEY" ]; then
	fail "Please set the BINTRAY_API_KEY environment variable"
fi

RAW_VERSION="$1"
SCRIPT_DIR=$(real_base_name "$0")
VERSION="${RAW_VERSION}+nsoperations"
TEMP_DIR=$(mktemp -d)

BOTTLE_OUTPUT="$TEMP_DIR/bottle.txt"
FORMULA_FILE="$SCRIPT_DIR/Formula/carthage.rb"

trap "rm -rf ${TEMP_DIR}" INT TERM EXIT

output "Using temporary directory $TEMP_DIR"

cd "$TEMP_DIR" || fail "Could not change directories to $TEMP_DIR"

git clone https://github.com/nsoperations/carthage carthage || fail "Could not clone nsoperations/carthage from github"

cd carthage > /dev/null

git checkout master || fail "Could not checkout master branch"

TAG_EXISTS=$(git tag -l | grep "$VERSION")

if [ -n "$TAG_EXISTS" ]; then

	git checkout "$VERSION"

else

	git tag -a -m "Tagged version $VERSION" "$VERSION" || fail "Could not tag version $VERSION"
	git push --tags || fail "Could not push tags"

fi

COMMIT_HASH=$(git rev-parse HEAD)

output "Tagged version $VERSION with commit hash $COMMIT_HASH"

cd "$SCRIPT_DIR"

git pull || fail "Could not pull from remote"

sed -i "" -E "s/^(.*:tag[[:space:]]*=>[[:space:]]*\")(.*)(\".*)$/\1${VERSION}\3/g" "$FORMULA_FILE"
sed -i "" -E "s/^(.*:version[[:space:]]*=>[[:space:]]*\")(.*)(\".*)$/\1${RAW_VERSION}\3/g" "$FORMULA_FILE"
sed -i "" -E "s/^(.*:revision[[:space:]]*=>[[:space:]]*\")(.*)(\".*)$/\1${COMMIT_HASH}\3/g" "$FORMULA_FILE"

brew uninstall carthage
brew install --build-bottle "$FORMULA_FILE" || fail "Build bottle failed"
brew bottle --force-core-tap "$FORMULA_FILE" > "$BOTTLE_OUTPUT" || fail "Export of bottle failed"

BINARY_HASH="$(cat "$BOTTLE_OUTPUT" | sed -n -E -e 's/sha256[[:space:]]*"(.*)".*/\1/p' | tr -d '[:space:]')"

if [ -z "$BINARY_HASH" ]; then
	fail "Could not extract binary hash"
fi

sed -i "" -E "s/^(.*sha256[[:space:]]*\")(.*)(\".*)$/\1${BINARY_HASH}\3/g" "$FORMULA_FILE"

output "Uploading to bintray..."

curl --show-error --fail -s --request PUT --user "werner77:${BINTRAY_API_KEY}" --header "X-Checksum-Sha2: ${BINARY_HASH}" --header "X-Bintray-Package: Carthage" --header "X-Bintray-Version: ${VERSION}" --header "X-Bintray-Publish: 1" --upload-file "./carthage--${RAW_VERSION}.mojave.bottle.tar.gz" "https://api.bintray.com/content/nsoperations/bottles-formulas/carthage-${RAW_VERSION}.mojave.bottle.tar.gz" || fail "Could not upload package to bintray"

output "Pushing updated formula"

git commit -a -m "Updated carthage formula" || fail "Could not commit formula"
git push || fail "Could not push formula to remote"

output "Testing whether install works"

brew uninstall carthage
brew install nsoperations/formulas/carthage || fail "Could not install carthage"

output "Done."


