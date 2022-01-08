#!/bin/zsh
if which op > /dev/null; then
    eval "$(op completion zsh)"; compdef _op op
fi