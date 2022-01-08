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
    echo -e "  ${bold}${red}-d  --no-docker${normal}              Don't install docker."
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
        sudo pip3 install feedparser > /dev/null 2>&1
        export FEEDPASER=true
    fi
}

get_version() {
    echo -e "import feedparser\nd=feedparser.parse('$1')\nprint(d.entries[0].title)\n" | python3 -
}

get_deb() {
    echo "import html5lib, requests; print(html5lib.parse(requests.get('$1').text, treebuilder='lxml', namespaceHTMLElements=False).xpath(\"/html/body//a[contains(@href, 'deb')]/@href\")[0])" | python3
}

setup_ppas() {   
    if [[ $COMMANDLINE_ONLY == "false" && ! -v WSLENV ]]; then
        if which plasmashell >/dev/null 2>&1; then
        show_msg "Setting up PPA for KDA Plasma backports..."
            sudo add-apt-repository -y ppa:kubuntu-ppa/backports
        fi
    fi
    show_msg "Setting up PPA for Git..."
    add-apt-repository -y  ppa:git-core/ppa
}

apt_update() {
    show_msg "Updating the system..."
    sudo apt-get update
    if [[ $SECUREBOOT == "true" ]]; then
        exec > /dev/tty
        sudo apt-get upgrade -y
        if [ $VERBOSE == "false" ]; then
            exec > /dev/null
        fi
    else
        sudo apt-get upgrade -y
    fi
}

apt_install() {
    show_msg "Installing from apt... "

    apt_pkgs=( "git" "curl" "zsh"  "python3.9-dev" "python3-pip" 
        "build-essential" "jed" "htop" "links" "lynx" "tree" "tmux" 
        "openjdk-11-jdk" "maven" "vim" "vim-nox"
        "vim-scripts" "most" "ruby-dev" "scdaemon" "pinentry-tty"
        "pinentry-curses" "libxml2-utils" "apt-transport-https"
	    "neovim" "libgconf-2-4"  "clamav"
        "default-jdk" "jq" "gnupg2" "libssl-dev" )
	
    recent_pkgs=( "openjdk-17-jdk" "python3.10-dev" "python3.10" )

    x_apt_pkgs=( "idle-python3.9" "vim-gtk3" "libappindicator3-1" "libappindicator1" "libc++1"
        "flatpak" "gnome-keyring" "materia-gtk-theme" "gtk2-engines-murrine" "libgdk-pixbuf2.0-0"
	    "gtk2-engines-pixbuf" "lm-sensors" "nvme-cli" "conky-all" "gdebi-core" )

    x_recent_pkgs=( "idle-python3.10" )

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
        
		if which plasmashell >/dev/null 2>&1; then
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
    if [[ $SECUREBOOT == "true" ]]; then
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
        arm64)      ARCH=arm64
                    ;;
        aarch64)    ARCH=arm64
                    ;;
        *)          echo "${red}Can't identify Arch to match to an LSD download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    show_msg "Installing the latest version of LSD -> version: ${LSDVER}..."
    wget -q -O /tmp/lsd_${LSDVER}_${ARCH}.deb "https://github.com/Peltoche/lsd/releases/download/${LSDVER}/lsd_${LSDVER}_${ARCH}.deb"
    if [ ! -f "/tmp/lsd_${LSDVER}_${ARCH}.deb" ]; then
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
        armf)       ARCH=arm
                    ;;
        arm64)      ARCH=arm64
                    ;;
        aarch64)    ARCH=arm64
                    ;;
        *)          echo "${red}Unable to match arch to an available download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    show_msg "Installing the latest version of yq -> version: ${YQVER}..."
    wget -q -O /tmp/yq_linux_${ARCH}.tar.gz "https://github.com/mikefarah/yq/releases/download/${YQVER}/yq_linux_${ARCH}.tar.gz"
    if [ ! -f "/tmp/yq_linux_${ARCH}.tar.gz" ]; then
        show_msg "${red}Failed to download yq... ${normal}${green}Skipping install...${normal}"
        return 1
    fi
    tar -zxf /tmp/yq_linux_${ARCH}.tar.gz --directory /tmp
    sudo mv /tmp/yq_linux_${ARCH} /usr/local/bin/yq
    sudo /tmp/install-man-page.sh
    if which yq > /dev/null; then
        rm /tmp/yq*
        rm /tmp/install-man-page.sh
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
        aarch64)    ARCH=arm64
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
        aarch64)    ARCH=arm64
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
        x86_64)     ARCH=x86_64
                    ;;
        aarch64)    ARCH=arm64
                    ;;
        *)          echo "${red}ncspot only runs on AMD64 Linux.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    show_msg "Installing the latest version of ncspot -> version: ${SPOTVER}..."
    wget -q -O /tmp/ncspot-v${SPOTVER}-linux-${ARCH}.tar.gz "https://github.com/hrkfdn/ncspot/releases/download/v${SPOTVER}/ncspot-v${SPOTVER}-linux-${ARCH}.tar.gz"
    if [ ! -f "/tmp/ncspot-v${SPOTVER}-linux-${ARCH}.tar.gz" ]; then
        show_msg "${red}Failed to download ncspot... ${normal}${green}Skipping install...${normal}"
        return 1
    fi
    tar -zxf "/tmp/ncspot-v${SPOTVER}-linux-${ARCH}.tar.gz" --directory /tmp
    sudo mv /tmp/ncspot /usr/local/bin
    if which ncspot > /dev/null; then
        rm /tmp/ncspot-v${SPOTVER}-linux-${ARCH}.tar.gz
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
        rm /tmp/xidel_${XIVER}-1_${ARCH}.deb
        return 0
    else
        show_msg "Failed to install Xidel XML Parser."
        return 1
    fi
}

install_aws_cli() {
    case $(uname -m) in
        x86_64)     ARCH=x86_64
                    ;;
        arm64)      ARCH=aarch64
                    ;;
        aarch64)    ARCH=arm64
                    ;;
        *)          echo "${red}Can't identify Arch to match to an aws cli download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    show_msg "Installing AWS CLI..."
    wget -q -O /tmp/awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip"
    unzip /tmp/awscliv2.zip -d /tmp
    sudo /tmp/aws/install
}

install_aws_sam() {
    show_msg "Installing AWS SAM..."  
    case $(uname -m) in
        x86_64)     ARCH=x86_64
                    wget -q -O /tmp/aws-sam-cli-linux-${ARCH}.zip "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-${ARCH}.zip"
                    unzip /tmp/aws-sam-cli-linux-${ARCH}.zip -d /tmp/sam
                    sudo /tmp/sam/install
                    ;;
        arm64)      ARCH=arm64
                    sudo pip install aws-sam-cli
                    ;;
        aarch64)    ARCH=arm64
                    sudo pip install aws-sam-cli
                    ;;
        *)          echo "${red}Can't identify Arch to match to an aws sam download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac 
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
        aarch64)    ARCH=arm64
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

install_docker_compose() {
    install_feedparser
    COMPVER=$(get_version https://github.com/docker/compose/releases.atom)
    case $(uname -m) in
        x86_64)     ARCH=x86_64
                    ;;
        arm64)      ARCH=aarch64
                    ;;
        *)          show_msg "${red}Can't identify Arch to match to a docker-compose download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    show_msg "Installing the latest version of docker-compose -> version: ${COMPVER}..."
    wget -q -O /tmp/docker-compose-linux-${ARCH} "https://github.com/docker/compose/releases/download/${COMPVER}/docker-compose-linux-${ARCH}"
    if [ ! -f "/tmp/docker-compose-linux-${ARCH}" ]; then
        show_msg "${red}Failed to download docker-compose... ${normal}${green}Skipping install...${normal}"
        return 1
    fi
    chmod +x /tmp/docker-compose-linux-${ARCH}
    sudo mv /tmp/docker-compose-linux-${ARCH} /usr/local/bin/docker-compose
    if which docker-compose > /dev/null; then
        return 0
    else
        show_msg "Failed to install docker compose"
        return 1
    fi
}

install_docker() {
    show_msg "Installing Docker Community Edition..."
    case $(uname -m) in
        x86_64)     ARCH=amd64
                    ;;
        arm64)      ARCH=aarch64
                    ;;
        aarch64)    ARCH=arm64
                    ;;
        *)          show_msg "${red}Can't identify Arch to match to a docker-compose download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
  "deb [arch=${ARCH} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    if [ $? ]; then
        show_msg "Docker installed successfully"
    fi
    sudo usermod -a -G docker $USERNAME
    show_msg "Installing docker-compose..."
    install_docker_compose
}

install_chrome() {
    if ! which google-chrome > /dev/null; then
        case $(uname -m) in
            x86_64)     ARCH=x64
                        ;;
            *)          echo "${red}Can't identify Arch to match to a Chrome download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                        return
        esac
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
        case $(uname -m) in
            x86_64)     ARCH=x64
                        ;;
            *)          echo "${red}Can't identify Arch to match to a Spotify download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                        return
        esac
        curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | sudo apt-key add - 
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
        case $(uname -m) in
            x86_64)     ARCH=x64
                        ;;
            *)          echo "${red}Can't identify Arch to match to a 1Password download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                        return
        esac
        wget -q -O /tmp/1password-latest.deb "https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb"
        if [ ! -f "/tmp/1password-latest.deb" ]; then
            show_msg "${red}Failed to download 1Password Deb Package... ${normal}${green}Skipping install...${normal}"
            return
        fi
        sudo dpkg -i /tmp/1password-latest.deb > /dev/null
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
    #sudo apt-get install --fix-broken
}

install_discord() {
    if ! which discord; then
        show_msg "Installing Discord (Latest)..."
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
        arm64)      ARCH=arm64
                    ;;
        *)          echo "${red}Can't identify Arch to match to an VS Code download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return
    esac
    wget -q -O /tmp/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-${ARCH}"
    sudo dpkg -i /tmp/vscode.deb >/dev/null
    if which code >/dev/null; then
        rm /tmp/vscode.deb
    else
        echo "Unable to install Visual Studio Code"
    fi
}

install_obsidian() {
    show_msg "Installing Obsidian..."
    case $(uname -m) in
        x86_64)     ARCH=x64
                    ;;
        *)          echo "${red}Obsidian only supports X86 on Ubuntu.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return
    esac
    DEB=$(get_deb "https://obsidian.md/download")
    wget -q -O /tmp/obsidian.deb $DEB
    if [ ! -f /tmp/obsidian.deb ]; then
        show_msg "${red}Error:${normal} Failed to download obsidian from ${DEB}."
    fi
    sudo dpkg -i /tmp/obsidian.deb
    if [[ $? == 0 ]]; then
        rm /tmp/obsidian.deb
    else
        show_msg "${red}Error:${normal} Failed to install obsidian."
    fi
}

install_slack() {
    show_msg "Installing Slack..."
    case $(uname -m) in
        x86_64)     ARCH=x64
                    ;;
        *)          echo "${red}Error:${normal} Slack only supports X86 on Ubuntu.  Arch = $(uname -m)... ${green}Skipping...${normal}"
                    return
    esac
    DEB=$(get_deb "https://slack.com/intl/en-gb/downloads/instructions/ubuntu")
    wget -q -O /tmp/slack.deb $DEB
    if [ ! -f /tmp/slack.deb ]; then
        show_msg "${red}Error:${normal} Failed to download slack from ${DEB}."
    fi
    sudo dpkg -i /tmp/slack.deb
    if [[ $? == 0 ]]; then
        rm /tmp/slack.deb
    else
        show_msg "${red}Error:${normal} Failed to install slack."
    fi
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
    if [[ $SECUREBOOT == "true" ]]; then
        exec > /dev/tty
        sudo apt-get install -y obs-studio
        if [ $VERBOSE == "false" ]; then
            exec > /dev/null
        fi
    else
        sudo apt-get install -y obs-studio > /dev/null
    fi
    # Disabling doing the modprobe at this stage.
    # sudo modprobe v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
    echo 'v4l2loopback' | sudo tee -a /etc/modules > /dev/null
    echo 'options v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1' | sudo tee - /etc/modprobe.d/v4l2loopback.conf > /dev/null
}

setup_nvidia_drivers() {
	if lspci |grep NVIDIA > /dev/null; then
		show_msg "${green}Checking NVIDIA driver status...${normal}"
		if ! lsmod |grep nvidia_uvm; then
			show_msg "${red}Installing NVIDIA Propriatory drivers...${normal}"
			if [[ $SECUREBOOT == "true" ]]; then
				exec > /dev/tty
				sudo ubuntu-drivers autoinstall
				if [ $VERBOSE == "false" ]; then
					exec > /dev/null
				fi
			else
				sudo ubuntu-drivers autoinstall > /dev/null
			fi
		fi
	fi
}

install_nvidia_modules_to_initramfs() {
    if lspci |grep NVIDIA > /dev/null; then
        echo -e "nvidia\nnvidia_modeset\nnvidia_uvm\nnvidia_drm" | sudo tee -a /etc/initramfs-tools/modules
    fi
}

setup_openrazer() {
    if lsusb |grep 1532 > /dev/null 2>&1; then
        show_msg "Razer Hardware Detected... Applying Xorg Conf File"
        wget -q -O /tmp/11-razer.conf "https://raw.githubusercontent.com/j-maynard/terminal-config/main/lib/11-razer.conf"
        sudo mv /tmp/11-razer.conf /etc/X11/xorg.conf.d/

        show_msg "Razer Hardware Detected... Installing OpenRazer..."
        sudo add-apt-repository -y ppa:openrazer/daily

        if [[ $SECUREBOOT == "true" ]]; then
            exec > /dev/tty
            sudo apt-get install -y openrazer-meta
            if [ $VERBOSE == "false" ]; then
                exec > /dev/null
            fi
        else
            sudo apt-get install -y openrazer-meta > /dev/null
        fi

        if [[ $COMMANDLINE_ONLY == "false" ]]; then
            # Add RazerGenie Repo
            echo 'deb http://download.opensuse.org/repositories/hardware:/razer/xUbuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/hardware-razer.list
            curl -LSso /tmp/razergenie.key https://download.opensuse.org/repositories/hardware:/razer/xUbuntu_20.04/Release.key
            sudo apt-key add /tmp/razergenie.key
            # Add Polychromatic Repo
            sudo add-apt-repository -y ppa:polychromatic/stable 
            # Install Both
            sudo apt-get update > /dev/null
            sudo apt-get install -y polychromatic razergenie > /dev/null
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

fix-update-grub() {
# As there is no accurate way to detect Kubuntu from Ubuntu
	# We look for plasmashell instead and then assume its Kubuntu.
	if which plasmashell > /dev/null; then
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
	t=/root/grub2-theme2
	git clone ${GIT_QUIET} https://github.com/vinceliuice/grub2-themes.git $t
    if [[ $SCREEN_4K == "true" ]]; then
        R4K='-s 4k'
    fi
	sudo ${t}/install.sh -b -i whitesur -t whitesur ${R4K} > /dev/null 2>&1
}

install_con_fonts() {
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

post_system_install() {
    show_msg "Setting up Plymouth..."
    sudo apt-get install -y plymouth-theme-spinner plymouth-theme-breeze plymouth-themes > /dev/null
    sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/bgrt/bgrt.plymouth > /dev/null
    show_msg "Setting up crypttab..."
    CRYPT_DEVICE=$(lsblk --json -o name,type,mountpoint | jq '.blockdevices[] | .children[]? | select(.children[]?.type == "crypt") | .name' | cut -d '"' -f 2)
    BLKID=$(sudo blkid /dev/${CRYPT_DEVICE} | cut -d ' ' -f 2 | cut -d '"' -f 2)
    sudo echo "$(cat /etc/hostname)_crypt UUID=${BLKID} none luks,discard" | tee -a /etc/crypttab
    update-initramfs -k all -c
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
FUNC=false
SCREEN_4K=true
SECUREBOOT=false
NODOCKER=false

# Process commandline arguments
while [ "$1" != "" ]; do
    case $1 in
		d | -d | --no-docker)           NODOCKER=true
                                        ;;
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

if [[ $SECUREBOOT == "true" ]]; then
    SECUREBOOT=true
fi

set_username

if [[ $FUNC == "true" ]]; then
    $FUNC_NAME
    exit $?
fi

setup_ppas
apt_update
apt_install
install_feedparser
retry_loop "install_lsd"
retry_loop "install_yq"
retry_loop "install_bat"
retry_loop "install_ncspot"
retry_loop "install_xidel"
retry_loop "install_glow"
retry_loop "install_go"
install_aws_cli

if [ -v WSLENV ]; then
    show_msg "Skipping Docker install as this should be done through Windows Docker Desktop..."
elif [[ $NODOCKER == "true" ]]; then
    show_msg "Skipping Docker install..."
else
    install_docker
    install_aws_sam
fi

if [[ $COMMANDLINE_ONLY == "false" && $WSL == "false" ]]; then
    show_msg "\n\nSetting up GUI Applications...\n\n"
    install_chrome
    install_inkscape
    install_discord
    install_libreoffice
    install_vscode
    install_spotify
    
    if [[ $OBS == "true" ]]; then
        setup_obs
    fi

    if [[ $GAMES == "true" ]]; then
        install_steam
        install_minecraft
    fi
    install_1password

    fix_sddm
    if pgrep plasmashell; then
        install_kvantum
    fi
fi

if [[ $WSL == "false" ]]; then
    show_msg "\n\nDoing some hardware setup...\n\n"
	setup_nvidia_drivers
	install_nvidia_modules_to_initramfs
	setup_openrazer
    fix-update-grub
	install_grub_themes
    install_con_fonts
    post_system_install
fi

if [[ $COMMANDLINE_ONLY == "false" ]]; then
    install_nerd_fonts
fi

cd $STARTPWD

echo script_run = true | sudo tee /etc/post-install-script-run > /dev/null
if [[ $USERNAME == "root" ]]; then
    rm -r /tmp/*
fi
show_msg "\n\nUbuntu Setup Script has finished installing...\n\n"
exit 0
