# action-is-release

## Description

This action checks to see if the `.version` key in a repository's `package.json` has changed in order to determine if this commit is a release commit.

![image](https://user-images.githubusercontent.com/675259/181828020-b54ef521-20f1-477c-83b4-3e9ac5b91398.png)

## Usage

```yaml
jobs:
  is-release:
    # release merge commits come from GitHub user
    if: github.event.head_commit.committer.name == 'GitHub'
    outputs:
      IS_RELEASE: ${{ steps.is-release.outputs.IS_RELEASE }}
    runs-on: ubuntu-latest
    steps:
      - uses: MetaMask/action-is-release@v1.0
        id: is-release
```


