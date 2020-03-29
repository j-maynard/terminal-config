#!/bin/bash
STARTPWD=$(pwd)
sudo apt-get update
sudo apt-get install -y git zsh python3.8 idle-python3.8 python3.8-dev python3-pip build-essential jed htop links lynx tree tmux openjdk-11-jdk openjdk-8-jdk maven emacs26 vim-nox vim-gtk vim-gnome
chsh -s /bin/zsh
git clone https://github.com/gcuisinier/jenv.git ~/.jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

jenv add /usr/lib/jvm/java-11-openjdk-amd64
jenv add /usr/lib/jvm/java-8-openjdk-amd64

pip3 install --user setuptools
pip3 install --user powerline-status
mkdir -p  ~/.config/powerline
cp -r ~/.local/lib/python3.8/site-packages/powerline/config_files/ ~/.config/powerline/
curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin
echo "Installing Nerd Font... this may take a while"
git clone --depth 1 git@github.com:ryanoasis/nerd-fonts.git
/tmp/nerd-fonts/install.sh
cd $STARTPWD
echo "Update the fonts for your terminal and then restart your shell to fnish"
echo "Now run the setup script"