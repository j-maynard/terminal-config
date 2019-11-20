if [[ $TERM_PROGRAM != 'Apple_Terminal' ]]; then;
  export EXIT_SESSION=0
  if [[ -z "$TMUX" ]]; then
    ~/.term-config/tmux-attach.sh
    if [[ "$?" == "0" ]]; then
      echo "Script exited 0"
      exit
    elif [[ "$?" == "666" ]]; then
       "Script exited 666"
      ~/.screenfetch/screenfetch-dev -a ~/.screenfetch/ft.txt
    fi
  fi
fi
