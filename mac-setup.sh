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
    echo "Mac Setup Script Version 0.5"
    echo "(c) Jamie Maynard 2020"
}

SILENT='>/dev/null'
PRIVATE=false
while [ "$1" != "" ]; do
    case $1 in
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
echo -e "Installing homebrew"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" $SILENT

echo -e "Installing from brew... "
echo -e "  ┣━━━━━━━━━━━━━━┓"
echo -e "  ┣━> zsh        ┣━> python"
echo -e "  ┣━> maven      ┣━> openssh"
echo -e "  ┣━> htop       ┣━> tree"
echo -e "  ┣━> lynx       ┣━> links"
echo -e "  ┣━> tmux       ┣━> most"
echo -e "  ┣━> emac       ┣━> antibody"
echo -e "  ┣━> openjdk 8  ┣━> openjdk 11"
echo -e "  ┣━> rbenv      ┣━> jenv"
echo -e "  ┣━> lsd        ┣━> vs code"
echo -e "  ┣━> slack      ┣━> insomnia"
echo -e "  ┣━> gnupg      ┣━> macvim"
echo -e "  ┗━> iterm2     ┗━>google-chrome"
brew install zsh python maven openssh htop links lynx coreutils tree tmux most gnupg jenv rbenv lsd $SILENT
brew cask install emacs $SILENT
brew install getantibody/tap/antibody $SILENT
brew install macvim --env-std --with-override-system-vim $SILENT
brew tap adoptopenjdk/openjdk $SILENT
brew cask install adoptopenjdk8 $SILENT
brew cask install adoptopenjdk11 $SILENT
brew cask install visual-studio-code $SILENT
brew cask install slack $SILENT
brew cask install insomnia $SILENT
brew cask install iterm2 $SILENT
brew cask install google-chrome $SILENT

echo -e "Changing shells to zsh... enter your user password when asked!"
chsh -s /bin/zsh $SILENT

echo -e "Installing powerline..."
pip install --user setuptools $SILENT
pip install --user powerline-status $SILENT
mkdir -p  ~/.config/powerline $SILENT
cp -r ~/Library/Python/3.6/lib/python/site-packages/powerline/config_files/ ~/.config/powerline/ $SILENT
