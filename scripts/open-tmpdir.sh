dir=$(node -p 'os.tmpdir()')

if [ "$OSTYPE" == 'msys' ]; then
  start $dir
else 
  open $dir
fi