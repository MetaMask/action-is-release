# action-is-release

## Description

Check whether the current commit is a release commit. Primarily this action looks at the `.version` key in a repository's `package.json` to see whether it has changed. Optionally, it can also validate that the commit message starts with a specific string.

![image](https://user-images.githubusercontent.com/675259/181828020-b54ef521-20f1-477c-83b4-3e9ac5b91398.png)

## Usage

### Basic usage

This will look at the current commit, comparing it to `github.event.before` to see whether the `version` field of the `package.json` file in the root directory of the repository has changed. If the version has been updated, `IS_RELEASE` will be set to `true`. Otherwise, it will be set to `false`.

```yaml
jobs:
  is-release:
    outputs:
      IS_RELEASE: ${{ steps.is-release.outputs.IS_RELEASE }}
    runs-on: ubuntu-latest
    steps:
      - uses: MetaMask/action-is-release@v1.0
        id: is-release
```

### Filter by merge commit author

Here is an example of how to use this action with a merge author filter. This will act the same as the previous example, except that it will be skipped if the commit author is anyone other than "GitHub". When skipped, `IS_RELEASE` will be unset.

```yaml
jobs:
  is-release:
    # Filter by commits made by the author "github-actions"
    if: github.event.head_commit.author.name == 'github-actions'
    outputs:
      IS_RELEASE: ${{ steps.is-release.outputs.IS_RELEASE }}
    runs-on: ubuntu-latest
    steps:
      - uses: MetaMask/action-is-release@v1.0
        id: is-release
```

### With specific commit message prefix

Here is an example of how to use the `commit-starts-with` option.

```yaml
jobs:
  is-release:
    outputs:
      IS_RELEASE: ${{ steps.is-release.outputs.IS_RELEASE }}
    runs-on: ubuntu-latest
    steps:
      - uses: MetaMask/action-is-release@v1.0
        id: is-release
        with:
          commit-starts-with: 'Release [version]'
```

This will set `IS_RELEASE` to `true` if triggered on a commit where the package version changed, and where the commit message starts with "Release [new package version]" (e.g "Release 1.0.0", if the package version was updated to "1.0.0").

### With specific commit message body prefix

Here is an example of how to use the `commit-body-starts-with` option.

```yaml
jobs:
  is-release:
    outputs:
      IS_RELEASE: ${{ steps.is-release.outputs.IS_RELEASE }}
    runs-on: ubuntu-latest
    steps:
      - uses: MetaMask/action-is-release@v1.0
        id: is-release
        with:
          commit-body-starts-with: 'Release [version]'
```

This behaves the same as the `commit-starts-with` option but ignores the title of the commit message.

For example, the below commit message would result in `IS_RELEASE` set to `true`, assuming the package version had still been changed.

```
Merge pull request #123 from release/1.0.0

Release 1.0.0
```

This can be used to identify release commits that are also merge commits and therefore have a fixed title format.

### Conditionally running release jobs

You can then add filters in following jobs so those will skip if the `IS_RELEASE` criteria isn't met:

```yaml
jobs:
  is-release:
    < insert example from above >
  publish-release:
    if: needs.is-release.outputs.IS_RELEASE == 'true'
    runs-on: ubuntu-latest
    needs: is-release
```

### Alternate package directories

If the relevant version is not defined in the `package.json` in the root directory, an alternate directory can be specified using the `package-dir` option.

```yaml
jobs:
  is-release:
    outputs:
      IS_RELEASE: ${{ steps.is-release.outputs.IS_RELEASE }}
    runs-on: ubuntu-latest
    steps:
      - uses: MetaMask/action-is-release@v1.0
        id: is-release
        with:
          package-dir: 'packages/some-workspace'
```

This can be used to identify release commits in monorepos that contain multiple packages and therefore multiple `package.json` files with alternate versions.
