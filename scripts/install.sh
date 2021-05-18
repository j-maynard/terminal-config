#!/bin/bash
# Stop on error
STARTPWD=$(pwd)

SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`

# Define colors and styles
normal="\033[0m"
bold="\033[1m"
green="\e[32m"
red="\e[31m"
yellow="\e[93m"

set_username() {
    if [ -z $SUDO_USER ]; then
        USERNAME=$USER
        WSL_USER=$USER
    else
        USERNAME=$SUDO_USER
    fi
    if [ $USERNAME == "root" ]; then
        if [[ -v WSLENV && ! -v WSL_USER ]]; then
            show_msg "WSL Username not set... Exiting!"
            exec > /dev/tty
            usage
            exit 1
        fi
        USER_PATH="/root"
    else
        USER_PATH="/home/$USER"
    fi
    if [ ! -v WSL_USER ]; then
        WSL_USER=$USERNAME
    fi
}

export GIT_REPO="https://raw.githubusercontent.com/j-maynard/terminal-config/main/scripts"

usage() {
    echo -e "Usage:"
    echo -e "  ${bold}${red}-w  --wsl-user [username]${normal}    Sets the Windows username which runs WSL.  This is used to find the windows"
    echo -e "                               users home directory. If not specified it matches it to the linux username."
    echo -e "                               If you run this script as root then you ${bold}MUST${normal} specify this."
    echo -e "  ${bold}${red}-t  --theme-only${normal}             Don't install anything just setup terminal"
    echo -e "  ${bold}${red}-c  --commandline-only${normal}       Don't install GUI/X components"
    echo -e "  ${bold}${red}-s  --streaming${normal}              Install OBS Studio and related components (Ubuntu Only)"
    echo -e "  ${bold}${red}-o  --virtual-box${normal}            Installs VirtualBox (Ubuntu Only)"
    echo -e "  ${bold}${red}-g  --nogames${normal}                Prevents installing games this includes Stream and Minecraft (Ubuntu Only)"
    echo -e "  ${bold}${red}-p  --private-script${normal}         Run private scripts (These are encrypted)"
    echo -e "  ${bold}${red}-V  --verbose${normal}                Shows command output for debugging"
    echo -e "  ${bold}${red}-v  --version${normal}                Shows version details"
    echo -e "  ${bold}${red}-h  --help${normal}                   Shows this usage message"
}

version() {
    echo "Shared Setup Script Version 0.5"
    echo "(c) Jamie Maynard 2020"
}

show_msg() {
    echo -e $1 > /dev/tty
}

get_file() {
    APP=$1
    FILE=$2
    URL=$3
    echo $1 $2 $3
    if [[ $APP == "wget" ]]; then
        wget -q -O $FILE $URL
    elif [[ $APP == "curl" ]]; then
        curl -LSso $FILE $URL
    else
        show_msg "No curl or wget... value of APP = '${APP}'... Exiting..."
        exit 1
    fi
}

os_script() {
    GET=$1
    OS=$2
    MODEL=$3
    show_msg "Getting OS/Distro setup script for '${OS}' from git"
    cd /tmp
    get_file $GET "${OS}-setup.sh" "$GIT_REPO/${OS}-setup.sh?$(date +%s)"
    chmod +x ${OS}-setup.sh
    exec > /dev/tty
    if [[ $OS == "ubuntu" && $STREAMING == "true" ]]; then
        SARGS="-s"
    fi
    if [[ $OS == "ubuntu" && $VM == "true" ]]; then
        VMARGS="-o"
    fi
    if [[ $OS == "ubuntu" && $GAMES == "false" ]]; then
        GARGS="-g"
    fi
    
    echo "Running OS/Distro setup script"
    ./${OS}-setup.sh $MODEL $VARG $CARG $WSLARG $SARGS $NEON_FLAG $GARGS $VMARGS
    rm ${OS}-setup.sh
    if [ $VERBOSE == "false" ]; then
        exec > /dev/null
    fi
}

theme_only() {
    if [ $THEME_ONLY == 'false' ]; then
        return
    fi
    which git > /dev/null
    if [[ $? != 0 ]]; then
        show_msg "${red}This script requries ${bold}git${normal}${red} to run...  Exiting...${normal}"
        exit 1
    fi

    which curl > /dev/null
    if [[ $? != 0 ]]; then
        show_msg "${red}This script requries ${bold}curl${normal}${red} to run...  Exiting...${normal}"
        exit 1
    fi
}

setup_os() {
    if [ $THEME_ONLY == 'true' ]; then
        return
    fi

    #Begin OS Detection
    which wget
    if [[ $? == 0 ]]; then
        GET="wget"
    else
        which curl
        if [[ $? == 0 ]]; then
            GET="curl"
        else
            
            which apt
            if [[ $? == 0 ]]; then
                show_msg "No curl or wget... installing wget via apt"
                sudo apt update > /dev/null
                sudo apt-install wget > /dev/null
                GET="wget"
            fi
            
            which brew
            if [[ $? == 0 ]]; then
                show_msg "No curl or wget... installing wget via brew"
                brew install wget
                GET="wget"
            fi
        fi
    fi
    

    if [ -z "$GET" ]; then
        show_msg "No curl or wget... or error in the logic... Exiting..."
        exit 1
    fi

    cd /tmp
    get_file $GET "neofetch" "https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch"
    OS=$(bash /tmp/neofetch func_name os | cut -d ':' -f 2 | awk '{$1=$1};1')
    DISTRO=$(bash /tmp/neofetch func_name distro | cut -d ':' -f 2 | cut -d ' ' -f 2 | awk '{$1=$1};1')
    MODEL=$(bash /tmp/neofetch func_name distro | cut -d ':' -f 2)
    rm /tmp/neofetch
    
    case $OS in
        Linux)      case $DISTRO in
                        *buntu)         os_script $GET "ubuntu"
                                        ;;
                        KDE | Neon)     NEON_FLAG=-n
                                        os_script $GET "ubuntu"
                                        ;;
                        *)              show_msg "Unknown Linux distribution.  Consider writing an OS/Distro install script.  Exiting..."
                                        exit 1
                                        ;;
                    esac
                    ;;
        Darwin)     os_script $GET "mac"
                    ;;
        *)          show_msg "Unknown operating system.  Consider writing an OS/Distro install script.  Exiting..."
                    exit 1
                    ;;
    esac
}

setup_config() {
    if [[ -d "${USER_PATH}/terminal-config" ]]; then
        mv "${USER_PATH}/terminal-config" "${USER_PATH}/.term-config"
    
    elif [ ! -d "${USER_PATH}/.term-config" ]; then
        show_msg "Terminal Config not present, retrrieving from github"
        git clone $GIT_QUIET https://github.com/j-maynard/terminal-config.git "${USER_PATH}/.term-config"
    fi

    show_msg "Running config script at '${USER_PATH}/.term-config/config-setup.sh'..."
    
    exec > /dev/tty
    $USER_PATH/.term-config/scripts/config-setup.sh $VARG
    if [ $VERBOSE == "false" ]; then
        exec > /dev/null
    fi
}

tmp_gpg_agent_conf() {
    if [ ! -d "${USER_PATH}/.gnupg" ]; then
        mkdir -p "${USER_PATH}/.gnupg"
        chmod 700 ${USER_PATH}/.gnupg
    fi
    cat << EOF > "${USER_PATH}/.gnupg/gpg-agent.conf"
pinentry-program "/usr/bin/pinentry-curses"
default-cache-ttl 60
max-cache-ttl 120
EOF
    if ps -C gpg-agnet &> /dev/null; then
        sudo killall -s 9 gpg-agent
    fi
    /usr/bin/gpg-agent -q --daemon
}

setup_git() {
    echo "Please supply your git user details:"
    read -p "Name: " NAME
    read -p "E-Mail:" EMAIL
    git config --global user.name "${NAME}"
    git config --global user.email "${EMAIL}"
}

private_setup() {
    if [ $PRIVATE != "true" ]; then
        setup_git
        return
    fi

    tmp_gpg_agent_conf
    show_msg "Running private setup script..."
    show_msg "DEBUG: Running: source < (gpg -d -q ${USER_PATH}/.term-config/encrypted/private-setup.gpg)"
    exec > /dev/tty
    eval "$(gpg -d -q ${USER_PATH}/.term-config/encrypted/private-setup.gpg)"
    show_msg "Running git setup script..."
    ${USER_PATH}/.term-config/scripts/git-setup.sh
    if [ $VERBOSE == "false" ]; then
        exec > /dev/null
    fi
}

################################
# Main script body starts here #
################################

# Set default options
THEME_ONLY=false
COMMANDLINE_ONLY=false
VERBOSE=false
PRIVATE=false
STREAMING=false
GAMES=true
VM=false

# Process commandline arguments
while [ "$1" != "" ]; do
    case $1 in
        t | -t | --theme-only)          THEME_ONLY=true
                                        ;;
        c | -c | --commandline-only)    COMMANDLINE_ONLY=true
                                        CARG="-c"
                                        ;;
        s | -s | --streaming)           STREAMING=true
                                        ;;
        w | -w | --wsl-user)            shift
                                        if [[ $1 =~ ^-.* ]]; then
                                            continue
                                        fi
                                        WSL_USER=$1
                                        WSLARG="-w ${WSL_USER}"
                                        ;;
        o | -o | --virtualbox)          VM=true
                                        ;;
        g | -g | --no-games)            GAMES=false
                                        ;;
        p | -p | --private-script)      PRIVATE=true
                                        ;;
        V | -V | --verbose)             VERBOSE=true
                                        VARG="-V"
                                        ;;
        v | -v | --version)             version
                                        exit
                                        ;;
        h | -h | --help)                usage
                                        exit 0
                                        ;;
        * )                             echo -e "Unknown option $1...\n"
                                        usage
                                        exit 1
    esac
    shift
done

# Silence output
if [ $VERBOSE == "false" ]; then
    echo "Silencing output"
    exec > /dev/null 
fi

set_username
theme_only
setup_os
setup_config
private_setup

unset GIT_REPO
show_msg "${green}Install Script has finished running... You should probably reboot"
cd $STARTPWD
