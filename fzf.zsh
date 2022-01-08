# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/jamie/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/Users/jamie/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/Users/jamie/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/Users/jamie/.fzf/shell/key-bindings.zsh"
