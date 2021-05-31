#!/bin/zsh
#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_COMPLETION_OPTS='--border --info=inline'
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
--border
--color=dark
--color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f
--color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
'
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
