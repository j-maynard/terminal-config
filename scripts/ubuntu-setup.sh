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
    echo -e "  ${bold}${red}-s  --streaming${normal}              Install OBS studio as well as v4l2loopback for steaming"
    echo -e "  ${bold}${red}-c  --commandline-only${normal}       Install only commandline tools (no snaps, no chrome, etc...)"
    echo -e "  ${bold}${red}-w  --wsl-user [username]${normal}    Sets the Windows username which runs WSL.  This is used to find the windows"
    echo -e "                               users home directory. If not specified it matches it to the linux username."
    echo -e "                               If you run this script as root then you ${bold}MUST${normal} specify this."
    echo -e "  ${bold}${red}-o  --virtual-box${normal}            Installs VirtualBox"
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

apt_update() {
    show_msg "Updating the system..."
    sudo apt-get update
    if [[ $(mokutil --sb-state) == "SecureBoot enabled" ]]; then
        exec > /dev/tty
        sudo apt-get upgrade -y
        if [ $VERBOSE == "false" ]; then
            exec > /dev/null
        fi
    else
        sudo apt-get upgrade -y
    fi
}

pkcon_update() {
    show_msg "Updating the system..."
    sudo apt-get update
    if [[ $(mokutil --sb-state) == "SecureBoot enabled" ]]; then
        exec > /dev/tty
        sudo pkcon update -y --allow-downgrades
        if [ $VERBOSE == "false" ]; then
            exec > /dev/null
        fi
    else
        sudo pkcon update -y --allow-downgrades
    fi
}

apt_install() {
    show_msg "Installing from apt... "

    apt_pkgs=( "git" "curl" "zsh"  "python3.9-dev" "python3-pip" 
        "build-essential" "jed" "htop" "links" "lynx" "tree" "tmux" 
        "openjdk-11-jdk" "maven" "vim" "vim-nox"
        "vim-scripts" "most" "ruby-dev" "scdaemon" "pinentry-tty"
        "pinentry-curses" "libxml2-utils" "apt-transport-https"
	    "neovim" "libgconf-2-4" "libappindicator1" "libc++1" "clamav"
        "default-jdk" "jq" "gnupg2" )
	
    recent_pkgs=( "openjdk-17-jdk" "python3.10-dev" "python3.10" )

    x_apt_pkgs=( "idle-python3.9" "vim-gtk3" "libappindicator3-1"
        "flatpak" "gnome-keyring" "materia-gtk-theme" "gtk2-engines-murrine"
	    "gtk2-engines-pixbuf" "lm-sensors" "nvme-cli" "conky-all" "gdebi-core" )
	    
    x_recent_pkgs=( "idle-python3.10" )

    neon_pkgs=( "wget" "fonts-liberation" )

    gnome_pkgs=( "pinentry-gnome3" "gnome-tweaks" )

    kde_pkgs=( "kmail" "latte-dock" "umbrello" "kdegames" "kaddressbook" "pinentry-qt"
        "akonadi-backend-postgresql" "akonadi-backend-sqlite" "kleopatra" )
    
    streaming_apt_pkgs=( "ffmpeg" "v4l2loopback-dkms" "v4l2loopback-utils" )

    for pkg in ${apt_pkgs[@]}; do
	PKGS="${PKGS} ${pkg} "
    done
    
    if [ $(lsb_release -r |xargs| cut -d ":" -f 2 |cut -d "." -f 1 |xargs) -gt "20" ]; then
        for pkg in ${recent_pkgs[@]}; do
		PKGS="${PKGS} ${pkg} "
	done
    fi
    
    if [[ $COMMANDLINE_ONLY == "false" && ! -v WSLENV ]]; then
        for pkg in ${x_apt_pkgs[@]}; do
            PKGS="${PKGS} ${pkg} "
        done
		
		if [ $(lsb_release -r |xargs| cut -d ":" -f 2 |cut -d "." -f 1 |xargs) -gt "20" ]; then
			for pkg in ${x_recent_pkgs[@]}; do
				PKGS="${PKGS} ${pkg} "
			done
		fi
        
		if plasmashell --version >/dev/null 2>&1; then
            for pkg in ${kde_pkgs[@]}; do
                PKGS="${PKGS} ${pkg} "
            done
        else
            for pkg in ${gnome_pkgs[@]}; do
                PKGS="${PKGS} ${pkg} "
            done
        fi
        if [[ $NEON == "true" ]]; then
            for pkg in ${neon_pkgs[@]}; do
                PKGS="${PKGS} ${pkg} "
            done
        fi
        sudo usermod -a -G disk `whoami`
        sudo usermod -a -G users `whoami`
    fi

    if [[ $STREAMING == "true" ]]; then
        for pkg in ${streaming_apt_pkgs[@]}; do
            PKGS="${PKGS} ${pkg} "
        done
    fi

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

    show_msg "Installing the following packages using apt:"
    echo -e ${pkg_out[@]} | column -t -s "|" > /dev/tty
    if [[ $(mokutil --sb-state) == "SecureBoot enabled" ]]; then
        exec > /dev/tty
        sudo apt-get install -y ${PKGS[@]}
        if [ $VERBOSE == "false" ]; then
            exec > /dev/null
        fi
    else
        sudo apt-get install -y ${PKGS[@]}
        if [ $? -ne 0 ]; then
            show_msg "${red}Packages are missing or apt-get failed to install properly.  Exiting!${nromal}"
            exit 1
        fi
    fi
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

retry_loop() {
    FUNC_NAME="$1"
    $FUNC_NAME
    if [[ $? != 0 ]]; then
        show_msg "Retrying function $FUNC_NAME..."
        $FUNC_NAME
    fi
}

install_lsd() {
    install_feedparser
    LSDVER=$(get_version https://github.com/Peltoche/lsd/tags.atom)
    case $(uname -m) in
        x86_64)     ARCH=amd64
                    ;;
        arm64)     ARCH=arm64
                    ;;
        *)          echo "${red}Can't identify Arch to match to an LSD download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    show_msg "Installing the latest version of LSD -> version: ${LSDVER}..."
    wget -q -O /tmp/lsd_${LSDVER}_${ARCH}.deb "https://github.com/Peltoche/lsd/releases/download/${LSDVER}/lsd_${LSDVER}_${ARCH}.deb"
    if [ ! -f "lsd_${LSDVER}_${ARCH}.deb" ]; then
        show_msg "${red}Failed to download go... ${normal}${green}Skipping install...${normal}"
        return 1
    fi
    sudo dpkg -i /tmp/lsd_${LSDVER}_${ARCH}.deb
    if [ $? == 0 ]; then
        rm /tmp/lsd_${LSDVER}_${ARCH}.deb
        return 0
    else
        show_msg "Failed to install ls replacement lsd"
        return 1
    fi
}

install_yq() {
    install_feedparser
    YQVER=$(get_version https://github.com/mikefarah/yq/releases.atom | cut -d ' ' -f 1)
    case $(uname -m) in
        x86_64)     ARCH=amd64
                    ;;
        *)          echo "${red}yq only runs on AMD64 Linux.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    show_msg "Installing the latest version of yq -> version: ${YQVER}..."
    wget -q -O /tmp/yq_linux_amd64.tar.gz "https://github.com/mikefarah/yq/releases/download/${YQVER}/yq_linux_amd64.tar.gz"
    if [ ! -f "yq_linux_amd64.tar.gz" ]; then
        show_msg "${red}Failed to download yq... ${normal}${green}Skipping install...${normal}"
        return 1
    fi
    tar -zxf yq_linux_amd64.tar.gz
    sudo mv yq_linux_amd64 /usr/local/bin/yq
    if which yq > /dev/null; then
        rm yq_linux_amd64.tar.gz
        return 0
    else
        show_msg "Failed to install yq yaml parser"
        return 1
    fi
}

install_bat() {
    install_feedparser
    BATVER=$(get_version https://github.com/sharkdp/bat/releases.atom |cut -d 'v' -f 2)
    case $(uname -m) in
        x86_64)     ARCH=amd64
                    ;;
        arm64)      ARCH=arm64
                    ;;
        armhf)      ARCH=armhf
                    ;;
        *)          echo "${red}Can't identify Arch to match to an bat download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    show_msg "Installing the latest version of bat -> version: ${BATVER}..."

    wget -q -O /tmp/bat_${BATVER}_${ARCH}.deb "https://github.com/sharkdp/bat/releases/download/v${BATVER}/bat_${BATVER}_${ARCH}.deb"
    if [ ! -f "/tmp/bat_${BATVER}_${ARCH}.deb" ]; then
        show_msg "${red}Failed to download bat... ${normal}${green}Skipping install...${normal}"
        return 1
    fi
    sudo dpkg -i /tmp/bat_${BATVER}_${ARCH}.deb
    if [ $? == 0 ]; then
        rm /tmp/bat_${BATVER}_${ARCH}.deb
        return 0
    else
        show_msg "Failed to install bat the cat clone with wings"
        return 1
    fi
}

install_glow() {
    install_feedparser
    GLOWVER=$(get_version https://github.com/charmbracelet/glow/releases.atom |cut -d 'v' -f 2)
    case $(uname -m) in
        x86_64)     ARCH=amd64
                    ;;
        arm64)      ARCH=arm64
                    ;;
        armhf)      ARCH=armv6
                    ;;
        *)          echo "${red}Can't identify Arch to match to a glow download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    show_msg "Installing the latest version of Glow -> version: ${GLOWVER}..."

    wget -q -O /tmp/glow_${GLOWVER}_${ARCH}.deb "https://github.com/charmbracelet/glow/releases/download/v${GLOWVER}/glow_${GLOWVER}_linux_${ARCH}.deb"
    if [ ! -f "/tmp/glow_${GLOWVER}_${ARCH}.deb" ]; then
        show_msg "${red}Failed to download glow... ${normal}${green}Skipping install...${normal}"
        return 1
    fi
    sudo dpkg -i /tmp/glow_${GLOWVER}_${ARCH}.deb
    if [ $? == 0 ]; then
        rm /tmp/glow_${GLOWVER}_${ARCH}.deb
        return 0
    else
        show_msg "Failed to install glow the markdown viewer for the commandline"
        return 1
    fi
}

install_ncspot() {
    install_feedparser
    SPOTVER=$(get_version https://github.com/hrkfdn/ncspot/releases.atom)
    case $(uname -m) in
        x86_64)     ARCH=amd64
                    ;;
        *)          echo "${red}ncspot only runs on AMD64 Linux.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    show_msg "Installing the latest version of ncspot -> version: ${SPOTVER}..."
    wget -q -O /tmp/ncspot-v${SPOTVER}-linux.tar.gz "https://github.com/hrkfdn/ncspot/releases/download/v${SPOTVER}/ncspot-v${SPOTVER}-linux.tar.gz"
    if [ ! -f "/tmp/ncspot-v${SPOTVER}-linux.tar.gz" ]; then
        show_msg "${red}Failed to download ncspot... ${normal}${green}Skipping install...${normal}"
        return 1
    fi
    tar -zxf "/tmp/ncspot-v${SPOTVER}-linux.tar.gz"
    sudo mv /tmp/ncspot /usr/local/bin
    if which ncspot > /dev/null; then
        rm /tmp/ncspot-v${SPOTVER}-linux.tar.gz
        return 0
    else
        show_msg "Failed to install ncspot Spotify Client"
        return 1
    fi
}

install_xidel() {
    install_feedparser
    XIVER=$(get_version https://github.com/benibela/xidel/releases.atom | cut -d ' ' -f 2)
    case $(uname -m) in
        x86_64)     ARCH=amd64
                    ;;
        *)          echo "${red}Xidel only runs on AMD64 Linux.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    show_msg "Installing the latest version of xidel -> version: ${XIVER}..."
    wget -q -O /tmp/xidel_${XIVER}-1_${ARCH}.deb "https://github.com/benibela/xidel/releases/download/Xidel_${XIVER}/xidel_${XIVER}-1_${ARCH}.deb"
    if [ ! -f "/tmp/xidel_${XIVER}-1_${ARCH}.deb" ]; then
        show_msg "${red}Failed to download xidel... ${normal}${green}Skipping install...${normal}"
        return 1
    fi
    sudo dpkg -i /tmp/xidel_${XIVER}-1_${ARCH}.deb
    if [ $? == 0 ]; then
        rm xidel_${XIVER}-1_${ARCH}.deb
        return 0
    else
        show_msg "Failed to install Xidel XML Parser."
        return 1
    fi
}

install_go() {
    install_feedparser
    GOVER=$(get_version https://github.com/golang/go/releases.atom |cut -d ' ' -f 2)
    if [ -d /usr/local/go ]; then
        if [ -f /usr/local/go/bin/go ]; then
            if [ $(/usr/local/go/bin/go version | cut -d' ' -f3) ==  $GOVER ]; then
                show_msg "${green}Latest Version of Go (${GOVER} is already installed.${normal}  Skipping go install..."
                return 0
            fi
        fi
    fi

    case $(uname -m) in
        x86_64)     ARCH=amd64
                    ;;
        armv6l)     ARCH=armv6l
                    ;;
        arm64)      ARCH=arm64
                    ;;
        *)          show_msg "${red}Can't identify Arch to match to a Go download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    show_msg "Installing the latest version of Go -> version: ${GOVER}..."
    wget -q -O /tmp/${GOVER}.linux-${ARCH}.tar.gz https://dl.google.com/go/${GOVER}.linux-${ARCH}.tar.gz
    if [ ! -f "/tmp/${GOVER}.linux-${ARCH}.tar.gz" ]; then
        show_msg "${red}Failed to download go... ${normal}${green}Skipping install...${normal}"
        return 1
    fi
    if [ -d "/usr/local/go" ]; then
        sudo rm -rf /usr/local/go
    fi
    sudo tar -zxf /tmp/${GOVER}.linux-amd64.tar.gz --directory /usr/local/
    rm ${GOVER}.linux-amd64.tar.gz
    if [[ -f "/usr/local/bin/go" ]]; then
        sudo rm /usr/local/bin/go
    fi
    if [[ -f "/usr/local/bin/gofmt" ]]; then
        sudo rm /usr/local/bin/gofmt
    fi
    sudo ln -s /usr/local/go/bin/go /usr/local/bin/go
    sudo ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt
    return 0
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

install_docker() {
    if [ -v WSLENV ]; then
        show_msg "Skipping Docker install as this should be done through Windows Docker Desktop..."
        return
    fi 
    show_msg "Installing Docker Community Edition..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    if [ $? ]; then
        show_msg "Docker installed successfully"
    fi
    sudo usermod -a -G docker $USERNAME
    show_msg "Installing docker-compose..."
    sudo curl -SsL "https://github.com/docker/compose/releases/download/1.26.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    if which docker-compose > /dev/null; then
        show_msg "Docker Compose installed successfully..."
    else
        show_msg "Docker Compose install failed... You may need to add /usr/local/bin to your path"
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

install_chrome() {
    if ! which google-chrome > /dev/null; then
        show_msg "Installing Google Chrome (Latest)..."
        wget -q -O /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        if [ ! -f "/tmp/google-chrome-stable_current_amd64.deb" ]; then
            show_msg "${red}Failed to download Google Chrome... ${normal}${green}Skipping install...${normal}"
            return
        fi
        sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb
        if [ $? == 0 ]; then
            rm /tmp/google-chrome-stable_current_amd64.deb
        else
            show_msg "Failed to install chrome"
        fi
    fi
}

install_spotify() {
    show_msg "Installing Spotify Client..."
    if ! which spotify > /dev/null; then
        curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add - 
        echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
        sudo apt-get update && sudo apt-get install -y spotify-client
        if [[ $4K == "true" ]]; then
            sed "s/Exec=spotify %U/Exec=spotify --force-device-scale-factor=1.75 %U/" /usr/local/share/applications/spotify.desktop | sudo tee /usr/local/share/applications/spotify.desktop
        fi
    fi
}

install_1password() {
    show_msg "Installing 1Password..."
    if ! which 1password > /dev/null; then
        wget -q -O /tmp/1password-latest.deb "https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb"
        if [ ! -f "/tmp/1password-latest.deb" ]; then
            show_msg "${red}Failed to download 1Password Deb Package... ${normal}${green}Skipping install...${normal}"
            return
        fi
        sudo dpkg -i /tmp/1password-latest.deb
        if [ $? == 0 ]; then
            rm /tmp/1password-latest.deb
        else
            show_msg "Failed to install 1Password..."
        fi
    fi
}

install_inkscape() {
    show_msg "Installing Inkscape..."
    sudo add-apt-repository -y ppa:inkscape.dev/stable
    sudo apt-get update
    sudo apt-get install -y inkscape > /dev/null
    sudo apt-get install --fix-broken
}

install_discord() {
    if ! which discord; then
        show_msg "Installing Discord (Latest)..."
        sudo apt-get install -y libappindicator1 libc++1 
        wget -q -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"
        sudo dpkg -i /tmp/discord.deb
        if which discord >/dev/null; then
            rm /tmp/discord.deb
        else
            sudo apt-get --fix-broken install
            if which discord >/dev/null; then
                rm /tmp/discord.deb
                show_msg "Discord installed successfully"
            else
                show_msg "Failed to install discord"
            fi
        fi
    fi
}

install_libreoffice() {
    show_msg "Removing bundled LibreOffice and installing official LibreOffice from PPA..."
    sudo apt-get remove -y --purge libreoffice*
    sudo apt-get clean -y
    sudo apt-get autoremove -y
    sudo add-apt-repository -y ppa:libreoffice/ppa
    sudo apt-get update
    sudo apt-get install -y libreoffice
}

install_vscode() {
    show_msg "Installing Visual Studio Code..."
    case $(uname -m) in
        x86_64)     ARCH=x64
                    ;;
        *)          echo "${red}Can't identify Arch to match to an LSD download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return
    esac
    cd /tmp
    wget -q "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-${ARCH}"
    mv /tmp/"download?build=stable&os=linux-deb-${ARCH}" vscode.deb
    sudo dpkg -i /tmp/vscode.deb >/dev/null
    if which code >/dev/null; then
        rm vscode.deb
    else
        echo "Unable to install Visual Studio Code"
    fi
}

install_typora() {
    show_msg "Install Typora (Markdown Viewer/Editor)..."
    wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add - > /dev/null 2>&1
    sudo add-apt-repository -y 'deb https://typora.io/linux ./'
    sudo apt-get update > /dev/null
    sudo apt-get install -y typora  > /dev/null
}

install_virtualbox() {
    show_msg "Installing Oracle Virtual Box..."
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add - > /dev/null 2>&1
    wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add - > /dev/null 2>&1
    dist=$(lsb_release -c | cut -d':' -f 2 | tr -d '[:space:]')
    echo "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $dist contrib" | sudo tee -a /etc/apt/sources.list
    sudo apt-get update
    pkg=$(apt-cache search virtualbox | grep Oracle |sort -r |head -n1 |cut -d ' ' -f1)
    sudo apt-get install -y $pkg
}

setup_obs() {
    exec > /dev/tty
    show_msg "Streaming selected... Installing Open Braodcase System (OBS)..."
    sudo add-apt-repository -y ppa:obsproject/obs-studio  > /dev/null 2>&1
    if ! curl -Ss -f http://ppa.launchpad.net/obsproject/obs-studio/ubuntu/dists/$(lsb_release -c -s) > /dev/null 2>&1; then
        show_msg "No $(lsb_release -c -s) release... Skipping OBS install"
        return
    fi
    sudo apt-get update > /dev/null
    if [[ $(mokutil --sb-state) == "SecureBoot enabled" ]]; then
        exec > /dev/tty
        sudo apt-get install -y obs-studio
        if [ $VERBOSE == "false" ]; then
            exec > /dev/null
        fi
    else
        sudo apt-get install -y obs-studio > /dev/null
    fi
    # Disabled this as I think OBS now does this automatically
    #sudo modprobe v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
    #echo 'v4l2loopback' | sudo tee -a /etc/modules 
    #echo 'options v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1' | sudo tee - /etc/modprobe.d/v4l2loopback.conf > /dev/null
}

setup_nvidia_drivers() {
	if lspci |grep NVIDIA > /dev/null; then
		show_msg "${green}Checking NVIDIA driver status...${normal}"
		if ! lsmod |grep nvidia_uvm; then
			show_msg "${red}Installing NVIDIA Propriatory drivers...${normal}"
			if [[ $(mokutil --sb-state) == "SecureBoot enabled" ]]; then
				exec > /dev/tty
				sudo ubuntu-drivers autoinstall
				if [ $VERBOSE == "false" ]; then
					exec > /dev/null
				fi
			else
				sudo ubuntu-drivers autoinstall
			fi
		fi
	fi
}

install_nvidia_modules_to_initramfs() {
    if lspci |grep NVIDIA > /dev/null; then
        echo -e "nvidia\nnvidia_modeset\nnvidia_uvm\nnvidia_drm" | sudo tee -a /etc/initramfs-tools/modules
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

setup_openrazer() {
    if lsusb |grep 1532 > /dev/null 2>&1; then
        show_msg "Razer Hardware Detected... Applying Xorg Conf File"
        wget -q -O /tmp/11-razer.conf "https://raw.githubusercontent.com/j-maynard/terminal-config/main/lib/11-razer.conf"
        sudo mv /tmp/11-razer.conf /etc/X11/xorg.conf.d/

        show_msg "Razer Hardware Detected... Installing OpenRazer..."
        sudo add-apt-repository -y ppa:openrazer/daily

        if [[ $(mokutil --sb-state) == "SecureBoot enabled" ]]; then
            exec > /dev/tty
            sudo apt-get install -y openrazer-meta
            if [ $VERBOSE == "false" ]; then
                exec > /dev/null
            fi
        else
            sudo apt-get install -y openrazer-meta
        fi

        if [[ $COMMANDLINE_ONLY == "false" ]]; then
            # Add RazerGenie Repo
            echo 'deb http://download.opensuse.org/repositories/hardware:/razer/xUbuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/hardware-razer.list
            curl -LSso /tmp/razergenie.key https://download.opensuse.org/repositories/hardware:/razer/xUbuntu_20.04/Release.key
            sudo apt-key add /tmp/razergenie.key
            # Add Polychromatic Repo
            sudo add-apt-repository -y ppa:polychromatic/stable
            # Install Both
            sudo apt-get update
            sudo apt-get install -y polychromatic razergenie
        fi
    fi
}

install_steam() {
    show_msg "Installing Steam..."
    sudo apt-get install -y zenity zenity-common > /dev/null 2>&1
    wget -qO /tmp/steam.deb https://cdn.cloudflare.steamstatic.com/client/installer/steam.deb
    sudo dpkg -i /tmp/steam.deb > /dev/null
}

install_minecraft() {
    show_msg "Installing Minecraft..."
    wget -qO /tmp/minecraft.deb https://launcher.mojang.com/download/Minecraft.deb
    sudo dpkg -i /tmp/minecraft.deb > /dev/null
}

fix_sddm() {
    if [[ -f "/usr/share/sddm/scripts/Xsetup" ]]; then
        show_msg "SDDM present"
        grep term-config /usr/share/sddm/scripts/Xsetup
        if [ $? != 0 ]; then
            show_msg "Updating SDDM XSetup script..."
            curl -LSs "$GIT_REPO/lib/Xsetup.snippet" | sudo tee -a /usr/share/sddm/scripts/Xsetup >/dev/null
        fi
    fi
}

install_kvantum() {
    if which plasmashell > /dev/null; then
        show_msg "Installing Kvantum Plasma theme manager..."
        sudo add-apt-repository -y ppa:papirus/papirus > /dev/null 2>&1
        sudo apt-get update > /dev/null
        sudo apt-get install -y qt5-style-kvantum qt5-style-kvantum-themes > /dev/null
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

fix-update-grub() {
# As there is no accurate way to detect Kubuntu from Ubuntu
	# We look for plasmashell instead and then assume its Kubuntu.
	if plasmashell --version >/dev/null 2>&1; then
        show_msg "Updating update grub script to replace Ubuntu with Kubuntu..."
		cat << EOF | sudo tee - /usr/sbin/update-grub > /dev/null 2&>1
#!/bin/sh                                                               
set -e                                                                  
grub-mkconfig -o /boot/grub/grub.cfg "\$@"                          
if plasmashell --version >/dev/null 2>&1; then                          
        echo "Looks like Kubuntu... Updating Ubuntu to Kubuntu... " >&2 
        C=/boot/grub/grub.cfg                                           
        chmod +w \$C 
        sed -i 's/ubuntu/kubuntu/' \$C
        sed -i 's/Ubuntu/Kubuntu/' \$C
        sed -i 's/kkubuntu/kubuntu/' \$C
        chmod -w \$C
fi
EOF
	fi
}

install_grub_themes() {
	# Install Grub Theme
	# TODO Make own GRUB theme for the Razer Blade
    show_msg "Installing grub themes..."
	t=/tmp/grub2-theme2
	git clone ${GIT_QUIET} https://github.com/vinceliuice/grub2-themes.git $t
        if /usr/bin/xrandr --query|/usr/bin/grep -A 1 connected|grep -v connected| grep 2160 > /dev/null 2&>1; then
            R4K='-4'
        fi
	sudo $t/install.sh -b -v -w $R4K > /dev/null 2>&1
	sudo $t/install.sh -b -s $R4K > /dev/null 2>&1
	sudo $t/install.sh -b -l $R4K > /dev/null 2>&1
	sudo $t/install.sh -b -t $R4K > /dev/null 2>&1
	rm -rf $t
}

install_con_fonts() {
    if [ -v WSLENV ]; then
        return
    fi
    show_msg "Running console fonts setup script..."
    curl -LSs "$GIT_REPO/scripts/console-font-setup.sh" | sudo bash -s - $VARG 
}

install_nerd_fonts() {
    if [[ $THEME_ONLY == 'true' ]]; then
        show_msg "${red}Please make sure you have Nerd Font installed on your system.${normal}"
        return
    fi
    if [[ $COMMANDLINE_ONLY == "true" && ! -v WSLENV ]]; then
        show_msg "${red}Please make sure you have Nerd Font installed on your system.${normal}"
        return
    fi
    if [ -v WSLENV ]; then
        for d in /mnt/c/Users/*; do
            DIR="$d/AppData/Local/Microsoft/Windows/Fonts"
            if [ -d "${DIR}" ]; then
               if ls ${DIR}/*Nerd* &> /dev/null; then 
                    echo -e "${green}${bold}Nerd fonts have been found... Skipping installation...${normal}"
                    return
                fi
            fi
        done
    fi
    git clone $GIT_QUIET https://github.com/ryanoasis/nerd-fonts.git --depth=1 /tmp/fonts
    cd /tmp/fonts
    if [ -v WSLENV ]; then
        cp -r /tmp/fonts/patched-fonts /mnt/c/temp
        powershell.exe -ExecutionPolicy Bypass -File c:/temp/patched-fonts/install.ps1
        rm -rf /mnt/c/temp/patched-fonts
    else
        show_msg "Install NerdFonts..."
        sudo ./install.sh --install-to-system-path > /dev/null 2>&1
        cd $STARTPWD
        rm -rf /tmp/fonts
    fi
}

################################
# Main Script body starts here #
################################

# Set default options
COMMANDLINE_ONLY=false
STREAMING=false
VERBOSE=false
PRIVATE=false
WSL=false
NEON=false
FEEDPASER=false
GAMES=true
DESKTOP_THEME=breeze-dark
VM=false
FUNC=false

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
        s | -s | --streaming)           STREAMING=true
                                        ;;
        o | -o | --virtualbox)          VM=true
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

if [[ $NEON == "true" ]]; then
    pkcon_update
else
    apt_update
fi

apt_install
install_antibody
change_shell
install_feedparser
retry_loop "install_lsd"
retry_loop "install_yq"
retry_loop "install_bat"
retry_loop "install_ncspot"
retry_loop "install_xidel"
retry_loop "install_go"

setup_wsl
setup_shims
install_docker

if [[ $COMMANDLINE_ONLY == "false" && $WSL == "false" ]]; then
    show_msg "\n\nSetting up GUI Applications...\n\n"
    install_snaps
    setup_flatpak
    install_chrome
    install_inkscape
    install_discord
    install_libreoffice
    install_vscode
    install_spotify
    install_typora
    if [ $VM == "true" ]; then
        install_virtualbox
    fi
    
    if [[ $STREAMING == "true" ]]; then
        setup_obs
    fi

    if [[ $GAMES == "true" ]]; then
        install_steam
        install_minecraft
    fi
    install_1password

    fix_sddm
    show_msg "\n\nInstalling desktop themes...\n\n"
    if pgrep plasmashell; then
        install_kvantum
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
    show_msg "\n\nDoing some hardware setup...\n\n"
	setup_nvidia_drivers
	install_nvidia_modules_to_initramfs
	setup_openrazer
	setup_streamdeck
    fix-update-grub
	install_grub_themes
    install_con_fonts
fi

if [[ $COMMANDLINE_ONLY == "false" ]]; then
    install_nerd_fonts
fi

# Post install tasks:
if [ ! -f /usr/bin/python ]; then
    show_msg "Linking /usr/bin/python3 to /usr/bin/python..."
    sudo ln -s /usr/bin/python3 /usr/bin/python
fi

cd $STARTPWD

show_msg "\n\nUbuntu Setup Script has finished installing...\n\n"
exit 0
