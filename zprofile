#!/bin/zsh
# Set run
if [[ -z $RUN ]]; then
  RUN=true
fi

if ! [[ -z "$TMUX" ]]; then
  RUN=false
  TERM_DETECT=1
fi

if [[ -z $TERM_DETECT ]]; then
  # Exclude program detection code
  if [[ $TERM_PROGRAM == 'Apple_Terminal' ]]; then;
    RUN=false
  fi

  #Don't run this script if we're in VS Code or IntelliJ
  if [[ "$TERMINAL_EMULATOR" == "JetBrains-JediTerm" ]] ; then
    RUN=false
  fi

  if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    RUN=false
  fi

  # There seems to be issues with WSL at the moment.  Don't run TMUX
  if grep -q -i 'Microsoft' /proc/version 2>/dev/null || \
      grep -q -i 'Microsoft' /proc/sys/kernel/osrelease 2>/dev/null
      then
    RUN=false
  fi
fi

if [[ $RUN == 'true' ]]; then
  export EXIT_SESSION=0
  ~/.term-config/tmux-attach.sh
  if [[ "$?" == "0" ]]; then
    echo "TMUX session ended"
    exit 0
  elif [[ "$?" == "666" ]]; then
    echo "TMUX Session not attached"
  fi
fi

export PATH="$HOME/.cargo/bin:$PATH"
