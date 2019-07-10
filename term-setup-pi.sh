#!/bin/bash
STARTPWD=$(pwd)
cd /tmp
sudo apt-get update
sudo apt-get install -y git zsh python3.7 idle-python3.7 python3.7-dev python3-pip build-essential jed htop links lynx tree tmux maven emacs emacs-gtk vim-nox vim-gtk xfce4 xfce4-goodies xfwm4-theme-breeze xfwm4-themes openjdk-8-jdk ruby ruby-dev most htop
cd /tmp
scp -r jamie@home.nightmares.co.uk:/home/jamie/.ssh ~/
scp jamie@home:/home/jamie/.zshrc ~/
scp jamie@home:/home/jamie/.zsh_plugins.txt ~/
scp jamie@home:/home/jamie/.iterm2_shell_integration.zsh ~/
scp -r jamie@home:/home/jamie/.iterm2 ~/
curl -sL git.io/antibody | sh -s
chsh -s /bin/zsh
pip3 install --user setuptools
pip3 install --user powerline-status
mkdir -p  ~/.config/powerline
cp -r ~/.local/lib/python3.6/site-packages/powerline/config_files/ ~/.config/powerline/
cd /tmp/
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts
# Install Colour Emojis
wget https://github.com/eosrei/twemoji-color-font/releases/download/v12.0.1/TwitterColorEmoji-SVGinOT-Linux-12.0.1.tar.gz
tar zxf TwitterColorEmoji-SVGinOT-Linux-12.0.1.tar.gz
cd TwitterColorEmoji-SVGinOT-Linux-12.0.1
./install.sh
# Install Nerd Font
cd ~/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/Ubuntu.zip
unzip Ubuntu.zip
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
cd /tmp
mkdir -p ~/.config/xfce4/terminal/
scp home:~/.config/xfce4/terminal/terminalrc ~/.config/xfce4/terminal/terminalrc
sudo update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper
cd /tmp
cd $STARTPWD
sudo gem install colorls

# Update LightDM to be of use
sudo sed -i 's/greeter-session=pi-greeter/#greeter-session=pi-greeter\ngreeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf

echo "Update the fonts for your terminal and then restart your shell to fnish"
