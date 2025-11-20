#!/bin/bash

# generate commands
commands=$(sa _ ls 2>/dev/null | tr '\n' ' ')
sys_commands="ls cat cmd u upgrade"

# detect shell - check multiple ways to detect zsh
# Method 1: Check if running in zsh (ZSH_VERSION is set)
# Method 2: Check $SHELL environment variable
# Method 3: Check parent shell via ps
detect_zsh() {
    if [ -n "$ZSH_VERSION" ]; then
        return 0
    fi
    
    # Check $SHELL environment variable
    if [ -n "$SHELL" ] && [[ "$SHELL" == *"zsh"* ]]; then
        return 0
    fi
    
    # Check parent process
    local parent_shell=$(ps -p $PPID -o comm= 2>/dev/null | head -1)
    if [[ "$parent_shell" == *"zsh"* ]]; then
        return 0
    fi
    
    # Check if zsh is available and is the default shell
    if command -v zsh >/dev/null 2>&1; then
        local default_shell=$(getent passwd "$USER" 2>/dev/null | cut -d: -f7)
        if [[ "$default_shell" == *"zsh"* ]]; then
            return 0
        fi
    fi
    
    return 1
}

# Allow manual override via environment variable
if [ -n "$SA_COMPLETION_SHELL" ]; then
    if [[ "$SA_COMPLETION_SHELL" == "zsh" ]]; then
        FORCE_ZSH=true
    elif [[ "$SA_COMPLETION_SHELL" == "bash" ]]; then
        FORCE_BASH=true
    fi
fi

# detect shell
if [ -n "$FORCE_ZSH" ] || detect_zsh; then
    # zsh completion - support multiple locations
    # Try user directory first, then system directory
    if [ -w "$HOME/.zsh/completions" ] || mkdir -p "$HOME/.zsh/completions" 2>/dev/null; then
        completion_dir="$HOME/.zsh/completions"
    elif [ -w "/usr/local/share/zsh/site-functions" ] || [ -w "/usr/share/zsh/site-functions" ]; then
        if [ -w "/usr/local/share/zsh/site-functions" ]; then
            completion_dir="/usr/local/share/zsh/site-functions"
        else
            completion_dir="/usr/share/zsh/site-functions"
        fi
    else
        completion_dir="$HOME/.zsh/completions"
        mkdir -p "$completion_dir"
    fi
    
    file="$completion_dir/_sa"
    
    cat > "$file" << 'EOF'
#compdef sa

_sa() {
    local -a commands sys_commands
    
    # Get available scripts dynamically (with error handling)
    commands=(${(f)"$(sa _ ls 2>/dev/null)"})
    sys_commands=(ls cat cmd u upgrade completion auto)
    
    # Remove empty elements
    commands=(${commands:#})
    
    # words[1] is "sa", words[2] is first argument
    if (( CURRENT == 2 )); then
        # First argument: either "_" or a script name
        local -a all_options
        all_options=("_" $commands)
        _describe -t commands 'sa commands' all_options
    elif (( CURRENT == 3 )); then
        # Second argument
        if [[ $words[2] == "_" ]]; then
            # System command
            _describe -t sys-commands 'system commands' sys_commands
        else
            # For script commands, use file completion
            _files
        fi
    elif (( CURRENT == 4 )); then
        # Third argument (for system commands)
        if [[ $words[2] == "_" ]]; then
            case $words[3] in
                cat)
                    # Complete script names for "sa _ cat <script>"
                    if (( ${#commands} > 0 )); then
                        _describe -t scripts 'scripts' commands
                    else
                        _files
                    fi
                    ;;
                cmd|completion|auto)
                    # For these commands, use file completion
                    _files
                    ;;
                *)
                    # For other system commands, use file completion
                    _files
                    ;;
            esac
        else
            # For script arguments, use file completion
            _files
        fi
    else
        # For more arguments, use file completion
        _files
    fi
}

_sa "$@"
EOF
    
    chmod +x "$file" 2>/dev/null || true
    
    # Add to zshrc if not already added
    zshrc="$HOME/.zshrc"
    needs_fpath=false
    needs_compinit=false
    
    if [[ "$completion_dir" == "$HOME/.zsh/completions" ]]; then
        needs_fpath=true
    fi
    
    if [ -f "$zshrc" ]; then
        # Check if fpath needs to be added
        if [ "$needs_fpath" = "true" ] && ! grep -qE "fpath=.*\.zsh/completions" "$zshrc" 2>/dev/null; then
            needs_fpath=true
        else
            needs_fpath=false
        fi
        
        # Check if compinit is already called
        if ! grep -qE "compinit" "$zshrc" 2>/dev/null; then
            needs_compinit=true
        fi
    else
        # Create .zshrc if it doesn't exist
        if [ -n "$zshrc" ]; then
            touch "$zshrc" 2>/dev/null || true
        fi
        needs_fpath=true
        needs_compinit=true
    fi
    
    # Add configuration to .zshrc
    if [ "$needs_fpath" = "true" ] || [ "$needs_compinit" = "true" ]; then
        if [ -n "$zshrc" ] && [ -f "$zshrc" ]; then
            echo "" >> "$zshrc"
            echo "# sa completion" >> "$zshrc"
            if [ "$needs_fpath" = "true" ]; then
                echo "fpath=(\$HOME/.zsh/completions \$fpath)" >> "$zshrc"
            fi
            if [ "$needs_compinit" = "true" ]; then
                echo "autoload -U compinit" >> "$zshrc"
                echo "compinit" >> "$zshrc"
            fi
        fi
    fi
    
    # Try to reload completion in current session
    if [ -n "$ZSH_VERSION" ]; then
        # Add to fpath for current session
        if [[ "$completion_dir" == "$HOME/.zsh/completions" ]]; then
            fpath=("$HOME/.zsh/completions" $fpath) 2>/dev/null || true
        fi
        # Try to reload
        if command -v compinit >/dev/null 2>&1 || autoload -U compinit 2>/dev/null; then
            compinit 2>/dev/null || true
        fi
    fi
    
    echo "✅ Zsh completion installed at: $file"
    if [[ "$completion_dir" == "$HOME/.zsh/completions" ]]; then
        echo "📝 Configuration added to ~/.zshrc"
        echo "💡 Please run: source ~/.zshrc"
        echo "   Or restart your terminal to enable completion"
    else
        echo "📝 Completion installed to system directory: $completion_dir"
        echo "💡 Please restart your terminal or run: compinit"
    fi
    
elif [ -n "$FORCE_BASH" ] || [ -n "$BASH_VERSION" ]; then
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