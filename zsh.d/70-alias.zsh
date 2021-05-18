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

## get rid of command not found ##
alias cd..='cd ..'
 
## a quick way to get out of current directory ##
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../..'

## Go Home
alias home="cd ${HOME}"

alias untar='tar -zxvf '
alias wget='wget -c '
alias getpass="openssl rand -base64 20"
alias sha='shasum -a 256 '
alias www='python -m SimpleHTTPServer 8000'
alias cls='clear'
alias c='clear'

## GDS Aliases
alias vpn='gds vpn'

## Replace cat with bat
alias cat='bat'
alias cata='bat -A'
alias catp='bat -p'

# JSON output view
alias json='jq -C -r | bat'
