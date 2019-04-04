#!/bin/bash
STARTPWD=$(pwd)
cd /tmp
wget https://go.microsoft.com/fwlink/?LinkID=760868 -O vscode-current.deb
sudo dpkg -i vscode-current.deb
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb:
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo add-apt-repository ppa:kelleyk/emacs
sudo apt-get update
sudo apt-get install -y git zsh python3.7 idle-python3.7 python3.7-dev python3-pip build-essential jed htop links lynx tree tmux openjdk-11-jdk maven emacs26 vim-nox vim-gtk vim-gnome xfce4-terminal
https://downloads.slack-edge.com/linux_releases/slack-desktop-3.3.7-amd64.deb
dpkg -i slack-desktop-3.3.7-amd64.deb
cd /tmp
wget https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz
sudo tar -zxvf openjdk-11.0.1_linux-x64_bin.tar.gz --directory /usr/lib/jvm/
sudo sh -c 'for bin in /usr/lib/jvm/jdk-11.0.1/bin/*; do update-alternatives --install /usr/bin/$(basename $bin) $(basename $bin) $bin 100; done'
sudo sh -c 'for bin in /usr/lib/jvm/jdk-11.0.1/bin/*; do update-alternatives --set $(basename $bin) $bin; done'
scp -r jamie@home.nightmares.co.uk:/home/jamie/.ssh ~/
scp jamie@home:/home/jamie/.zshrc ~/
scp jamie@home:/home/jamie/.zsh_plugins.txt ~/
scp jamie@home:/home/jamie/.iterm2_shell_integration.zsh ~/
scp -r jamie@home:/home/jamie/.iterm2 ~/
curl -sL git.io/antibody | sh -s
chsh -s /bin/zsh
pip3 install --user setuptools
pip3 install --user powerline-status
scp jamie@home:/home/jamie/.vimrc ~/.vimrc
scp jamie@home:/home/jamie/.emacs ~/.emacs
mkdir -p ~/.vim/colors
scp jamie@home:/home/jamie/.vim/colors/dracula.vim ~/.vim/colors/dracula.vim
mkdir -p  ~/.config/powerline
cp -r ~/.local/lib/python3.6/site-packages/powerline/config_files/ ~/.config/powerline/
cd /tmp/
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts
cd /tmp
wget https://dl.google.com/go/go1.11.4.linux-amd64.tar.gz
tar -zxvf /tmp/go1.11.4.linux-amd64.tar.gz --directory /usr/local/
sudo ln -s /usr/local/go/bin/go /usr/local/bin/go
sudo ln -s /usr/local/go/bin/godoc /usr/local/bin/godoc
sudo ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt
mkdir -p ~/.config/xfce4/terminal/
scp home:~/.config/xfce4/terminal/terminalrc ~/.config/xfce4/terminal/terminalrc
sudo update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper
cd /tmp
wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.12.4481.tar.gz
tar -zxvf jetbrains-toolbox-1.12.4481.tar.gz
./jetbrains-toolbox-1.12.4481/jetbrains-toolbox 
gsettings set org.cinnamon.theme name 'Mint-Y-Dark-Red'
gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Red'
gsettings set org.cinnamon.desktop.interface icon-theme 'Mint-Y-Red'
gsettings set x.dm.slick-greeter icon-theme-name 'Mint-X-Dark'
gsettings set org.cinnamon.desktop.wm.preferences theme 'Mint-Y-Dark'
cd $STARTPWD
echo "alias ls='ls --color'" >> ~/.zshrc
echo "alias tree='tree -C'" >> ~/.zshrc
echo "Update the fonts for your terminal and then restart your shell to fnish"
