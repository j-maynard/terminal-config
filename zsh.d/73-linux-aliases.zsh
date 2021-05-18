if [[ $(uname) == "Linux" ]]; then
    # Clipboard handling
    alias setclip="xclip -selection c"
    alias getclip="xclip -selection c -o"
    alias pbcopy=setclip
    alias pbpaste=getclip
    #alias xclip="xclip -selection c"
    alias vpn="gds vpn"
    alias plasma-reset="kquitapp5 plasmashell && kstart5 plasmashell"
fi
