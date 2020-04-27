#!/bin/bash
STARTPWD=$(pwd)

SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`

if [ -z $GIT_REPO ]; then
    GIT_REPO="https://raw.githubusercontent.com/j-maynard/terminal-config/master"
fi

# Define colors and styles
normal="\033[0m"
bold="\033[1m"
green="\e[32m"
red="\e[31m"
yellow="\e[93m"

usage() {
    echo -e "Usage:"
    echo -e "  -V  --verbose            Shows command output for debugging"
    echo -e "  -v  --version            Shows version details"
    echo -e "  -h  --help               Shows this usage message"
}

version() {
    echo -e "Ubuntu Setup Script Version 0.5"
    echo -e "(c) Jamie Maynard 2020"
}

show_msg() {
    echo -e $1 > /dev/tty
}

snap_install() {
    exec > /dev/tty
    show_msg "Installing ftom snap..."
    show_msg "  ┣━> Slack"
    show_msg "  ┣━> Spotify"
    show_msg "  ┣━> Visual Studio Code"
    show_msg "  ┣━> LSD for ls"
    show_msg "  ┣━> Emacs"
    show_msg "  ┗━> Insomnia"

    which slack
    if [ $? != 0 ]; then
        sudo snap install slack --classic
    fi
    which spotify
    if [ $? != 0 ]; then
        sudo snap install spotify --classic
    fi
    which code
    if [ $? != 0 ]; then
        sudo snap install code --classic
    fi
    which insomnia
    if [ $? != 0 ]; then
        sudo snap install insomnia
    fi
    which lsd
    if [ $? != 0 ]; then
        sudo snap install lsd --devmode
    fi
    which emacs
    if [ $? != 0 ]; then
        sudo snap install emacs --classic
    fi
    if [ $VERBOSE == "false" ]; then
        exec > /dev/null 
    fi
}

VERBOSE=false
PRIVATE=false
while [ "$1" != "" ]; do
    case $1 in
        -V | --verbose)         VERBOSE=true
                                ;;
        -v | --version)         version
                                exit 0
                                ;;
        -h | --help)            usage
                                exit 0
                                ;;
        * )                     echo -e "Unknown option $1...\n"
                                usage
                                exit 1
                                ;;
    esac
    shift
done

if [ $VERBOSE == "false" ]; then
    echo "Silencing output"
    exec > /dev/null 
fi

show_msg "Updating the system..."
sudo apt-get update
sudo apt-get upgrade -y
show_msg "Installing from apt... "
show_msg "  ┣━━━━━━━━━━━━━━┓"
show_msg "  ┣━> git        ┣━> curl"
show_msg "  ┣━> idle3      ┣━> pip3"
show_msg "  ┣━> zsh        ┣━> jed"
show_msg "  ┣━> htop       ┣━> most"
show_msg "  ┣━> tree       ┣━> tmux"
show_msg "  ┣━> lynx       ┣━> links"
show_msg "  ┣━> htop       ┣━> vim"
show_msg "  ┣━> openjdk 8  ┣━> openjdk 11"
show_msg "  ┣━> maven      ┗━> pinentry"
show_msg "  ┗━> scdaemon"

sudo apt-get install -y git curl zsh idle-python3.8 python3.8-dev python3-pip \
build-essential jed htop links lynx tree tmux openjdk-11-jdk openjdk-8-jdk \
maven vim vim-nox vim-gtk3 vim-scripts most ruby-dev scdaemon \
pinentry-qt pinentry-tty pinentry-curses libappindicator3-1

exec > /dev/tty 
echo ""
while true; do
    read -p "Snap currently takes forever to install anything... You sure you want to install stuff? [Yes/No/Y/y/N/n] " yn
    case $yn in
        [Yy]* )   snap_install
                  break
                  ;;
        [Nn]* )   break
                  ;;
        * )       echo "Please answer yes or no."
                  ;;
    esac
done
if [ $VERBOSE == "false" ]; then
  exec > /dev/null
fi

cd /tmp
which google-chrome
if [ $? != 0 ]; then
    show_msg "Installing Google Chrome (Latest)..."
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb 
    rm google-chrome-stable_current_amd64.deb 
fi

which antibody
if [ $? != 0 ]; then
    show_msg "Installing antibody..."
    curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin
fi

show_msg "Changing shells to ZSH... Please enter your passowrd!"
if [[ $(awk -F: '/jamie/ { print $7}' /etc/passwd) != "/bin/zsh" ]]; then
    chsh -s /bin/zsh
fi

show_msg "Installing powerline..."
sudo pip3 install setuptools
sudo pip3 install powerline-status
mkdir -p  ~/.config/powerline
cp -r /usr/local/lib/python3.8/dist-packages/powerline/config_files/* ~/.config/powerline/

which go
if [ $? != 0 ]; then
    show_msg "Installing golang..."
    wget -q https://dl.google.com/go/go1.11.4.linux-amd64.tar.gz
    sudo tar -zxvf /tmp/go1.11.4.linux-amd64.tar.gz --directory /usr/local/
    rm go1.11.4.linux-amd64.tar.gz
    if [[ -f "/usr/local/bin/go" ]]; then
        sudo rm /usr/local/bin/go
    fi
    if [[ -f "/usr/local/bin/godoc" ]]; then
        sudo rm /usr/local/bin/godoc
    fi
    if [[ -f "/usr/local/bin/gofmt" ]]; then
        sudo rm /usr/local/bin/gofmt
    fi
    sudo ln -s /usr/local/go/bin/go /usr/local/bin/go
    sudo ln -s /usr/local/go/bin/godoc /usr/local/bin/godoc
    sudo ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt
fi

if [[ ! -f "/opt/jetbrains-toolbox/jetbrains-toolbox" ]]; then
    show_msg "Installing Jetbrains Toolbox..."
    cd /tmp
    wget -q https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.17.6802.tar.gz
    tar -zxvf jetbrains-toolbox-1.17.6802.tar.gz
    sudo mkdir -p /opt/jetbrains-toolbox
    sudo mv ./jetbrains-toolbox-1.17.6802/jetbrains-toolbox /opt/jetbrains-toolbox/jetbrains-toolbox
    rm -rf /tmp/jetbrains-toolbox-1.17.6802
    sudo usermod -a -G users $(whoami)
    sudo chgrp -R users /opt/jetbrains-toolbox
    sudo chmod -R 775 /opt/jetbrains-toolbox
    /opt/jetbrains-toolbox/jetbrains-toolbox > /dev/null 2&>1 &
fi

if [[ -f "/usr/share/sddm/scripts/Xsetup" ]]; then
    show_msg "SDDM present"
    grep term-config /usr/share/sddm/scripts/Xsetup
    if [ $? != 0 ]; then
        show_msg "Updating SDDM XSetup script..."
        curl -LSs "$GIT_REPO/Xsetup.snippet" | sudo tee -a /usr/share/sddm/scripts/Xsetup
    fi
fi

show_msg "Linking /usr/bin/python3 to /usr/bin/python..."
sudo ln -s /usr/bin/python3 /usr/bin/python

show_msg "Running jenv/rbenv setup script..."
curl -LSs "$GIT_REPO/linux-env-setup.sh" | bash

show_msg "Running console fonts setup script..."
curl -LSs "$GIT_REPO/console-font-setup.sh" | bash

cd $STARTPWD

echo -e "Update the fonts for your terminal and then restart your shell to fnish"
echo -e "I recommnd actually restarting your whole system at this point"
