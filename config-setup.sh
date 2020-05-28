#!/bin/bash
SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`

# Define colors and styles
normal="\033[0m"
bold="\033[1m"
green="\e[32m"
red="\e[31m"
yellow="\e[93m"

usage() {
    echo -e "Usage:"
    echo -e "  -c  --term-config        Location of config files"
    echo -e "                           (Normally ~/.term-config)"
    echo -e "  -V  --verbose            Shows command output for debugging"
    echo -e "  -v  --version            Shows version details"
    echo -e "  -h  --help               Shows this usage message"
}

version() {
    echo "Dot Files Setup Script Version 0.5"
    echo "(c) Jamie Maynard 2020"
}

show_msg() {
    echo -e $1 > /dev/tty
}

set_username() {
    if [ -z $SUDO_USER ]; then
        $USERNAME=$USER
    else
        $USERNAME=$SUDO_USER
    fi
    if [ $USERNAME == "root" ]; then
        $USER_PATH="/root"
    else
        $USER_PATH="/home/$USER"
    fi
}

remove_existing() {
  DOT_BACKUP="${USER_PATH}/dot-backup"
  if [ -d $DOT_BACKUP ]; then
    DOT_BACKUP=${USER_PATH}/dot-backup`ls -A -d dot-backup* | wc -l`
  fi

  for FILE in ${configFiles[@]}; do
    #show_msg "Checking $FILE"
    FILE_PATH="${USER_PATH}/.${FILE}"
    if [ -L $FILE_PATH ]; then
      show_msg "Link to config file '.${FILE}' exists... removing..."
      rm $FILE_PATH
    elif [[ -L $FILE_PATH && -d $FILE_PATH ]]; then
      show_msg "Link to config directory '.${FILE}' exists... removing..."
      rm $FILE_PATH
    elif [ -f $FILE_PATH ]; then
      show_msg "config file '.${FILE}' already exists... moving to ~/dot-backup/${FILE}..."
      mkdir -p $DOT_BACKUP
      mv $FILE_PATH $DOT_BACKUP/${FILE}
    elif [ -d $FILE_PATH ]; then
      show_msg "config directory '.${FILE}' already exists... moving to ~/dot-backup/${FILE}..."
      mkdir -p $DOT_BACKUP
      mv $FILE_PATH $DOT_BACKUP/${FILE}
    elif [ ! -f $FILE_PATH ]; then
      continue
    else
      show_msg "The object at ${FILE_PATH} doesn't seem to be a file, link or directory.  Exiting..."
      exit 1
    fi
  done
  
  # Edge cases go here
  if [ -L "${USER_PATH}/.tmux.conf" ]; then
    show_msg "Link to config file '.tmux.conf' exists... removing..."
    rm ${USER_PATH}/.tmux.conf
  elif [ -f "${USER_PATH}/.tmux.conf" ]; then
    show_msg "config file '.tmux.conf' already exists... moving to ~/dot-backup/tmux.conf..."
    mkdir -p $DOT_BACKUP
    mv ${USER_PATH}/.tmux.conf $DOT_BACKUP/.tmux.conf
  fi

  #Check back up directory for size... if empty remove it
  if [ -n "$(ls -A $DOT_BACKUP/* 2>/dev/null)" ]; then
    exec > /dev/tty 
    echo ""
    while true; do
        read -p "Existing config files were found... Do you want to keep them?" yn
        case $yn in
            [Yy]* )   echo -e "You can check the files at $DOT_BACKUP"
                      break
                      ;;
            [Nn]* )   rm -rf $DOT_BACKUP
                      break
                      ;;
            * )       echo "Please answer yes or no."
                      ;;
        esac
    done
    if [ $VERBOSE == "false" ]; then
      exec > /dev/null
    fi
  fi
}

link_files() {
  show_msg "Linking files in place from term-config"
  for FILE in ${configFiles[@]}; do
    show_msg "Linking ${TERMCONFIG}/$FILE to ${USER_PATH}/.${FILE}"
    ln -s "${TERMCONFIG}/$FILE" "${USER_PATH}/.${FILE}"
  done

  # Edge Cases go here
  ln -s ${TERMCONFIG}/tmux/.tmux.conf ${USER_PATH}/.tmux.conf
}

configFiles=("emacs" "gitignore_global" "iterm2_shell_integration.zsh" "tmux" "tmux.conf.local" "vimrc" "zsh_plugins.txt" "zprofile" "zshenv" "zshrc" "vim" "mutt")
VERBOSE=false
set_username
TERMCONFIG="${USER_PATH}/.term-config"
while [ "$1" != "" ]; do
    case $1 in
        -c | --term-config)     shift
                                TERMCONFIG=$1
                                ;;
        -V | --verbose)         VERBOSE=true
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

if [ $VERBOSE == "false" ]; then
    echo "Silencing output"
    exec > /dev/null 
fi

# Move term-config in to the right place
if [[ "${SCRIPTPATH}" != "${TERMCONFIG}" ]]; then
    show_msg "Termal config directory is not in the right palce... Moving to ${TERMCONFIG}"
    mv ${SCRIPTPATH} ${TERMCONFIG}
fi

remove_existing
link_files

# make sure antibody is installed
which antibody
if [ "$?" != 0 ]; then
    show_msg "Antibody is not installed.  Installing now..."
    curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin
fi

show_msg "Installing vim.pathogen..."
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

show_msg "Install Vim plugins..."
if [ ! -d "${USER_PATH}/.term-config/vim/bundle/vim-sensible" ]; then
  git clone -q https://github.com/tpope/vim-sensible.git "${USER_PATH}/.term-config/vim/bundle/vim-sensible"
fi

if [ ! -d "${USER_PATH}/.term-config/vim/bundle/git-gutter" ]; then
  git clone -q git://github.com/airblade/vim-gitgutter.git "${USER_PATH}/.term-config/vim/bundle/git-gutter"
fi

if [ ! -d "${USER_PATH}/.term-config/vim/bundle/nerdtree" ]; then
  git clone -q https://github.com/scrooloose/nerdtree.git "${USER_PATH}/.term-config/vim/bundle/nerdtree"
fi

if [ ! -d "${USER_PATH}/.term-config/vim/bundle/nerdtree-git-plugin" ]; then
  git clone -q https://github.com/Xuyuanp/nerdtree-git-plugin.git "${USER_PATH}/.term-config/vim/bundle/nerdtree-git-plugin"
fi

show_msg "Terminal Config setup run sucessfully."
