
branch=${1:-master}
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --msg-filter "perl -CIOED -p -e 's/\p{Script_Extensions=Han}/ /g'" $branch