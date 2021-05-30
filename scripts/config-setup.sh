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
    echo -e "  -R  --root-install	      Install for root user using sudo"
    echo -e "  -r  --requirements       Check for required tools and directories"
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
    if [[ $(uname) == "Darwin" ]]; then
	HOME=/Users
    else
	HOME=/home
    fi
    if [ -z $SUDO_USER ]; then
        USERNAME=$USER
    else
        USERNAME=$SUDO_USER
    fi
    if [ $USERNAME == "root" ]; then
	USER_PATH="/root"
    else
        USER_PATH="$HOME/$USER"
    fi
    show_msg "User path is now set to '$USER_PATH'"
}

check_requirements() {
    MSG="${red}Your system doesn't meet the following requirements:\n"

    # Check to make sure the term-config directory is present
    if [ ! -d $TERMCONFIG ]; then
        MSG="${MSG}\t* Terminal configuration directory is not present at: ${bold}${TERMCONFIG}${normal}${red}\n"
        FAIL=true
    fi

    # Make sure everything is installed    
    if which antibody > /dev/null; then
        MSG="${MSG}\t* ${bold}Antibody${normal}${red} is not installed\n"
        FAIL=true
    fi

    if which vim > /dev/null; then
        MSG="${MSG}\t* ${bold}Vim${normal}${red} is not installed\n"
        FAIL=true
    fi

    if which nvim > /dev/null; then
        MSG="${MSG}\t* ${bold}Neovim${normal}${red} is not installed... maybe think about installing it?\n"
    fi

    which git > /dev/null
    if [ "$?" != 0 ]; then
        MSG="${MSG}\t* ${bold}Git${normal}${red} is not installed\n"
        FAIL=true
    fi

    which python > /dev/null
    if [ "$?" != 0 ]; then
        MSG="${MSG}\t* ${bold}Python${normal}${red} is not installed\n"
        FAIL=true
    fi

    which zsh > /dev/null
    if [ "$?" != 0 ]; then
        MSG="${MSG}\t* ${bold}ZSH${normal}${red} is not installed\n"
        FAIL=true
    fi

    if [ FAIL == 'true' ]; then
        show_msg "${MSG}${normal}"
        show_msg "You'll need to fix the requirements before running this script"
        if [ $SHOW_ONLY == 'true' ]; then
            exit 1
        else
            exit 0
        fi
    fi
}

disable_optional() {
    # RBenv and Jenv should be present
    # If they are missing then we disable their inits
    if [[ $(uname -a) == 'Linux' ]]; then
        if [ ! -d "${USER_PATH}/.jenv" ]; then
            echo "06-java.zsh" >> "${TERMCONFIG}/.optional.txt"
        fi
    fi
    if [ ! -d "${USER_PATH}/.rbenv" ]; then
        echo "07-ruby.zsh" >> "${TERMCONFIG}/.optional.txt"
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

  if [ -L "${USER_PATH}/.vimrc" ]; then
    show_msg "Link to config file '.vimrc' exists... removing..."
    rm ${USER_PATH}/.vimrc
  elif [ -f "${USER_PATH}/.vimrc" ]; then
    show_msg "config file '.vimrc' already exists... moving to ~/dot-backup/vimrc..."
    mkdir -p $DOT_BACKUP
    mv ${USER_PATH}/.vimrc $DOT_BACKUP/.vimrc
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
  ln -s ${TERMCONFIG}/vim/init.vim ${USER_PATH}/.vimrc
}

setup_fzf() {
  show_msg "Installing FZF..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ${USER_PATH}/.fzf
  ${USER_PATH}/.fzf/install
}

setup_vim() {
    show_msg "Installing vim.pathogen..."
    mkdir -p ${TERMCONFIG}/vim/autoload ${TERMCONFIG}/vim/bundle
    curl -LSso ${TERMCONFIG}/vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

    if which nvim > /dev/null; then
        show_msg "Setting up shared Vim / Neovim config"
        mkdir -p "${USER_PATH}/.config"
        ln -s "${TERMCONFIG}/vim" "${USER_PATH}/.config/nvim"
    fi

    show_msg "Pulling git submodules..."
    git -C ${TERMCONFIG} submodule init
    git -C ${TERMCONFIG} submodule update --recursive --remote
}

setup_git() {
    show_msg "Adding recommit to git"
    git config --global alias.recommit '!git commit -eF $(git rev-parse --git-dir)/COMMIT_EDITMSG'
}

configFiles=("streamdeck_ui.json" "emacs" "gitignore_global" "iterm2_shell_integration.zsh" "tmux" "tmux.conf.local" "zsh_plugins.txt" "zprofile" "zshenv" "zshrc" "vim" "mutt" "gitconfig")
VERBOSE=false
SHOW_ONLY=false
TERMCONFIG="${USER_PATH}/.term-config"

while [ "$1" != "" ]; do
    case $1 in
        -c | --term-config)     shift
                                TERMCONFIG=$1
				C=true
                                ;;
	-d | --docker-user)	USER=jamie
				;;
	-R | --root-user)	USER=root
				SUDO_USER=root
				if [ -z $C ]; then
					TERMCONFIG="${USER_PATH}/.term-config"
				fi
				;;
        -r | --requirements)    SHOW_ONLY=true
                                check_requirements
                                exit 0
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

set_username
check_requirements
remove_existing
link_files
setup_fzf
setup_git
setup_vim
disable_optional

show_msg "Terminal Config setup run sucessfully."
