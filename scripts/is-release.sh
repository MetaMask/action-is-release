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

# SemVer comparison function
# Returns: 0 if version1 < version2, 1 otherwise
semver-version-lt() {
  local version1="$1"
  local version2="$2"

  # Split versions into major.minor.patch
  IFS='.' read -a v1_parts <<< "$version1"
  IFS='.' read -a v2_parts <<< "$version2"

  # Ensure we have at least 3 parts (major.minor.patch)
  local v1_major="${v1_parts[0]:-0}"
  local v1_minor="${v1_parts[1]:-0}"
  local v1_patch="${v1_parts[2]:-0}"

  local v2_major="${v2_parts[0]:-0}"
  local v2_minor="${v2_parts[1]:-0}"
  local v2_patch="${v2_parts[2]:-0}"

  # Compare major version
  if [[ "$v1_major" -lt "$v2_major" ]]; then
    return 0  # version1 < version2
  elif [[ "$v1_major" -gt "$v2_major" ]]; then
    return 1  # version1 > version2
  fi

  # Major versions are equal, compare minor
  if [[ "$v1_minor" -lt "$v2_minor" ]]; then
    return 0  # version1 < version2
  elif [[ "$v1_minor" -gt "$v2_minor" ]]; then
    return 1  # version1 > version2
  fi

  # Minor versions are equal, compare patch
  if [[ "$v1_patch" -lt "$v2_patch" ]]; then
    return 0  # version1 < version2
  elif [[ "$v1_patch" -gt "$v2_patch" ]]; then
    return 1  # version1 > version2
  fi

  # All parts are equal (version1 == version2)
  return 1
}

VERSION_BEFORE="$(git show "$BEFORE":package.json | jq --raw-output .version)"
VERSION_AFTER="$(jq --raw-output .version package.json)"

if "$VERSION_BEFORE" == "$VERSION_AFTER"; then
  echo "Version unchanged, so this is not a release commit."
  echo "IS_RELEASE=false" >> $GITHUB_OUTPUT
  exit 0
elif semver-version-lt "$VERSION_BEFORE" "$VERSION_AFTER"; then
  echo "Version downgraded, so this is a release rollback."
  echo "IS_RELEASE=false" >> $GITHUB_OUTPUT
  echo "COMMIT_TYPE=release-rollback" >> $GITHUB_OUTPUT
elif [[ -n $COMMIT_STARTS_WITH ]]; then
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
      exit 0
  fi
fi

echo "This is a release commit!"
echo "IS_RELEASE=true" >> $GITHUB_OUTPUT
echo "COMMIT_TYPE=release" >> $GITHUB_OUTPUT
