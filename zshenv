export VERIFY_USE_PUBLIC_BINARIES=true
export DEVDIR=$HOME/Documents/Development
export TERMCONF=$HOME/.term-config
export ITERM_INT=false
export GPG_TTY=$(tty)
if [[ -v WSLENV ]]; then
    if [[ "$TERM_PROG" == "wsl-term" ]]; then
        export NF_SAFE=true 
    else
        export NF_SAFE=true
    fi
else
    if [[ "$TERM" == "linux" && -z $DISPLAY ]]; then
        export NF_SAFE=false
    else
        export NF_SAFE=true
    fi
fi
export PATH=$HOME/.cargo/bin:$PATH
export RUN=false
