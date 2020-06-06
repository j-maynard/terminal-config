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
    echo -e "  -m  --model              Takes the mdel string output by neofetch/screenfetch"
    echo -e "  -V  --verbose            Shows command output for debugging"
    echo -e "  -v  --version            Shows version details"
    echo -e "  -h  --help               Shows this usage message"
}

version() {
    echo -e "Raspbian Setup Script Version 0.5"
    echo -e "(c) Jamie Maynard 2020"
}

SILENT='>/dev/null'
PRIVATE=false
while [ "$1" != "" ]; do
    case $1 in
        -m | --model)           shift
                                MODEL=$1
                                ;;
        -w | --wsl-user)        shift
                                # Rasbian doesn't run in WSL.  Skipping...
                                ;;
        -V | --verbose)         SILENT=""
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

echo -e "Updating the system..."
sudo apt update $SILENT
sudo apt upgrade $SILENT
echo -e "Installing from apt... "
echo -e "  ┣━━━━━━━━━━━━━━┓"
echo -e "  ┣━> git        ┣━> curl"
echo -e "  ┣━> idle3      ┣━> pip3"
echo -e "  ┣━> zsh        ┣━> jed"
echo -e "  ┣━> htop       ┣━> most"
echo -e "  ┣━> tree       ┣━> tmux"
echo -e "  ┣━> lynx       ┣━> links"
echo -e "  ┣━> htop       ┣━> vim"
echo -e "  ┣━> openjdk 8  ┣━> openjdk 11"
echo -e "  ┣━> maven      ┣━> gnupg"
echo -e "  ┗━> pinentry   ┗━>scdaemon"

BASE_PACKAGES="git curl zsh python3.7-dev python3-pip \
build-essential jed htop links lynx tree tmux \
maven vim vim-nox vim-scripts most ruby-dev gnupg scdaemon \
pinentry-qt pinentry-tty pinentry-curses"

NOX_PACKAGES="openjdk-11-jdk openjdk-8-jdk"

X_PACKAGES="vim-gtk3 xfce4 xserver-xephyr thunar-archive-plugin \ 
thunar-media-tags-plugin gtk3-engines-xfce xfce4-goodies \
xfce4-power-manager xfwm4-themes xfce4-indicator-plugin \
xfce4-mpc-plugin xfce4-radio-plugin"

MODEL=$(echo "$MODEL" | tr '[:upper:]' '[:lower:]')
if [[ $MODEL =~ "zero" ]]; then
    X_PACKAGES=""
fi
sudo apt install $BASE_PACKAGES $NOX_PACKAGES $X_PACKAGES $SILENT

# echo -e "Installing ftom snap..."
# echo -e "  ┣━> Slack"
# echo -e "  ┣━> Visual Studio Code"
# echo -e "  ┣━> LSD for ls"
# echo -e "  ┣━> Emacs"
# echo -e "  ┗━> Insomnia"
# sudo snap install slack --classic $SILENT
# sudo snap install code --classic $SILENT
# sudo snap install insomnia $SILENT
# sudo snap install lsd $SILENT
# sudo snap install emacs --classic $SILENT

echo -e "Installing antibody..."
curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin $SILENT

echo -e "Changing shells to ZSH... Please enter your passowrd!"
chsh -s /bin/zsh

echo -e "Installing powerline..."
sudo pip3 install setuptools $SILENT
sudo pip3 install powerline-status $SILENT
mkdir -p  ~/.config/powerline $SILENT
cp -r /usr/local/lib/python3.8/dist-packages/powerline/config_files/* ~/.config/powerline/ $SILENT

echo -e "Installing golang..."
wget https://dl.google.com/go/go1.14.2.linux-arm64.tar.gz $SILENT
sudo tar -zxvf /tmp/go1.14.2.linux-arm64.tar.gz --directory /usr/local/ $SILENT
if [[ -f "/usr/local/bin/go" ]]; then
    sudo rm /usr/local/bin/go $SILENT
fi
if [[ -f "/usr/local/bin/godoc" ]]; then
    sudo rm /usr/local/bin/godoc $SILENT
fi
if [[ -f "/usr/local/bin/gofmt" ]]; then
    sudo rm /usr/local/bin/gofmt $SILENT
fi
sudo ln -s /usr/local/go/bin/go /usr/local/bin/go $SILENT
sudo ln -s /usr/local/go/bin/godoc /usr/local/bin/godoc $SILENT
sudo ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt $SILENT

echo -e "Installing rust and lsd... "
curl https://sh.rustup.rs -sSf | sh -s --  \
    --default-toolchain nightly-2020-04-07 \
    --component llvm-tools-preview rustfmt $SILENT

source $HOME/.cargo/env $SILENT
rustup target add aarch64-unknown-none-softfloat $SILENT
cargo install cargo-binutils $SILENT
cargo install lsd $SILENT

# Update LightDM to be of use
sudo sed -i 's/greeter-session=pi-greeter/#greeter-session=pi-greeter\ngreeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf

echo -e "Running jenv/rbenv setup script..."
bash < curl -LSs "$GIT_REPO/linux-env-setup.sh"

echo -e "Running console fonts setup script..."
bash < curl -LSs "$GIT_REPO/setup-console-font.sh"

cd $STARTPWD
echo -e "Update the fonts for your terminal and then restart your shell to fnish"
echo -e "I recommnd actually restarting your whole system at this point"
