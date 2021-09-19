_sa()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -W docker-clean git-clone-1 git-clone-dir git-clone-sa git-clone git-filter-hans git-log git-merge-x git-push-tag git-push-u git-remote-add-ssh git-report-day git-subm-rm init ipv4 nest-m npm-g-ls o open-tmpdir s tsc-check _pub  -- $cur) )
}
complete -F _sa sa
