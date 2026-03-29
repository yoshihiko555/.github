#!/usr/bin/env bash
# CHANGELOG.md の [Unreleased] セクションをバージョンセクションに切り出す
set -euo pipefail

version="${1:?Usage: release-changelog.sh <version> (e.g. v0.1.2)}"
version_num="${version#v}"
today=$(date +%Y-%m-%d)

if [ ! -f CHANGELOG.md ]; then
  echo "  ⚠ CHANGELOG.md が見つかりません"
  exit 1
fi

if ! grep -q "^## \[Unreleased\]" CHANGELOG.md; then
  echo "  ⚠ CHANGELOG.md に [Unreleased] セクションが見つかりません"
  exit 1
fi

# Unreleased セクションに内容があるか確認
content=$(awk '/^## \[Unreleased\]/{found=1; next} found && /^## \[/{exit} found{print}' CHANGELOG.md | grep -v '^$' || true)
if [ -z "$content" ]; then
  echo "  ⚠ [Unreleased] セクションが空です。リリースする変更がありません"
  exit 1
fi

# 既にバージョンセクションが存在する場合はスキップ
if grep -q "^## \[$version_num\]" CHANGELOG.md; then
  echo "  ✓ CHANGELOG.md に [$version_num] セクションが既に存在します"
  exit 0
fi

# [Unreleased] の直後に新バージョンヘッダーを挿入し、
# Unreleased セクションの内容を新バージョンセクション配下に移動する
awk -v ver="$version_num" -v dt="$today" '
  /^## \[Unreleased\]/ {
    print "## [Unreleased]"
    print ""
    print "## [" ver "] - " dt
    moving = 1
    next
  }
  moving && /^## \[/ {
    print
    moving = 0
    next
  }
  { print }
' CHANGELOG.md > CHANGELOG.md.tmp && mv CHANGELOG.md.tmp CHANGELOG.md

# フッターのリンクを更新
if grep -q "^\[Unreleased\]:" CHANGELOG.md; then
  prev_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
  if [ -n "$prev_tag" ]; then
    repo_slug=$(git remote get-url origin | sed 's/.*github.com[:/]//' | sed 's/\.git$//')
    sed -i '' "s|^\[Unreleased\]:.*|[Unreleased]: https://github.com/${repo_slug}/compare/${version}...HEAD|" CHANGELOG.md
    sed -i '' "/^\[Unreleased\]:/a\\
[$version_num]: https://github.com/${repo_slug}/compare/${prev_tag}...${version}" CHANGELOG.md
  fi
fi

git add CHANGELOG.md
git commit -m "chore(release): update CHANGELOG.md for $version"

echo "  ✓ CHANGELOG.md を $version 用に更新しコミットしました"
