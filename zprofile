#!/bin/zsh

# NOTE TO SELF!  These have to be here
if [[ $(uname) == 'Linux' ]]; then
    if [ -f "/etc/profile" ]; then
        emulate sh -c 'source /etc/profile'
    fi
fi

# Set run
if [[ -z $TMUX_ATTACH ]]; then
  TMUX_ATTACH=true
fi

if ! [[ -z "$TMUX" ]]; then
  echo "We're in a tmux session... don't run script again"
  TMUX_ATTACH=false
  TERM_DETECT=1
fi

if [[ -z $TERM_DETECT || $TMUX_ATTACH == 'false' ]]; then
  # Exclude program detection code for Apple Terminal
  # as various scripts including Powershell break
  # if tmux is run first
  if [[ $TERM_PROGRAM == 'Apple_Terminal' ]]; then;
    TMUX_ATTACH=false
  fi

  #Don't run this script if we're in VS Code or IntelliJ
  if [[ "$TERMINAL_EMULATOR" == "JetBrains-JediTerm" ]] ; then
    TMUX_ATTACH=false
  fi

  if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    TMUX_ATTACH=false
  fi

  # There seems to be issues with WSL at the moment.  Don't run TMUX
  if grep -q -i 'Microsoft' /proc/version 2>/dev/null || \
      grep -q -i 'Microsoft' /proc/sys/kernel/osrelease 2>/dev/null
      then
    TMUX_ATTACH=false
  fi

  # If we're in a Nerdfont Unsafe environemnt don't run tmux
  # Need to work out multiple themes for TMUX, until I do these
  # needs to stay in place.  Might move some of the above logic
  # out to zshenv where NF_SAFE is set.
  if [[ $NF_SAFE == 'false' ]]; then
    TMUX_ATTACH=false
  fi
fi

env > ~/.term-config/tmux.env

if [[ $TMUX_ATTACH == 'true' ]]; then
  export EXIT_SESSION=0
  ~/.term-config/tmux-attach.sh
  if [[ "$?" == "0" ]]; then
    echo "TMUX session ended"
    exit 0
  elif [[ "$?" == "666" ]]; then
    echo "TMUX Session not attached"
  fi
fi
