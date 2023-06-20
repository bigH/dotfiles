export SHELL="/bin/bash"
export SHELL_NAME="bash"

export DOT_FILES_DIR="$HOME/.hiren"

source "$DOT_FILES_DIR/profile"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/hiren/miniconda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/hiren/miniconda/etc/profile.d/conda.sh" ]; then
        . "/Users/hiren/miniconda/etc/profile.d/conda.sh"
    else
        export PATH="/Users/hiren/miniconda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

