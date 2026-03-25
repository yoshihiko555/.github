# .github

yoshihiko555 の共通 GitHub 資材を管理するリポジトリ。

## 内容

### Reusable Workflows

| Workflow | 用途 |
|----------|------|
| `.github/workflows/release.yml` | tag push を契機に CHANGELOG.md から GitHub Release を作成 |

### 各 repo での利用方法

各 repo の `.github/workflows/release.yml` に以下の caller workflow を置く:

```yaml
name: Release

on:
  push:
    tags:
      - "v*"

jobs:
  release:
    uses: yoshihiko555/.github/.github/workflows/release.yml@main
```

### Release workflow の動作

1. tag push (`v*`) をトリガーに caller workflow が起動
2. reusable workflow が `CHANGELOG.md` から該当バージョンのエントリを抽出
3. エントリがあれば release notes として使用、なければ `--generate-notes` にフォールバック
4. GitHub Release を作成（既に存在する場合はスキップ）

### 関連

- release タスク（tag 作成・push）: [dotfiles/taskfiles/release.yml](https://github.com/yoshihiko555/dotfiles)
- Git/release 運用方針: [dotfiles/github/docs/git-release-policy.md](https://github.com/yoshihiko555/dotfiles)
- Rulesets JSON: [dotfiles/github/rulesets/](https://github.com/yoshihiko555/dotfiles)
