# .github

yoshihiko555 の共通 GitHub 資材を管理するリポジトリ。

## 構成

```
.github/
├── .github/
│   └── workflows/
│       └── release.yml            # reusable release workflow
├── taskfiles/
│   └── release.yml                # 共通 release タスク定義
├── templates/
│   └── release.yml                # release notes カテゴリ設定テンプレート
├── docs/
│   ├── git-release-policy.md      # Git/release 運用方針
│   └── github-rulesets.md         # Rulesets の管理・import 手順
├── rulesets/
│   ├── main-protection.json       # main branch 保護
│   ├── tag-protection.json        # release tag 保護
│   └── README.md
├── PULL_REQUEST_TEMPLATE.md       # 共通 PR テンプレート
└── README.md
```

## Reusable Workflows

| Workflow | 用途 |
|----------|------|
| `.github/workflows/release.yml` | tag push を契機に CHANGELOG.md から GitHub Release を作成 |

## Release タスク

`taskfiles/release.yml` は各 repo の Taskfile からローカル参照する:

```yaml
includes:
  rel:
    taskfile: ~/ghq/github.com/yoshihiko555/.github/taskfiles/release.yml
    flatten: true
```

前提: `ghq get yoshihiko555/.github`

## 各 repo での利用方法

1. `.github/workflows/release.yml` に caller workflow を置く:

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

2. `Taskfile.yml` に上記の release タスク参照を追加する
3. `CHANGELOG.md` を用意する

## GitHub 設定

### Rulesets

`rulesets/` に GitHub Rulesets の共通 JSON を管理する。

#### 新しい repo への import 手順

1. 対象 repo の **Settings** → **Rules** → **Rulesets** を開く
2. **New ruleset** → **Import a ruleset** を選ぶ
3. `rulesets/` 配下の JSON を読み込む
   - `main-protection.json` — main branch 保護
   - `tag-protection.json` — release tag 保護
4. import 内容を確認して作成する

#### import 後に確認する項目

- target pattern が `main` など意図した対象になっている
- required status checks がその repo の CI ジョブ名と一致している
- bypass actor が意図どおりか
- `Require a pull request before merging` が有効か
- force push 禁止・linear history が有効か
- tag ruleset を使う repo では tag 側も設定したか

### Pull Requests 設定

各 repo で **Settings** → **General** → **Pull Requests** を次のように設定する。

| 設定項目 | 値 |
|----------|-----|
| Allow squash merging | ON |
| Allow merge commits | OFF |
| Allow rebase merging | OFF |
| Automatically delete head branches | ON |

詳細は `docs/github-rulesets.md` を参照。

## Release workflow の動作

1. tag push (`v*`) をトリガーに caller workflow が起動
2. reusable workflow が `CHANGELOG.md` から該当バージョンのエントリを抽出
3. エントリがあれば release notes として使用、なければ `--generate-notes` にフォールバック
4. GitHub Release を作成（既に存在する場合はスキップ）
