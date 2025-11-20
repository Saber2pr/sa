#!/bin/bash

# 目标值
MAXFILES=200000

echo "=== 提升系统 maxfiles 为 $MAXFILES ==="

# 1️⃣ 修改 /etc/sysctl.conf
if grep -q "kern.maxfiles=" /etc/sysctl.conf 2>/dev/null; then
    sudo sed -i '' "s/^kern.maxfiles=.*/kern.maxfiles=$MAXFILES/" /etc/sysctl.conf
else
    echo "kern.maxfiles=$MAXFILES" | sudo tee -a /etc/sysctl.conf
fi

if grep -q "kern.maxfilesperproc=" /etc/sysctl.conf 2>/dev/null; then
    sudo sed -i '' "s/^kern.maxfilesperproc=.*/kern.maxfilesperproc=$MAXFILES/" /etc/sysctl.conf
else
    echo "kern.maxfilesperproc=$MAXFILES" | sudo tee -a /etc/sysctl.conf
fi

# 2️⃣ 立即生效
sudo sysctl -w kern.maxfiles=$MAXFILES
sudo sysctl -w kern.maxfilesperproc=$MAXFILES

# 3️⃣ 当前 shell 会话生效
ulimit -n $MAXFILES

echo "✅ 文件句柄限制已提升到 $MAXFILES"
echo "注意：系统永久生效需要重启或重新登录 shell"
