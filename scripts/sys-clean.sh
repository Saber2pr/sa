sudo echo

# 定义开始时间
start=$(date +%s)

userDir=$HOME

# 执行要计时的命令

# node_modules
echo clean node_modules & \
rm -rfv $userDir/*/node_modules & \

# vscode

echo clean vscode
rm -rfv "$userDir/Library/Application Support/Code/Service Worker/CacheStorage" & \
rm -rfv "$userDir/Library/Application Support/Code/logs" & \

# docker

echo clean docker & \
rm -rfv "$userDir/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw" & \

# sim

echo clean sim & \
rm -rfv "$userDir/Library/Developer/CoreSimulator/Caches" & \

echo clean local caches & \
rm -rfv "$userDir/Library/Caches" & \

sudo npm cache clean --force & \
sudo yarn cache clean & \

wait

# 计算并显示执行时间
end=$(date +%s)

runtime=$(echo "$end - $start" | bc)
echo "执行时间：$runtime 秒"
