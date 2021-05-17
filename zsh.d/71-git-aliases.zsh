#!/bin/zsh
# Git aliases
which git > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    alias ga='git add'
    alias gc='git commit'
    alias commit='git commit'
    alias gr='git rm --cache'
    alias gi='git init'
    alias clone='git clone'
    alias gclone='git clone'
    alias greset='git reset'
    alias glog='git log'
    alias gdiff='git diff'
    alias gstat='git status'
    alias push='git push'
    alias pull='git pull'
    alias groot='groot=$(git rev-parse --show-toplevel);cd $groot'
    alias checkout='git checkout'
    alias force-push='git commit --amend --no-edit && git push -f'
    alias fp='force-push'
    alias push-new="git push --set-upstream origin \$(git branch | grep '*' | cut -d ' ' -f 2)"
fi
