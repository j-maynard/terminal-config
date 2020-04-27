#!/bin/bash
# Stop on error
set -e
STARTPWD=$(pwd)

SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`

# Define colors and styles
normal="\033[0m"
bold="\033[1m"
green="\e[32m"
red="\e[31m"
yellow="\e[93m"

export GIT_REPO="https://raw.githubusercontent.com/j-maynard/terminal-config/master"

usage() {
    echo -e "Usage:"
    echo -e "  -p  --private-script     Run private scripts (These are encrypted)"
    echo -e "  -V  --verbose            Shows command output for debugging"
    echo -e "  -v  --version            Shows version details"
    echo -e "  -h  --help               Shows this usage message"
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
        wget -q $URL
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
    get_file $GET "${OS}-setup.sh" "$GIT_REPO/${OS}-setup.sh"
    chmod +x ${OS}-setup.sh
    exec > /dev/tty
    echo "Running OS/Distro setup script"
    ./${OS}-setup.sh $MODEL
    rm ${OS}-setup.sh
    if [ $VERBOSE == "false" ]; then
        exec > /dev/null
    fi
}

config_script() {
    CONFIG_SCRIPT_PATH=$1
    show_msg "Running config script at ${CONFIG_SCRIPT_PATH}/config-setup.sh..."
    exec > /dev/tty
    cd $HOME
    $HOME/$CONFIG_SCRIPT_PATH/config-setup.sh
    if [ $VERBOSE == "false" ]; then
        exec > /dev/null
    fi
}

termsetup() {
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
                        Ubuntu | Neon)  os_script $GET "ubuntu"
                                        ;;
                        Raspbian)       os_script $GET "raspbian" $MODEL
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


VERBOSE=false
PRIVATE=false
while [ "$1" != "" ]; do
    case $1 in
        -p | --private-script)  PRIVATE=true
                                ;;
        -V | --verbose)         VERBOSE=true
                                ;;
        -v | --version)         version
                                exit
                                ;;
        * )                     echo -e "Unknown option $1...\n"
                                usage
                                exit 1
    esac
    shift
done

if [ $VERBOSE == "false" ]; then
    echo "Silencing output"
    exec > /dev/null 
fi

termsetup

cd $HOME
if [[ -d "${HOME}/terminal-config" ]]; then
    config_script "terminal-config"
elif [[ -d "${HOME}/.term-config" ]]; then
    config_script ".term-config"
else
    show_msg "Terminal Config not present, retrrieving from github"
    git clone https://github.com/j-maynard/terminal-config.git
    config_script "terminal-config"
fi

if [ $PRIVATE == "true" ]; then
    show_msg "Running private setup script..."
    source <(gpg -d -q ${HOME}/.term-config/encrypted/private-setup.gpg)
    show_msg "Running git setup script..."
    ~/.term-config/git-setup.sh
    if [ $VERBOSE == "false" ]; then
        exec > /dev/null
    fi
fi

show_msg "Install NerdFonts..."
git clone -q https://github.com/powerline/fonts.git --depth=1
sudo ./fonts/install.sh
rm -rf fonts

unset GIT_REPO
cd $STARTPWD
