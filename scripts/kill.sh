#!/bin/bash
# 用法示例：
#   ./port-check.sh 8080

# 检查是否传入端口号
if [ -z "$1" ]; then
  echo "用法：$0 <端口号>"
  exit 1
fi

PORT=$1

# macOS 下使用 lsof 命令
echo "正在检查端口 $PORT 的占用情况..."

# 查找占用该端口的进程
result=$(lsof -i tcp:$PORT 2>/dev/null)

if [ -z "$result" ]; then
  echo "✅ 端口 $PORT 当前未被占用。"
else
  echo "⚠️ 端口 $PORT 被以下进程占用："
  echo "$result"
  echo
  # 如果想直接杀死进程，可以选择执行：
  pid=$(echo "$result" | awk 'NR==2 {print $2}')
  echo "PID: $pid"
  read -p "是否要结束该进程？(y/N): " confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    kill -9 "$pid" && echo "✅ 已结束进程 $pid" || echo "❌ 结束失败，请检查权限。"
  else
    echo "已取消。"
  fi
fi
