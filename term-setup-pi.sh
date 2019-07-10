#!/bin/bash

# Stop on error
set -e

if [[ "$HOME/.term-config-run.lock" ]]; then
    echo "Terminal configuration script has already run.  Exiting..."
    exit 0
fi

# Record start directory to return here later
STARTPWD=$(pwd)

# Start in temp 
cd /tmp

# Update apt cache and upgrade packages and finally install our stuff
sudo apt update --allow-releaseinfo-change
sudo apt-get update
sudo apt-get install -y git zsh python3.7 idle-python3.7 python3.7-dev python3-pip build-essential jed htop links lynx tree tmux maven emacs emacs-gtk vim-nox vim-gtk xfce4 xfce4-goodies xfwm4-theme-breeze xfwm4-themes openjdk-8-jdk ruby ruby-dev most htop
sudo apt clean

# Copy SSH Keys from server
scp -r jamie@home.nightmares.co.uk:/home/jamie/.ssh ~/

# Install antibody
curl -sL git.io/antibody | sh -s
sudo mv ./bin/antibody /usr/local/bin/antibody
rm -r ./bin

# Set shell to ZSH
chsh -s /bin/zsh

# Run setup script for terminal config
~/terminal-config/setup.sh

# Install powerline for vim
pip3 install --user setuptools
pip3 install --user powerline-status
mkdir -p  ~/.config/powerline
cp -r ~/.local/lib/python3.6/site-packages/powerline/config_files/ ~/.config/powerline/

cd /tmp/

# Install Colour Emojis
mkdir ~/.fonts
wget https://noto-website.storage.googleapis.com/pkgs/NotoColorEmoji-unhinted.zip
cd ~/fonts
unzip /tmp/NotoColorEmoji-unhinted.zip
rm LICENSE_OFL.txt README
mkdir -p ~/.config/fontconfig/
cp ~/.term-config/font-config.xml ~/.config/fontconfig/fonts.conf
fc-cache -fv

# Install Nerd Font
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/Ubuntu.zip
unzip Ubuntu.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/UbuntuMono.zip
unzip UbuntuMono.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/SourceCodePro.zip
unzip SourceCodePro.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/Terminus.zip
unzip Terminus.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/OpenDyslexic.zip
unzip OpenDyslexic.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/DejaVuSansMono.zip
unzip DejaVuSansMono.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/DroidSansMono.zip
unzip DroidSansMono.zip
sudo fc-cache -fv
fc-cache -fv

cd /tmp
mkdir -p ~/.config/xfce4/terminal/
scp home:~/.config/xfce4/terminal/terminalrc ~/.config/xfce4/terminal/terminalrc
sudo update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper

cd $STARTPWD
sudo gem install colorls

git clone https://github.com/gcuisinier/jenv.git ~/.jenv

# Update LightDM to be of use
sudo sed -i 's/greeter-session=pi-greeter/#greeter-session=pi-greeter\ngreeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf

# Make sure to update the git url for term-setup to be SSH
cd ~/.term-config
git remote set-url origin git@github.com:j-maynard/terminal-config.git

cd $STARTPWD

tocuh "$HOME/.term-config-run.lock"
echo "Update the fonts for your terminal and then restart your shell to fnish"
