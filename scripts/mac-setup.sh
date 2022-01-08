#!/bin/bash
STARTPWD=$(pwd)

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`

if [ -z $GIT_REPO ]; then
    GIT_REPO="https://raw.githubusercontent.com/j-maynard/terminal-config/main"
fi

# Define colors and styles
normal="\033[0m"
bold="\033[1m"
green="\e[32m"
red="\e[31m"
yellow="\e[93m"

usage() {
    echo -e "Usage:"
    echo -e "  ${bold}${red}-V  --verbose${normal}                Shows command output for debugging"
    echo -e "  ${bold}${red}-v  --version${normal}                Shows version details and exit"
    echo -e "  ${bold}${red}-h  --help${normal}                   Shows this usage message and exit"
}

version() {
    echo -e "Ubuntu Setup Script Version 0.8"
    echo -e "(c) Jamie Maynard 2021"
}

show_msg() {
    echo -e "${bold}${1}${normal}" > /dev/tty
}

show_pkgs() {
	PKGS=("$@")
	SORTED_PKGS=($(for a in "${PKGS[@]}"; do echo "$a "; done | sort))
    col=0
    for pkg in ${SORTED_PKGS[@]}; do
        if [[ $col == '3' ]]; then
            pkg_out="${pkg_out}${pkg}\n"
            col=0
        else
            pkg_out="${pkg_out}${pkg} | "
            col=$(expr $col + 1)
        fi
    done
	echo -e ${pkg_out[@]} | column -t -s "|" > /dev/tty
	unset pkg_out
}

install_homebrew() {
	show_msg "Installing Homebrew..."
	if [ ! -f /opt/homebrew/bin/brew ]; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	eval "$(/opt/homebrew/bin/brew shellenv)"
}

add_taps() {
	show_msg "Adding tap for OpenJDK..."
	brew tap adoptopenjdk/openjdk
}

install_brews() {
	BREWS=("python" "maven" "openssh" "htop" "links" "coreutils" "tree" "tmux" "most"
    	"gnupg" "jenv" "rbenv" "lsd" "bat" "ncspot" "yq" "jq" "jed" "neovim" "awscli" "go"
    	"visual-studio-code" "discord" "iterm2" "obsidian" "antibody" "openjdk@11" 
    	"openjdk@17" "insomnia" "google-chrome" "multipass" "fzf" "pinentry-mac")
    show_msg "Installing the following brews using homebrew:"
	show_pkgs "${BREWS[@]} nerd-fonts"
	BREWS="${BREWS[@]}"
	brew install ${BREWS[@]}
	brew install $( brew search font | grep nerd | tr '\n' ' ' )
}

install_casks() {
	CASKS=("aws-vault" "emacs" "1password-cli" "macvim" "powershell" "vimr")
	show_msg "Installing the following casks using homebrew:"
	show_pkgs "${CASKS[@]}"
	brew install --cask ${CASKS[@]}
}

setup_jdk() {
	sudo ln -sfn $(brew --prefix)/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
}

# Silence output
if [[ $VERBOSE == "false" ]]; then
    echo "Silencing output"
    GIT_QUIET="-q"
    exec > /dev/tty
    exec > /dev/null 
fi

if [[ $FUNC == "true" ]]; then
    $FUNC_NAME
    exit $?
fi

show_msg "Setting up Mac apps and terminal apps..."

install_homebrew
add_taps
install_brews
install_casks
setup_jdk