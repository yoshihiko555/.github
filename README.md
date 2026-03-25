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
│   ├── CHANGELOG.md               # CHANGELOG テンプレート
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

## 新規リポジトリセットアップ

新しいリポジトリを作成したら、以下の手順で共通資材を導入する。

### 1. リポジトリファイルの配置

#### CHANGELOG.md

`templates/CHANGELOG.md` をリポジトリルートの `CHANGELOG.md` としてコピーする。
初回作成時から `Unreleased` と version セクションの見出し形式を揃えておく。

```markdown
# Changelog

## [Unreleased]

### Added

### Changed

### Fixed

## [0.1.0] - YYYY-MM-DD
```

#### Release caller workflow

`.github/workflows/release.yml` に caller workflow を置く:

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

#### Release notes カテゴリ設定

`templates/release.yml` を `.github/release.yml` としてコピーする。
PR ラベルに応じた GitHub Release notes の自動カテゴリ分けが有効になる。

#### PR テンプレート

`PULL_REQUEST_TEMPLATE.md` を `.github/PULL_REQUEST_TEMPLATE.md` としてコピーする。

#### Taskfile

前提: `ghq get yoshihiko555/.github`

`Taskfile.yml` に release タスク参照を追加する:

```yaml
includes:
  rel:
    taskfile: ~/ghq/github.com/yoshihiko555/.github/taskfiles/release.yml
    flatten: true
```

### 2. GitHub Settings

#### Rulesets

`rulesets/` に GitHub Rulesets の共通 JSON を管理する。

1. 対象 repo の **Settings** → **Rules** → **Rulesets** を開く
2. **New ruleset** → **Import a ruleset** を選ぶ
3. `rulesets/` 配下の JSON を読み込む
   - `main-protection.json` — main branch 保護
   - `tag-protection.json` — release tag 保護
4. import 内容を確認して作成する

import 後に確認する項目:

- target pattern が `main` など意図した対象になっている
- required status checks がその repo の CI ジョブ名と一致している
- bypass actor が意図どおりか
- `Require a pull request before merging` が有効か
- force push 禁止・linear history が有効か
- tag ruleset を使う repo では tag 側も設定したか

#### Pull Requests 設定

**Settings** → **General** → **Pull Requests** を次のように設定する。

| 設定項目 | 値 |
|----------|-----|
| Allow squash merging | ON |
| Allow merge commits | OFF |
| Allow rebase merging | OFF |
| Automatically delete head branches | ON |

詳細は `docs/github-rulesets.md` を参照。

### セットアップチェックリスト

- [ ] `CHANGELOG.md` を作成した
- [ ] `.github/workflows/release.yml` (caller workflow) を配置した
- [ ] `.github/release.yml` (release notes カテゴリ設定) を配置した
- [ ] `.github/PULL_REQUEST_TEMPLATE.md` を配置した
- [ ] `Taskfile.yml` に release タスク参照を追加した
- [ ] Rulesets を import した（main-protection / tag-protection）
- [ ] Pull Requests 設定を確認した（squash merge / delete head branches）

## Release workflow の動作

1. tag push (`v*`) をトリガーに caller workflow が起動
2. reusable workflow が `CHANGELOG.md` から該当バージョンのエントリを抽出
3. エントリがあれば release notes として使用、なければ `--generate-notes` にフォールバック
4. GitHub Release を作成（既に存在する場合はスキップ）
