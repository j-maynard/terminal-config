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
export XDG_CONFIG_HOME=$HOME/.config
if [[ $XDG_SESSION_TYPE == 'wayland' ]]; then
    export CHROME_FLAGS='--enable-features=UseOzonePlatform --ozone-platform=wayland'
    export CHROMIUM_FLAGS='--enable-features=UseOzonePlatform --ozone-platform=wayland'
    export ELECTRON_FLAGS='--enable-features=UseOzonePlatform --ozone-platform=wayland'
    export ELECTRON12_FLAGS='--enable-features=UseOzonePlatform --ozone-platform=wayland'
fi
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

# Setup homebrew on the mac
if [[ $(uname) == "Darwin" ]]; then
    eval $(/opt/homebrew/bin/brew shellenv)
    # Build MacOS Path
    export PATH="/Library/Frameworks/Python.framework/Versions/3.10/bin:${PATH}"
fi

export TMUX_INTEGRATION=true

# Uncomment to stop TMUX from running at startup
export RUN=false

# Bug in pip3 means it looks for a keyring
# if it queries kwallet and no keyring exists
# it prompts kwallet to create one.  This envvar
# stops that from happening.
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring

# HiDPI Settings for GTK Apps doesn't work well with
# KDE Plasma HiDPI Scalling.
# export GDK_DPI_SCALE=1.75
# export GDK_SCALE=1.75

if [[ $(uname) == "Darwin" ]]; then
    export PAGER=/opt/homebrew/bin/bat
    export EDITOR=/opt/homebrew/bin/nvim
else
    export PAGER=/usr/bin/bat
    export EDITOR=/usr/bin/nvim
fi

# Source local environment variables to over ride
# any of the envars defined here.
source ~/.term-config/zshenv.local
. "$HOME/.cargo/env"
