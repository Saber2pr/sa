name=.temp
repo=$1

git clone --depth 1 $repo $name

ls -A1 $name | xargs -I {} cp -r $name/{} ./
rm -rf ./.temp