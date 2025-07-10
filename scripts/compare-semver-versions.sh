#!/usr/bin/env bash

set -euo pipefail

# Returns: "gt" if version1 > version2, "lt" if version1 < version2, "eq" if version1 == version2
compare-semver-versions() {
  local version1="$1"
  local version2="$2"

  # Split versions into major.minor.patch and prerelease
  IFS='.' read -a v1_parts <<< "$version1"
  IFS='.' read -a v2_parts <<< "$version2"

  # Extract prerelease parts if they exist
  local v1_prerelease=""
  local v2_prerelease=""

  # Check if version1 has prerelease (contains hyphen)
  if [[ "$version1" == *"-"* ]]; then
    v1_prerelease="${version1#*-}"
    # Remove prerelease from parts array
    v1_parts=("${v1_parts[@]%-*}")
  fi

  # Check if version2 has prerelease (contains hyphen)
  if [[ "$version2" == *"-"* ]]; then
    v2_prerelease="${version2#*-}"
    # Remove prerelease from parts array
    v2_parts=("${v2_parts[@]%-*}")
  fi

  # Ensure we have at least 3 parts (major.minor.patch)
  local v1_major="${v1_parts[0]:-0}"
  local v1_minor="${v1_parts[1]:-0}"
  local v1_patch="${v1_parts[2]:-0}"

  local v2_major="${v2_parts[0]:-0}"
  local v2_minor="${v2_parts[1]:-0}"
  local v2_patch="${v2_parts[2]:-0}"

  # Compare major version
  if [[ "$v1_major" -gt "$v2_major" ]]; then
    echo "gt"
    return
  elif [[ "$v1_major" -lt "$v2_major" ]]; then
    echo "lt"
    return
  fi

  # Major versions are equal, compare minor
  if [[ "$v1_minor" -gt "$v2_minor" ]]; then
    echo "gt"
    return
  elif [[ "$v1_minor" -lt "$v2_minor" ]]; then
    echo "lt"
    return
  fi

  # Minor versions are equal, compare patch
  if [[ "$v1_patch" -gt "$v2_patch" ]]; then
    echo "gt"
    return
  elif [[ "$v1_patch" -lt "$v2_patch" ]]; then
    echo "lt"
    return
  fi

  # All numeric parts are equal, compare prereleases
  # If one has prerelease and the other doesn't, the one without prerelease is greater
  if [[ -z "$v1_prerelease" && -n "$v2_prerelease" ]]; then
    echo "gt"  # no prerelease > prerelease
    return
  elif [[ -n "$v1_prerelease" && -z "$v2_prerelease" ]]; then
    echo "lt"  # prerelease < no prerelease
    return
  elif [[ -z "$v1_prerelease" && -z "$v2_prerelease" ]]; then
    echo "eq"  # both have no prerelease
    return
  else
    # Both have prereleases, compare alphabetically
    if [[ "$v1_prerelease" > "$v2_prerelease" ]]; then
      echo "gt"
      return
    elif [[ "$v1_prerelease" < "$v2_prerelease" ]]; then
      echo "lt"
      return
    else
      echo "eq"  # prereleases are equal
      return
    fi
  fi
}

# Only run main function if this script is called directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <version1> <version2>"
    echo "Returns: gt if version1 > version2, lt if version1 < version2, eq if version1 == version2"
    exit 1
  fi

  compare-semver-versions "$@"
fi
