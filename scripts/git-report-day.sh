echo -e "$(date +'%Y-%m-%d')日报 $(git config user.name)\n$(git log $(git branch --show-current) --reverse --pretty=format:"%cd %s" --since="date '+%Y-%m-%d 00:00:00'" --date=format:'%H:%M:%S' --invert-grep --extended-regexp --no-merges)" > $(git config user.name)的$(date +'%Y-%m-%d')日报.txt