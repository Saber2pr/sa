file-drop start

# 检查命令的返回代码
if [ $? -eq 0 ]; then
  echo "Bye"
else
  echo "未检测到安装，正在执行 CLI 安装"
  sudo npm i -g @saber2pr/file-drop@0.0.5
  file-drop start
fi
