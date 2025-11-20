#!/bin/bash

# generate commands
commands=$(sa _ ls 2>/dev/null | tr '\n' ' ')
sys_commands="ls cat cmd u upgrade"

# detect shell
if [ -n "$ZSH_VERSION" ]; then
    # zsh completion
    completion_dir="$HOME/.zsh/completions"
    mkdir -p "$completion_dir"
    file="$completion_dir/_sa"
    
    cat > "$file" << 'EOF'
#compdef sa

_sa() {
    local -a commands sys_commands
    
    # Get available scripts
    commands=($(sa _ ls 2>/dev/null))
    sys_commands=(ls cat cmd u upgrade)
    
    if (( CURRENT == 2 )); then
        # First argument: either "_" or a script name
        _describe 'commands' commands
        _describe 'system prefix' '_'
    elif (( CURRENT == 3 )); then
        # Second argument
        if [[ $words[2] == "_" ]]; then
            # System command
            _describe 'system commands' sys_commands
        fi
    elif (( CURRENT == 4 )); then
        # Third argument (for system commands)
        if [[ $words[2] == "_" ]]; then
            case $words[3] in
                cat)
                    # Complete script names for "sa _ cat <script>"
                    _describe 'scripts' commands
                    ;;
            esac
        fi
    fi
}

_sa "$@"
EOF
    
    chmod +x "$file"
    
    # Add to zshrc if not already added
    if ! grep -q "fpath=(\$HOME/.zsh/completions \$fpath)" "$HOME/.zshrc" 2>/dev/null; then
        echo "" >> "$HOME/.zshrc"
        echo "# sa completion" >> "$HOME/.zshrc"
        echo "fpath=(\$HOME/.zsh/completions \$fpath)" >> "$HOME/.zshrc"
        echo "autoload -U compinit && compinit" >> "$HOME/.zshrc"
    fi
    
    echo "Zsh completion installed at: $file"
    echo "Please run: source ~/.zshrc"
    
elif [ -n "$BASH_VERSION" ]; then
    # bash completion
    sourcedir="/etc/bash_completion.d"
    file="$sourcedir/saber2pr_cli.bash"
    
    mkdir -p "$sourcedir"
    
    cat > "$file" << EOF
_sa()
{
    local cur prev words cword
    COMPREPLY=()
    cur="\${COMP_WORDS[COMP_CWORD]}"
    prev="\${COMP_WORDS[COMP_CWORD-1]}"
    
    # Get available commands dynamically
    local commands="\$(sa _ ls 2>/dev/null | tr '\\n' ' ')"
    local sys_commands="$sys_commands"
    
    # If first argument is "_", complete system commands
    if [ "\${COMP_WORDS[1]}" = "_" ]; then
        if [ "\$COMP_CWORD" -eq 2 ]; then
            # Complete system command
            COMPREPLY=( \$(compgen -W "\$sys_commands" -- "\$cur") )
        elif [ "\$COMP_CWORD" -eq 3 ]; then
            # Third argument depends on the system command
            case "\$prev" in
                cat)
                    # Complete script names for "sa _ cat <script>"
                    COMPREPLY=( \$(compgen -W "\$commands" -- "\$cur") )
                    ;;
                *)
                    # For other system commands, use default file completion
                    COMPREPLY=( \$(compgen -f -- "\$cur") )
                    ;;
            esac
        else
            # For more arguments, use default file completion
            COMPREPLY=( \$(compgen -f -- "\$cur") )
        fi
    elif [ "\$COMP_CWORD" -eq 1 ]; then
        # First argument: complete script names or "_"
        local all_options="\$commands _"
        COMPREPLY=( \$(compgen -W "\$all_options" -- "\$cur") )
    else
        # For script arguments, use default file completion
        COMPREPLY=( \$(compgen -f -- "\$cur") )
    fi
    
    return 0
}
complete -F _sa sa
EOF
    
    chmod +x "$file"
    
    # Try to source if possible
    if [ -f "$file" ]; then
        source "$file" 2>/dev/null || true
    fi
    
    echo "Bash completion installed at: $file"
    echo "Please run: source $file"
    echo "Or restart your terminal"
else
    echo "Unsupported shell. Please use bash or zsh."
    exit 1
fi