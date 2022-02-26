#!/bin/zsh
which java > /dev/null 2>&1
if [[ $? > 0 ]]; then
    return
fi

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
alias java11='jenv global 11.0'
alias java17='jenv global 17.0'