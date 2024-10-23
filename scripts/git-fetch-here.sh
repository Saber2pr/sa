name=.temp
repo=$1

# save old origin
originUrl=$(git remote get-url origin)

# clone new repo
git clone --depth 1 $repo $name

# copy new repo files
ls -A1 $name | xargs -I {} cp -r $name/{} ./
rm -rf ./.temp

# clear current git
rm -rf .git
git init

# set old origin
git remote add origin $originUrl