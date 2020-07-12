#!/bin/zsh
#####
## Autorun for the gpg-relay bridge
##
USERNAME=${(C)USER}
#USERNAME="${USER^}"
SOCAT_PID_FILE=$HOME/.term-config/wingpg/socat-gpg.pid
NPIPERELAY="/mnt/c/Users/${USERNAME}/AppData/Roaming/gnupg/npiperelay.exe"

if [[ -f $SOCAT_PID_FILE ]] && kill -0 $(cat $SOCAT_PID_FILE) >/dev/null 2>&1; then
   : # already running
else
    rm -f "$HOME/.gnupg/S.gpg-agent"
    (trap "rm $SOCAT_PID_FILE" EXIT; socat UNIX-LISTEN:"$HOME/.gnupg/S.gpg-agent,fork" EXEC:"$NPIPERELAY -ei -ep -s -a \"C:/Users/$USERNAME/AppData/Roaming/gnupg/S.gpg-agent\"",nofork </dev/null &>/dev/null) &
    echo $! >$SOCAT_PID_FILE
fi
