#!/bin/bash
STARTPWD=$(pwd)

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

set_username() {
    if [ -z $SUDO_USER ]; then
        USERNAME=$USER
        WSL_USER=$USER
    else
        USERNAME=$SUDO_USER
    fi
    if [[ $USERNAME == "root" ]]; then
        if [[ -v WSLENV && ! -v WSL_USER ]]; then
            show_msg "WSL Username not set... Exiting!"
            exec > /dev/tty
            usage
            exit 1
        fi
        USER_PATH="/root"
    else
        USER_PATH="/home/$USER"
    fi
    if [ ! -v WSL_USER ]; then
        WSL_USER=$USERNAME
    fi
}

usage() {
    echo -e "Usage:"
    echo -e "  ${bold}${red}-o  --obs${normal}                    Don't install OBS studio or v4l2loopback"
    echo -e "  ${bold}${red}-c  --commandline-only${normal}       Install only commandline tools (no snaps, no chrome, etc...)"
    echo -e "  ${bold}${red}-w  --wsl-user [username]${normal}    Sets the Windows username which runs WSL.  This is used to find the windows"
    echo -e "                               users home directory. If not specified it matches it to the linux username."
    echo -e "                               If you run this script as root then you ${bold}MUST${normal} specify this."
    echo -e "  ${bold}${red}-b  --virtual-box${normal}            Installs VirtualBox"
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

install_feedparser() {
    if [[ $FEEDPASER == "false" ]]; then
	show_msg "Installing feedparser using pip..."
	export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring
        pip3 install feedparser > /dev/null 2>&1
        export FEEDPASER=true
    fi
}

get_version() {
    echo -e "import feedparser\nd=feedparser.parse('$1')\nprint(d.entries[0].title)\n" | python3 -
}

install_antibody() {
	if ! which antibody > /dev/null; then
	    show_msg "Installing antibody..."
	    curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin
	fi
}

change_shell() {
	if [[ $(awk -F: '/${USERNAME}/ {print $7}' /etc/passwd) != "/bin/zsh" ]]; then
	    show_msg "Changing shells to ZSH..."
	    sudo chsh -s /bin/zsh $USERNAME
	fi
}

install_snaps() {
    show_msg "Installing the following packages from snap:"
    show_msg "Authy"
    show_msg "Journey"
    show_msg "Todoist"

    if ! which authy > /dev/null; then
        sudo snap install authy --beta
    fi
    if ! which todoist > /dev/null; then
        sudo snap install todoist
    fi
    if ! which journey > /dev/null; then
        sudo snap install journey
    fi
}

setup_flatpak() {
    show_msg "Setting up Flatpak..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak install -y flathub org.gnome.Platform//40
    sudo flatpak install -y flathub org.gtk.Gtk3theme.Breeze-Dark
    show_msg "Installing Geary using Flatpak..."
    sudo flatpak install -y flathub org.gnome.Geary
}

setup_wsl() {
    if [ ! -v WSLENV ]; then
        return
    fi 
    WSL=true
    show_msg "WSL Environment variable present.  Setup WSL specific stuff..."
    sudo apt-get install -y socat pass
    if [ ! -d "/mnt/c/Users/$WSL_USER" ]; then
        show_msg "${red}Can't match username to directory.  Tried ${bold}'/mnt/c/Users/$WSL_USER'${normal}${red}... Have you set the wsl-user option?${normal}"
        exec > /dev/tty
        usage
        show_msg "${red}Unable to continue.  ${bold}Exiting...${normal}"
        exit 1
    else
        WSL_HOME="/mnt/c/Users/$WSL_USER"
    fi
    exec > /dev/tty
    if [ ! -d "/mnt/c/Program Files (x86)/Gpg4win/bin" ]; then
        echo -e "Please download and install WinGPG from https://www.gpg4win.org/thanks-for-download.html"
        read -p "Once this is done please press any key to continue..."
    fi
    if [ ! -d "/mnt/c/Program Files (x86)/Gpg4win/bin" ]; then
        show_msg "Unable to complete WSL due to missing WinGPG"
        return 1
    fi
    WINGPG_HOME="$WSL_HOME/AppData/Roaming/gnupg"
    mkdir -p $WINGPG_HOME
    if [ ! -f "${WINGPG_HOME}/npiperelay.exe" ]; then
        wget -q -O "${WINGPG_HOME}/npiperelay.exe" https://github.com/NZSmartie/npiperelay/releases/download/v0.1/npiperelay.exe
    fi
    cat << EOF > "${WINGPG_HOME}/gpg-agent.conf"
enable-ssh-support
enable-putty-support
pinentry-program "C:\Program Files (x86)\Gpg4win\bin\pinentry-w32.exe"
default-cache-ttl 60
max-cache-ttl 120
EOF
    /mnt/c/Program\ Files\ \(x86\)/GnuPG/bin/gpg-connect-agent.exe /bye
    curl -LSs https://raw.githubusercontent.com/j-maynard/terminal-config/master/wingpg/create-gpg-agent-lnk.ps1 | sed "s|\$USER=|\$USER=${WSL_USER}|g" > /mnt/c/temp/create-gpg-agent-lnk.ps1
    powershell.exe -ExecutionPolicy Bypass c:\\temp\\create-gpg-agent-lnk.ps1
}

setup_shims() {
    show_msg "Running jenv/rbenv setup script..."
    curl -LSs "$GIT_REPO/scripts/shim-setup.sh" | bash -s - $VARG
    if [ $? -eq 0 ]; then
        show_msg "${green}RBenv and Jenv installed successfully.${normal}"
    else
        show_msg "${red}Failed to install rbenv/jenv.${normal}"
    fi
}

setup_streamdeck() {
    if lsusb |grep 0fd9:006d > /dev/null; then
		show_msg "Installing streamdeck libraries..."
		if [[ $(mokutil --sb-state) == "SecureBoot enabled" ]]; then
			exec > /dev/tty
			sudo apt-get install -y qt5-default libhidapi-hidraw0 libudev-dev libusb-1.0-0-dev python3-pip
			if [ $VERBOSE == "false" ]; then
				exec > /dev/null
			fi
		else
			sudo apt-get install -y qt5-default libhidapi-hidraw0 libudev-dev libusb-1.0-0-dev python3-pip
		fi

		show_msg "Adding udev rules and reloading"
		sudo usermod -a -G plugdev `whoami`

		sudo tee /etc/udev/rules.d/99-streamdeck.rules << EOF
SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0060", MODE:="666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0063", MODE:="666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="006c", MODE:="666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="006d", MODE:="666", GROUP="plugdev"
EOF

		sudo udevadm control --reload-rules

		show_msg "Unplug and replug in device for the new udev rules to take effect"
		show_msg "Installing streamdeck_ui..."
		pip3 install --user streamdeck_ui
		if [ $? == 0 ]; then
			show_msg "StreamDeck-UI Installed"
		else
			show_msg "Something went wrong installing StreamDeck-Ui"
		fi
    fi
}

install_custom_panel() {
    if which plasmashell > /dev/null; then
        show_msg "Installing custom HUD Panel..."
        git clone -q https://github.com/j-maynard/kde-panels /tmp/kde-panels
        cd /tmp/kde-panels/panels
        kpackagetool5 -t Plasma/LayoutTemplate --install org.kde.plasma.desktop.hudPanel
        kpackagetool5 -t Plasma/LayoutTemplate --install org.kde.plasma.desktop.gnomePanel
    fi
}

setup_breeze_dark() {
	lookandfeeltool -a org.kde.breezedark.desktop
	sudo flatpak install -y flathub flathub org.gtk.Gtk3theme.Breeze-Dark
	sudo flatpak override --filesystem=~/.themes
}

install_qogir_theme() {
    show_msg "Setting up Qogir Material Theme..."
    mkdir -p ~/.local/share/plasma/plasmoids
    gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close
    cd /tmp
    if pgrep plasmashell; then
        git clone ${GIT_QUIET} https://github.com/vinceliuice/Qogir-kde.git
        /tmp/Qogir-kde/install.sh > /dev/null
    fi
    git clone ${GIT_QUIET} https://github.com/vinceliuice/Qogir-theme
    /tmp/Qogir-theme/install.sh > /dev/null
    /tmp/Qogir-theme/install.sh -l ubuntu > /dev/null
    git clone ${GIT_QUIET} https://github.com/vinceliuice/Qogir-icon-theme.git
    /tmp/Qogir-icon-theme/install.sh > /dev/null
    if which snap > /dev/null; then
        sudo snap install qogir-themes > /dev/null
        for i in $(snap connections | grep gtk-common-themes:gtk-3-themes | awk '{print $2}'); do sudo snap connect $i qogir-themes:gtk-3-themes; done
        for i in $(snap connections | grep gtk-common-themes:icon-themes | awk '{print $2}'); do sudo snap connect $i qogir-themes:icon-themes; done
    fi
    if which flatpak > /dev/null; then
        sudo flatpak install -y flathub org.gtk.Gtk3theme.Qogir-ubuntu-dark/x86_64/3.34
        sudo flatpak override --filesystem=~/.themes
    fi
}


install_virtual_desktop_bar() {
    if which plasmashell > /dev/null; then
        show_msg "Installing Virtual Desktop Bar plasmoid..."
        sudo apt-get install -y cmake extra-cmake-modules g++ qtbase5-dev qtdeclarative5-dev libqt5x11extras5-dev libkf5plasma-dev libkf5globalaccel-dev libkf5xmlgui-dev > /dev/null
        git clone -q https://github.com/wsdfhjxc/virtual-desktop-bar.git /tmp/virtual-desktop-bar
        cd /tmp/virtual-desktop-bar
        ./scripts/build-applet.sh > /dev/null 
        ./scripts/install-applet.sh > /dev/null
    fi
}

################################
# Main Script body starts here #
################################

# Set default options
COMMANDLINE_ONLY=false
OBS=true
VERBOSE=false
PRIVATE=false
WSL=false
NEON=false
FEEDPASER=false
GAMES=true
DESKTOP_THEME=breeze-dark
VM=false
FUNC=false
SCREEN_4K=true

# Process commandline arguments
while [ "$1" != "" ]; do
    case $1 in
		q | -q | --qogir)				DESKTOP_THEME=qogir
										;;
        g | -g | --no-games)            GAMES=false
                                        ;;
        n | -n | --neon)                NEON=true
                                        ;;
        c | -c | --commandline-only)    COMMANDLINE_ONLY=true
                                    	;;
        w | -w | --wsl-user)            shift
                                        WSL_USER=$1
                                        ;;
	    m | -m | --model)		        shift
					                    # Not used for ubuntu.  Skipping
					                    ;;
        o | -o | --obs)                 OBS=false
                                        ;;
        s | -s | --screen)              SCREEN_4K=false
                                        ;;
        b | -b | --virtualbox)          VM=true
                                        ;;
        r | -r | --run)                 FUNC=true
                                        shift
                                        FUNC_NAME=$1
                                        ;;
        V | -V | --verbose)             VERBOSE=true
					                    VARG="-V"
                                    	;;
        v | -v | --version)             version
                                    	exit 0
                                    	;;
        h | -h | --help)                usage
                                    	exit 0
                                    	;;
        * )                         	echo -e "Unknown option $1...\n"
                                    	usage
                                    	exit 1
                                    	;;
    esac
    shift
done

# Silence output
if [ $VERBOSE == "false" ]; then
    echo "Silencing output"
    GIT_QUIET="-q"
    exec > /dev/tty
    exec > /dev/null 
fi

set_username

if [[ $FUNC == "true" ]]; then
    $FUNC_NAME
    exit 0
fi

if [ ! -f /etc/post-install-script-run ]; then
    wget -q -O /tmp/ubuntu-setup-system.sh $GIT_REPO/scripts/ubuntu-setup-system.sh
    bash /tmp/ubuntu-setup-system.sh $@
fi

install_antibody
change_shell
install_feedparser

setup_wsl
setup_shims

if [[ $COMMANDLINE_ONLY == "false" && $WSL == "false" ]]; then
    show_msg "\n\nSetting up GUI Applications...\n\n"
    install_snaps
    setup_flatpak
    show_msg "\n\nInstalling desktop themes...\n\n"
    if pgrep plasmashell; then
        install_virtual_desktop_bar
        install_custom_panel
    fi
	
	case $DESKTOP_THEME in
        qogir)	install_qogir_theme
				;;
		*)		setup_breeze_dark
				;;
		esac
fi

if [[ $WSL == "false" ]]; then
	setup_streamdeck
fi

cd $STARTPWD

show_msg "\n\nUbuntu Setup Script has finished installing...\n\n"
exit 0
