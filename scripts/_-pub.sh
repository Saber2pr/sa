# pub files
files=$@

function get_absPaths {
  node -p "'$1'.split(' ').map(file => path.resolve(file)).join(' ')"
}

abs_files=$(get_absPaths "$files")

# cd temp
tmpdir=$(node -p 'os.tmpdir()')
name="sa-pub-temp"

# pubtmp
pubtmp=$(node -p "path.join('$tmpdir', '$name')")

# checkout in sa
cd $pubtmp
git clone https://github.com/Saber2pr/sa.git $name
cd $name

for item in $abs_files;
do
  cp $item ./scripts
done

# sa git-push-u

open .