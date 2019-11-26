#!/bin/zsh
# LS with icons when available
which lsd > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    alias ls='lsd'
    alias l='lsd -l'
    alias la='lsd -a'
    alias lla='lsd -la'
    alias lt='lsd --tree'
    alias tree='lsd --tree'
else
    which colorls > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
      alias ls='colorls'
      alias l='colorls -l'
      alias la='colorls -a'
      alias lla='colorls -la'
      alias lt='colorls --tree'
      alias tree='colorls --tree'
    else
      alias ls='ls --color'
  fi
fi
