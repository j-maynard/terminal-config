alias cdev="cd $DEVDIR"
alias findoccurances="grep -rnw ./ -e"
alias findinfolder="grep -rnwl ./ -e"
alias findi=findinfolder
alias findo=findoccurances
if [[ $(uname) == 'Linux' ]]; then
    alias xopen='xdg-open'
fi
 if [[ -v WSLENV ]]; then
    alias wingpg='${HOME}/.term-config/wingpg-connect.sh &'
fi
alias genairlinetmuxconf='nvim -c "+:Tmuxline" "+TmuxlineSnapshot ~/.term-config/tmux-airline.conf" "+q"'
