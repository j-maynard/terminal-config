if [[ $(uname) == "Linux" ]]; then
    alias vi="nvim"
    alias vim="nvim"
    # Clipboard handling
    alias setclip="xclip -selection c"
    alias getclip="xclip -selection c -o"
    alias pbcopy=setclip
    alias pbpaste=getclip
    #alias xclip="xclip -selection c"
fi
