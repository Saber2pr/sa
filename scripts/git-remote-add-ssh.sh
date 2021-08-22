remoteList="$(git remote -v)"
# parse origin
originHttp="$(echo $remoteList | grep -oP "origin \K(\S*?) (?=\(fetch\))")"
# parse repo path
repo="$(echo $originHttp | grep -oP "https://github\.com/\K(\S*?)$")"
# create ssh url
ssh="$(echo "git@github.com:$repo")"
# config ssh remote
git remote add ssh $ssh