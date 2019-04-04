#!/bin/bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install zsh python maven openssh htop links lynx coreutils tree tmux most
brew cask install emacs
scp -r jamie@home.nightmares.co.uk:/home/jamie/.ssh ~/.ssh
scp jamie@home:/home/jamie/.zshrc ~/
scp jamie@home:/home/jamie/.zsh_plugins.txt ~/
scp jamie@home:/home/jamie/.iterm2_shell_integration.zsh ~/
scp -r jamie@home:/home/jamie/.iterm2 ~/
brew install getantibody/tap/antibody
chsh -s /bin/zsh
brew install macvim --env-std --with-override-system-vim
pip install --user powerline-status
scp jamie@home:/home/jamie/.vimrc-mac ~/.vimrc
mkdir -p ~/.vim/colors
scp jamie@home:/home/jamie/.vim/colors/dracula.vim ~/.vim/colors/dracula.vim
mkdir -p  ~/.config/powerline
cp -r ~/Library/Python/3.6/lib/python/site-packages/powerline/config_files/ ~/.config/powerline/
cd /tmp/
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts
cd ~/
echo 'PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"' >> ~/.zshrc
echo 'MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"' >> ~/.zshrc
echo "alias ls='ls --color'" >> ~/.zshrc
echo "alias tree='tree -C'" >> ~/.zshrc
echo "Update the fonts for your terminal and then restart your shell to fnish"

