#!/usr/bin/env bash

set -x
set -e
set -o pipefail

if [[ -z $BEFORE ]]; then
  echo "Error: Before SHA not specified."
  exit 1
fi

git fetch origin "$BEFORE"

VERSION_BEFORE="$(git show "$BEFORE":package.json | jq --raw-output .version)"
VERSION_AFTER="$(jq --raw-output .version package.json)"

if [[ "$VERSION_BEFORE" == "$VERSION_AFTER" ]]; then
  echo "Notice: version unchanged. Skipping release."
  echo "IS_RELEASE=false" >> "$GITHUB_OUTPUT"
  exit 0
elif [[ -n $COMMIT_STARTS_WITH ]]; then
  if [[ -z $COMMIT_MESSAGE ]]; then
    COMMIT_MESSAGE="$(git log --max-count=1 --format=%s)"
  fi

  match_found=false

  IFS=',' read -ra RAW_PREFIXES <<< "${COMMIT_STARTS_WITH}"
  for RAW_PREFIX in "${RAW_PREFIXES[@]}"; do
    EXPECTED_COMMIT_PREFIX="${RAW_PREFIX//\[version\]/$VERSION_AFTER}"
    if [[ $COMMIT_MESSAGE =~ ^$EXPECTED_COMMIT_PREFIX ]]; then
      match_found=true
      break;
    fi
  done

  if [[ $match_found == false ]]; then
      echo "Notice: commit message does not start with \"${COMMIT_STARTS_WITH}\". Skipping release."
      echo "IS_RELEASE=false" >> "$GITHUB_OUTPUT"
      exit 0
  fi
fi

echo "IS_RELEASE=true" >> "$GITHUB_OUTPUT"
