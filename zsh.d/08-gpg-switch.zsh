#!/bin/zsh
switch_gpg_home() {
    if echo $GNUPGHOME | grep usba; then
        export GNUPGHOME=/home/jamesmaynard/.gnupg-usbc
    else
        export GNUPGHOME=/home/jamesmaynard/.gnupg-usba
    fi
}
alias switch-yubikey=switch_gpg_home
