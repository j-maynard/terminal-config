#!/bin/bash
# Stop on error
set -e
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
sudo apt update
sudo apt upgrade -y
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

sudo apt install -y git curl zsh idle-python3.8 python3.8-dev python3-pip \
build-essential jed htop links lynx tree tmux openjdk-11-jdk openjdk-8-jdk \
maven vim vim-nox vim-gtk3 vim-scripts most ruby-dev scdaemon \
pinentry-qt pinentry-tty pinentry-curses

show_msg "Installing ftom snap..."
show_msg "  ┣━> Slack"
show_msg "  ┣━> Visual Studio Code"
show_msg "  ┣━> LSD for ls"
show_msg "  ┣━> Emacs"
show_msg "  ┗━> Insomnia"
sudo snap install slack --classic
sudo snap install code --classic
sudo snap install insomnia
sudo snap install lsd
sudo snap install emacs --classic

cd /tmp
show_msg "Installing Google Chrome (Latest)..."
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb 
rm google-chrome-stable_current_amd64.deb 

show_msg "Installing antibody..."
curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin

show_msg "Changing shells to ZSH... Please enter your passowrd!"
chsh -s /bin/zsh

show_msg "Installing powerline..."
sudo pip3 install setuptools
sudo pip3 install powerline-status
mkdir -p  ~/.config/powerline
cp -r /usr/local/lib/python3.8/dist-packages/powerline/config_files/* ~/.config/powerline/

show_msg "Installing golang..."
wget -q https://dl.google.com/go/go1.11.4.linux-amd64.tar.gz
sudo tar -zxvf /tmp/go1.11.4.linux-amd64.tar.gz --directory /usr/local/
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

show_msg "Installing Jetbrains Toolbox..."
wget -q https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.17.6802.tar.gz
sudo tar -zxvf jetbrains-toolbox-1.17.6802.tar.gz -C /opt
sudo mv /opt/jetbrains-toolbox-1.17.6802 /opt/jetbrains-toolbox
sudo usermod -a -G users $(whoami)
sudo chgrp users /opt/jetbrains-toolbox
sudo chmod 775 /opt/jetbrains-toolbox
/opt/jetbrains-toolbox/jetbrains-toolbox &

if [ -f "/usr/share/sddm/scripts/Xsetup"]; then
    show_msg "SDDM present updating XSetup script..."
    curl -LSs "$GIT_REPO/XSetup.snippet" >> /usr/share/sddm/scripts/Xsetup
fi

show_msg "Running jenv/rbenv setup script..."
bash < curl -LSs "$GIT_REPO/linux-env-setup.sh"

show_msg "Running console fonts setup script..."
bash < curl -LSs "$GIT_REPO/setup-console-font.sh"

cd $STARTPWD

echo -e "Update the fonts for your terminal and then restart your shell to fnish"
echo -e "I recommnd actually restarting your whole system at this point"
