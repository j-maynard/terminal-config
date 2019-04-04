#!/bin/bash

termconfig="${HOME}/.term-config"
loc="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Move term-config files in to place
if [[ "${loc}" != "${termconfig}" ]]; then
    echo "Term config not in the right palce... Moving to ${termconfig}"
    mv ${loc} ${termconfig}
fi

# Remove existing files
if [ -f "${HOME}/.emacs" ]; then
    echo "emacs config exists removing..."
    rm ${HOME}/.emacs
fi

if [ -f "${HOME}/.gitignore_global" ]; then
    echo "gitignore_global config exists removing..."
    rm ${HOME}/.gitignore_global
fi

if [ -f "${HOME}/.iterm2_shell_integration" ]; then
    echo "iterm2_shell_integration config exists removing..."
    rm ${HOME}/.iterm2_shell_integration
fi

if [ -d "${HOME}/.screenfetch" ]; then 
    echo "user screenfetch exists removing..."
  if [ -L "${HOME}/.screenfetch" ]; then
    # It is a symlink!
    rm "${HOME}/.screenfetch"
  else
    # It's a directory!
    rm -rf "${HOME}/.screenfetch"
  fi
fi

if [ -d "${HOME}/.tmux" ]; then 
    echo "tmux config directory exists removing..."
  if [ -L "${HOME}/.tmux" ]; then
    # It is a symlink!
    rm "${HOME}/.tmux"
  else
    # It's a directory!
    rm -rf "${HOME}/.tmux"
  fi
fi

if [ -f "${HOME}/.tmux.conf" ]; then
    echo "tmux.conf config exists removing..."
    rm ${HOME}/.tmux.conf
fi

if [ -f "${HOME}/.tmux-attach.sh" ]; then
    echo "tmux-attach.sh script exists removing..."
    rm ${HOME}/.tmux-attach.sh
fi

if [ -f "${HOME}/.tmux.conf.local" ]; then
    echo "tmux.conf.local config exists removing..."
    rm ${HOME}/.tmux.conf.local
fi

if [ -d "${HOME}/.vim" ]; then 
    echo "vim config directory exists removing..."
  if [ -L "${HOME}/.vim" ]; then
    # It is a symlink!
    rm "${HOME}/.vim"
  else
    # It's a directory!
    rm -rf "${HOME}/.vim"
  fi
fi

if [ -f "${HOME}/.vimrc" ]; then
    echo "vimrc config exists removing..."
    rm ${HOME}/.vimrc
fi

if [ -f "${HOME}/.zsh_plugins.txt" ]; then
    echo "zsh_plugins.txt config exists removing..."
    rm ${HOME}/.zsh_plugins.txt
fi

if [ -f "${HOME}/.zshrc" ]; then
    echo "zshrc config exists removing..."
    rm ${HOME}/.zshrc
fi

# make sure antibody is installed
which antibody
if [ "$?" != 0 ]; then
    echo "antibody not installed.  Installing now..."
    curl -sL git.io/antibody | sh -s
fi

echo "Linking files in place from term-config"
ln -s ${termconfig}/emacs ${HOME}/.emacs
ln -s ${termconfig}/gitignore_global ${HOME}/.gitignore_global
ln -s ${termconfig}/iterm2_shell_integration.zsh ${HOME}/.iterm2_shell_integration
ln -s ${termconfig}/screenfetch ${HOME}/.screenfetch
ln -s ${termconfig}/tmux ${HOME}/.tmux
ln -s ${termconfig}/tmux/.tmux.conf ${HOME}/.tmux.conf
ln -s ${termconfig}/tmux-attach.sh ${HOME}/.tmux-attach.sh
ln -s ${termconfig}/tmux.conf.local ${HOME}/.tmux.conf.local
ln -s ${termconfig}/vimrc ${HOME}/.vimrc
ln -s ${termconfig}/zsh_plugins.txt ${HOME}/.zsh_plugins.txt
ln -s ${termconfig}/zshrc ${HOME}/.zshrc
ln -s ${termconfig}/vim ${HOME}/.vim
