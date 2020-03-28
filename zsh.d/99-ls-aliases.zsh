#!/bin/zsh
# LS with icons when available
which lsd > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    LS_MOD=lsd
fi
which colorls > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    LS_MOD=colorls
fi
if [[ "$NF_SAFE" == "false" ]]; then
    LS_MOD=safe
fi
if [[ -z $LS_MOD ]]; then
    LS_MOD=safe
fi

case $LS_MOD in
    lsd)
        alias ls='lsd'
        alias l='lsd -l'
        alias la='lsd -a'
        alias lla='lsd -la'
        alias lt='lsd --tree'
        alias tree='lsd --tree'
        ;;
    colorls)
        alias ls='colorls'
        alias l='colorls -l'
        alias la='colorls -a'
        alias lla='colorls -la'
        alias lt='colorls --tree'
        alias tree='colorls --tree'
        ;;
    safe)
        alias ls='ls --color'
        alias l='ls --color -l'
        alias la='ls --color -a'
        alias lla='ls --color -la'
        alias lt='tree'
        ;;
    *)
        alias ls='ls'
        alias l='ls -l'
        alias la='ls -a'
        alias lla='ls -al'
        alias lt='tree'
esac
