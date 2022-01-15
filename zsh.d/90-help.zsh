#!/bin/zsh
show_help() {
    ALIASES="$(tput bold)Aliases$(tput sgr0)"
    COMMANDS="$(tput bold)Commands$(tput sgr0)"
    PAD=10
    
    while read l; do
        type=$(echo $l | cut -d ':' -f 1)
        cmd=$(echo $l | cut -d ':' -f 2)
        if [[ $type == 'a' || $type == 'c' ]]; then
            if [ ${#cmd} -gt $PAD ]; then
                PAD=${#cmd}
            fi
        fi
    done<~/.term-config/useful-commands.txt
    PAD=$((PAD+5))
    while read l; do
        type=$(echo $l | cut -d ':' -f 1)
        cmd=$(echo $l | cut -d ':' -f 2)
        txt=$(echo $l | cut -d ':' -f 3)
        if [[ $type == 'a' ]]; then
            ALIASES="$ALIASES\n$(tput setaf 1)${(r:PAD:)cmd}$(tput sgr0)$(tput setaf 2)$txt$(tput sgr0)"
        elif [[ $type == 'c' ]]; then
            COMMANDS="$COMMANDS\n$(tput setaf 1)${(r:PAD:)cmd}$(tput sgr0)$(tput setaf 2)$txt$(tput sgr0)"
        else
            continue
        fi
    done<~/.term-config/useful-commands.txt
    echo "$ALIASES\n\n$COMMANDS"
}

add_help_alias_usage() {
    echo "Add help alias usage"
}

add_help_alias() {
    while [ "$1" != "" ]; do
        case $1 in
            -c | --command)				    shift
                                            COMMAND=$1
                                            ;;
            -t | --text)                    shift
                                            TEXT=$1
                                            ;;
            -h | --help)                    add_help_alias_usage
                                            return 0
                                            ;;
            * )                         	echo -e "Unknown option $1...\n"
                                            add_help_alias_usage
                                            return 1
                                            ;;
        esac
        shift
    done

    echo "a:${COMMAND}:${TEXT}">>~/.term-config/useful-commands.txt
}

add_help_command() {
    while [ "$1" != "" ]; do
        case $1 in
            -c | --command)				    shift
                                            COMMAND=$1
                                            ;;
            -t | --text)                    shift
                                            TEXT=$1
                                            ;;
            -h | --help)                    add_help_alias_usage
                                            return 0
                                            ;;
            * )                         	echo -e "Unknown option $1...\n"
                                            add_help_alias_usage
                                            return 1
                                            ;;
        esac
        shift
    done

    echo "c:${COMMAND}:${TEXT}">>~/.term-config/useful-commands.txt
}

alias help=show_help
echo ""