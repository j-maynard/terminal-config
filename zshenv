export VERIFY_USE_PUBLIC_BINARIES=true
export DEVDIR=$HOME/Development
export TERMCONF=$HOME/.term-config
export ITERM_INT=false
export GPG_TTY=$(tty)
export GPG_KEY=9073DEB608346BA4
export NERD_FONT=true
export NF=true
export POWERLINE_SAFE=true
if [[ -v WSLENV ]]; then
    if [[ "$TERM_PROG" == "winterm" ]]; then
        export NF_SAFE=true
        export POWERLINE_SAFE=true
    elif [[ $WSLENV == "WT_SESSION::WT_PROFILE_ID" ]]; then
        export NF_SAFE=true
        export POWERLINE_SAFE=true
    else
        export NF_SAFE=false
        export POWERLINE_SAFE=false
    fi
else
    if [[ "$TERM" == "linux" && -z $DISPLAY ]]; then
        export TERM_PROG='linux_console'
        export NF_SAFE=false
        export POWERLINE_SAFE=true
    elif [[ $TERM_PROG == 'linux_console' ]]; then
        export NF_SAFE=false
        export POWERLINE_SAFE=true
    else
        export NF_SAFE=true
        export POWERLINE_SAFE=true
    fi
fi
export TMUX_ATTACH=false
