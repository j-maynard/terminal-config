#!/bin/bash
# If we're not in a TMUX session lets attach to one or create a new one
function assessSession() {
  read -p "Choose a Session: " session_number
  enter=$(echo -e "\n")
  if [[ $session_number = $enter ]]; then
    SESSION="n"
  else
    for i in "${UNATTCHED_SESSIONS[@]}"
    do
        if [[ $i = $session_number ]]; then
            SESSION=$session_number
            case "$SESSION" in
            "X")
                SESSION="x"
                ;;
            "N")
                SESSION="n"
                ;;
            *)
                ;;
            esac
        fi
    done
  fi
}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

case $(uname) in
    Darwin)
        MOTD="bash $SCRIPT_DIR/macmotd/motd.sh"
        ;;
    Linux)
        NF=$(which neofetch &> /dev/null && echo $?)
        SF=$(which screenfetch &> /dev/null && echo $?)
        LF=$(ls $SCRIPT_DIR/linmotd/motd.sh &> /dev/null && echo $?)
        if [[ "$LF" == "0" ]]; then
            MOTD="$SCRIPT_DIR/linmotd/motd.sh"
        elif [[ "$NF" == "0" ]]; then
            MOTD="neofetch"
        elif [[ "$SF" == "0" ]]; then
            MOTD="screenfetch"
        else
            MOTD="echo No MOTD setup... Think about installing neofetch, screenfetch or creating a linfetch script"
        fi
        ;;
    *)
        MOTD="Your platform '$(uname)' is not recognised."
        ;;
esac

if [[ $TERM_PROGRAM == "iTerm.app" ]]; then
    if [[ "$(cat $SCRIPT_DIR/tmux_integration)" == "false" ]]; then
        TMUX_CMD="tmux -s $USER"
    else
        TMUX_CMD="tmux -CC -s $USER"
    fi
    ITERM2=TRUE
else
    TMUX_CMD="tmux"
    ITERM2=FALSE
fi

# First check no sessions are runing
tmux ls &> /dev/null
# If this exits with 1, no sessions are running, start a new one
if [[ "$?" == "1" ]]; then
  exec $TMUX_CMD new-session "echo && $MOTD && zsh"
  exit 0
fi

TMUX_SESSIONS=($(tmux ls -F '#{session_name}, #{session_attached}' |grep -v ', 1' |cut -d, -f1))
#If no sessions are available to attach to just create a new one
if [[ ${#TMUX_SESSIONS[@]} == "0" ]]; then
  exec $TMUX_CMD new-session "echo && $MOTD && zsh"
  exit 0
fi
echo "TMUX sessions are availble to attach to:"
tmux ls |grep -v attached
echo " : n or ↵  to start a new session"

UNATTCHED_SESSIONS=($(tmux ls -F '#{session_name}, #{session_attached}' |grep -v ', 1' |cut -d, -f1  && echo "n" && echo "N" && echo "X" && echo "x"))
while [[ -z "$SESSION" ]]
do
  if [[ -n "$LOOPRUN" ]]; then
      echo "Not a valid session number."
  fi
  assessSession "${UNATTCHED_SESSIONS[@]}"
  LOOPRUN=1
done

if [[ "$SESSION" = "n" ]]; then
  exec $TMUX_CMD new-session "echo && $MOTD && zsh"
  exit 0
elif [[ "$SESSION" = "x" ]]; then
  exit 666
else
  exec $TMUX_CMD a -t $SESSION
  exit 0
fi
