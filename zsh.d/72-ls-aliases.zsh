#!/bin/zsh
if which lsd > /dev/null; then
    alias ls='lsd'
    alias l='lsd -l'
    alias la='lsd -a'
    alias lla='lsd -la'
    alias lt='lsd --tree'
    alias tree='lsd --tree'
else
    alias ls='ls --color'
    alias l='ls --color -l'
    alias la='ls --color -a'
    alias lla='ls --color -la'
    alias lt='tree'
fi
