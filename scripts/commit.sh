#!/usr/bin/env bash
set -euo pipefail

msg="$*"
if [ -z "$msg" ]; then
  echo "错误：缺少提交信息。用法: $0 <commit message>" >&2
  exit 1
fi

git add -A
if git diff --cached --quiet; then
  echo "没有需要提交的改动，跳过 commit。"
else
  git commit --no-verify -m "$msg"
fi

git pull --rebase
git push --follow-tags
