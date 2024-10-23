name=.temp
repo=$1

# clone new repo
git clone --depth 1 $repo $name

rm -rf $name/.git

# copy new repo files
ls -A1 $name | xargs -I {} cp -r $name/{} ./
rm -rf ./.temp
