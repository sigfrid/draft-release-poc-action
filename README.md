# draft-release-poc-action

```
name: Draft a Release
on:
  repository_dispatch:
    types: [release]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: Draft release
      uses: sigfrid/draft-release-poc-action
      env:
        GITHUB_ACCESS_TOKEN: xxxxx
        GITHUB_REPOSITORY: xxxx/xxxxxx
        GITHUB_MILESTONE: xxxx
```
