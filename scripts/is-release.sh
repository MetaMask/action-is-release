#!/usr/bin/env bash

set -x
set -e
set -o pipefail

BEFORE="${1}"
COMMIT_STARTS_WITH="${2}"
COMMIT_BODY_STARTS_WITH="${3}"
PACKAGE_DIR="${4}"

if [[ -z $BEFORE ]]; then
  echo "Error: Before SHA not specified."
  exit 1
fi

if [[ -z $PACKAGE_DIR ]]; then
  echo "Error: Package directory not specified."
  exit 1
fi

VERSION_BEFORE="$(git show "$BEFORE":"$PACKAGE_DIR"/package.json | jq --raw-output .version)"
VERSION_AFTER="$(jq --raw-output .version "$PACKAGE_DIR"/package.json)"

if [[ "$VERSION_BEFORE" == "$VERSION_AFTER" ]]; then
  echo "Notice: version unchanged. Skipping release."
  echo "IS_RELEASE=false" >> $GITHUB_OUTPUT
  exit 0
elif [[ -n $COMMIT_STARTS_WITH ]]; then
  EXPECTED_COMMIT_PREFIX="${COMMIT_STARTS_WITH//\[version\]/$VERSION_AFTER}"
  COMMIT_MESSAGE="$(git log --max-count=1 --format=%s)"

  if [[ ! $COMMIT_MESSAGE =~ ^$EXPECTED_COMMIT_PREFIX ]]; then
    echo "Notice: commit message does not start with \"${COMMIT_STARTS_WITH}\". Skipping release."
    echo "IS_RELEASE=false" >> $GITHUB_OUTPUT
    exit 0
  fi
elif [[ -n $COMMIT_BODY_STARTS_WITH ]]; then
  EXPECTED_COMMIT_BODY_PREFIX="${COMMIT_BODY_STARTS_WITH//\[version\]/$VERSION_AFTER}"
  COMMIT_MESSAGE="$(git log --max-count=1 --format=%b)"

  if [[ ! $COMMIT_MESSAGE =~ ^$EXPECTED_COMMIT_BODY_PREFIX ]]; then
    echo "Notice: commit message body does not start with \"${EXPECTED_COMMIT_BODY_PREFIX}\". Skipping release."
    echo "IS_RELEASE=false" >> $GITHUB_OUTPUT
    exit 0
  fi
fi

echo "IS_RELEASE=true" >> $GITHUB_OUTPUT
