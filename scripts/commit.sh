msg="$1"
if [ -z "$msg" ]; then
  echo "错误：缺少提交信息。用法: $0 <commit message>" >&2
  exit 1
fi
git pull
git add .
git commit -a -m "$msg"
git push --follow-tags
