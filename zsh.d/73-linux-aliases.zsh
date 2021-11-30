if [[ $(uname) == "Linux" ]]; then
    # Clipboard handling
    alias setclip="xclip -selection c"
    alias getclip="xclip -selection c -o"
    alias pbcopy=setclip
    alias pbpaste=getclip
    #alias xclip="xclip -selection c"
    alias plasma-reset="kquitapp5 plasmashell && kstart5 plasmashell"
    alias resetcam="sudo modprobe -r v4l2loopback && sudo modprobe v4l2loopback"
    alias camreset=resetcam
fi
