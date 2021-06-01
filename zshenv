export VERIFY_USE_PUBLIC_BINARIES=true
export DEVDIR=$HOME/Development
export TERMCONF=$HOME/.term-config
export ITERM_INT=false
export GPG_TTY=$(tty)
export GPG_KEY=9073DEB608346BA4
export GNUPGHOME=${HOME}/.gnupg
export NERD_FONT=true
export NF=true
export POWERLINE_SAFE=true
export PATH=$HOME/.local/bin:$PATH
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
export TMUX_INTEGRATION=true

# Uncomment to stop TMUX from running at startup
export RUN=false

# HiDPI Settings for GTK Apps doesn't work well with
# KDE Plasma HiDPI Scalling.
# export GDK_DPI_SCALE=1.75
# export GDK_SCALE=1.75

