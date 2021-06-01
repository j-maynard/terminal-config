#!/bin/bash

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
    else
        USERNAME=$SUDO_USER
    fi
    if [ $USERNAME == "root" ]; then
        USER_PATH="/root"
    else
        USER_PATH="/home/$USER"
    fi
}

usage() {
    echo -e "Usage:"
    echo -e "  ${bold}${red}-R  --run-as-root${normal}          If running as root in a sudo shell this fixes the home path"
    echo -e "  ${bold}${red}-V  --verbose${normal}              Shows command output for debugging"
    echo -e "  ${bold}${red}-v  --version${normal}              Shows version details and exit"
    echo -e "  ${bold}${red}-h  --help${normal}                 Shows this usage message and exit"
}

version() {
    echo -e "Shim Setup Script Version 0.5"
    echo -e "(c) Jamie Maynard 2020"
}

show_msg() {
    echo -e $1 > /dev/tty
}

install_rbenv() {
  if [ ! -d "${USER_PATH}/.rbenv" ]; then
    show_msg "Setting RBEnv up...."
    git clone $GIT_QUIET https://github.com/rbenv/rbenv.git $USER_PATH/.rbenv
    cd $USER_PATH/.rbenv && src/configure && make -C src
    mkdir -p $USER_PATH/.rbenv/plugins
    git clone -q https://github.com/rbenv/ruby-build.git $USER_PATH/.rbenv/plugins/ruby-build
  fi
}

install_jenv() {
  if [[ $(uname) != "Linux" ]]; then
    return
  fi
  
  if [ ! -d "${USER_PATH}/.jenv" ]; then
    show_msg "Setting JEnv up...."
    git clone $GIT_QUIET https://github.com/gcuisinier/jenv.git $USER_PATH/.jenv
    mkdir $USER_PATH/.jenv/versions
    $USER_PATH/.jenv/bin/jenv add /usr/lib/jvm/java-11-openjdk-amd64
    #Disabling Java8... will remove soon.
    #$USER_PATH/.jenv/bin/jenv add /usr/lib/jvm/java-8-openjdk-amd64
  fi
}

################################
# Main Script body starts here #
################################

# Set default options
VERBOSE=false

# Process commandline arguments
while [ "$1" != "" ]; do
    case $1 in
        R | -R | --run-as-root)     USER=root
                                    SUDO_USER=root
                                    set_username
                                    ;;
        V | -V | --verbose)         VERBOSE=true
                                    ;;
        v | -v | --version)         version
                                    exit 0
                                    ;;
        h | -h | --help)            usage
                                    exit 0
                                    ;;
        * )                         echo -e "Unknown option $1...\n"
                                    usage
                                    exit 1
                                    ;;
    esac
    shift
done

# Silence output
if [ $VERBOSE == "false" ]; then
    echo "Silencing output"
    exec > /dev/null
    GIT_QUIET="-q"
fi

set_username
install_rbenv
install_jenv

