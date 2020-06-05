show_msg() {
  echo -e $1 > /dev/tty
}

install_lsd() {
  LSDVER=$(curl -s https://github.com/Peltoche/lsd/tags.atom | xidel -se '//feed/entry[1]/title' - | cut -d' ' -f2)
  case $(uname -m) in
      x86_64)     ARCH=amd64
                  ;;
      armv6l)     ARCH=armv6l
                  ;;
      *)          echo "${red}Can't identify Arch to match to an LSD download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                  return
  esac
  show_msg "Installing the latest version of LSD -> version: ${LSDVER}..."
  wget -q "https://github.com/Peltoche/lsd/releases/download/${LSDVER}/lsd_${LSDVER}_${ARCH}.deb"
  if [ ! -f "lsd_${LSDVER}_${ARCH}.deb" ]; then
      show_msg "${red}Failed to download go... ${normal}${green}Skipping install...${normal}"
      return
  fi
  sudo dpkg -i lsd_${LSDVER}_${ARCH}.deb
}

install_lsd
