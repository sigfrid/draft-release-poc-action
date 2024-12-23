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
      - name: Checkout action
        uses: actions/checkout@v2
        with:
          repository: 'sigfrid/draft-release-poc-action'
          ref: 'main'
      - name: Set up ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
      - name: Draft release
        uses: sigfrid/draft-release-poc-action@main
        env:
          GITHUB_ACCESS_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITHUB_REPOSITORY: $GITHUB_REPOSITORY
          GITHUB_MILESTONE: ${{ github.event.client_payload.target_release }}
```
