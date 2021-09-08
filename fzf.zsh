# Setup fzf
# ---------
if [[ ! "$PATH" == */home/jamie/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/jamie/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/jamie/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/jamie/.fzf/shell/key-bindings.zsh"
