# GitHub Action: Create release and version branch

Creates a release and version branch when a specific commit message is provided 

## Inputs

### `github_token`
**Optional**

### `COMMIT_MESSAGE`

**Required**. Commit message that is required to know which version to increment.

## Example usage
```yml
name: Creates new release and version branch
on:
  push:
    branch: "master"

jobs:
  create-release-and-branch:
  - uses: MineHub-Technologies/action-create-release-and-version-branch@master
    id: create-release-and-version-branch
    with:
      COMMIT_MESSAGE: ${{ github.event.head_commit.message }}
```
