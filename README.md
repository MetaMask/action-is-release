# action-is-release

## Description

This action checks to see if the `.version` key in a repository's `package.json` has changed in order to determine if this commit is a release commit.

![image](https://user-images.githubusercontent.com/675259/181828020-b54ef521-20f1-477c-83b4-3e9ac5b91398.png)

## Usage

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
You can then add filters in following jobs so those will skip if the `IS_RELEASE` criteria isn't met:

```yaml
publish-release:
    if: needs.is-release.outputs.IS_RELEASE == 'true'
    runs-on: ubuntu-latest
    needs: is-release
```
