alias cdev="cd $DEVDIR"
alias findoccurances="grep -rnw ./ -e"
alias findinfolder="grep -rnwl ./ -e"
alias findi=findinfolder
alias findo=findoccurances
if [[ $(uname) == 'Linux' ]]; then
    alias xopen='xdg-open'
fi
