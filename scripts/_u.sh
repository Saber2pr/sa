cwd=$1

if [ "$cwd" != "" ]; then
  echo + cd $cwd
  cd $cwd
else
  echo
fi

sa git-push-u