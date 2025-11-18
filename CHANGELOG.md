# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.2.0]

### Added

- Add option to skip checkout ([#17](https://github.com/MetaMask/action-is-release/pull/17))
  - This is useful when the action is used in a workflow that has already checked out the repository.

## [2.1.0]

### Added

- Add options to check if a pull request is a release PR ([#14](https://github.com/MetaMask/action-is-release/pull/14))
  - This adds two new optional inputs:
    - `before`: Used to check commits before a specific SHA (e.g., the base of a PR) for a version bump.
    - `commit-message`: Used to specify the commit message to check for the release format, e.g., the pull request title.

### Fixed

- Use environment variables for script inputs ([#15](https://github.com/MetaMask/action-is-release/pull/15))

## [2.0.0]

### Changed

- **BREAKING:** Bump `actions/checkout` to `v4` ([#11](https://github.com/MetaMask/action-is-release/pull/11))
  - This is a breaking change because `actions/checkout@v4` uses Node 20.
- Support multiple commit prefixes ([#6](https://github.com/MetaMask/action-is-release/pull/6))

[Unreleased]: https://github.com/MetaMask/action-is-release/compare/v2.2.0...HEAD
[2.2.0]: https://github.com/MetaMask/action-is-release/releases/tag/v2.2.0
[2.1.0]: https://github.com/MetaMask/action-is-release/releases/tag/v2.1.0
[2.0.0]: https://github.com/MetaMask/action-is-release/releases/tag/v2.0.0
