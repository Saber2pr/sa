# generate commands
commands=$(sa _ ls | tr '\n' ' ')

# paths
sourcedir="/etc/bash_completion.d"
file="$sourcedir/saber2pr_cli.bash"

# register to source
echo "_sa()
{
    local cur=\${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( \$(compgen -W "$commands" -- \$cur) )
}
complete -F _sa sa" > $file

# enable settings
chmod +x $file
source $file