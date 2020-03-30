#!/bin/bash
if [[ -f "$HOME/.term-config-run.lock" ]]; then
    echo "Termal Config Setup already run.  Exiting..."
    exit 0
fi

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

if [ -d "${HOME}/.mutt" ]; then 
    echo "mutt config directory exists removing..."
  if [ -L "${HOME}/.mutt" ]; then
    # It is a symlink!
    rm "${HOME}/.mutt"
  else
    # It's a directory!
    rm -rf "${HOME}/.mutt"
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
ln -s ${termconfig}/mutt ${HOME}/.mutt

echo "Installing vim.pathogen..."
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

echo "Install Vim plugins..."
git clone https://github.com/tpope/vim-sensible.git ~/.vim/bundle/vim-sensible
git clone git://github.com/airblade/vim-gitgutter.git ~/vim/bundle/git-gutter
git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree
git clone https://github.com/Xuyuanp/nerdtree-git-plugin.git ~/.vim/bundle/nerdtree-git-plugin

echo "Install Vim colors..."
mkdir -p ~/.vim/colors
scp jamie@home:/home/jamie/.vim/colors/dracula.vim ~/.vim/colors/dracula.vim

touch "$HOME/.term-config-run.lock"
echo "Terminal Config setup run sucessfully."
