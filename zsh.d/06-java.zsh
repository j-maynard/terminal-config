#!/bin/zsh
which java > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    java11
fi
