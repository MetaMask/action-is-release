#!/usr/bin/env bash

set -x
set -e
set -o pipefail

BEFORE="${1}"
COMMIT_STARTS_WITH="${2}"

if [[ -z $BEFORE ]]; then
  echo "Error: Before SHA not specified."
  exit 1
fi

VERSION_BEFORE="$(git show "$BEFORE":package.json | jq --raw-output .version)"
VERSION_AFTER="$(jq --raw-output .version package.json)"

if [[ "$VERSION_AFTER" == "$VERSION_BEFORE" ]]; then
  echo "Version unchanged, so this is not a release commit."
  echo "IS_RELEASE=false" >> $GITHUB_OUTPUT
  echo "COMMIT_TYPE=normal" >> $GITHUB_OUTPUT
  exit 0
else
  # Get the comparison result
  COMPARISON_WITH_BEFORE="$(./scripts/compare-semver-versions.sh "$VERSION_AFTER" "$VERSION_BEFORE")"
  
  if [[ "$COMPARISON_WITH_BEFORE" == "lt" ]]; then
    echo "Version downgraded, so this is a release rollback."
    echo "IS_RELEASE=false" >> $GITHUB_OUTPUT
    echo "COMMIT_TYPE=release-rollback" >> $GITHUB_OUTPUT
    exit 0
  fi
fi

if [[ -n $COMMIT_STARTS_WITH ]]; then
  COMMIT_MESSAGE="$(git log --max-count=1 --format=%s)"
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
      echo "Commit message does not start with \"${COMMIT_STARTS_WITH}\", so this is not a release commit."
      echo "IS_RELEASE=false" >> $GITHUB_OUTPUT
      echo "COMMIT_TYPE=normal" >> $GITHUB_OUTPUT
      exit 0
  fi
fi

echo "This is a release commit!"
echo "IS_RELEASE=true" >> $GITHUB_OUTPUT
echo "COMMIT_TYPE=release" >> $GITHUB_OUTPUT
