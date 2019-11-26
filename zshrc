test ! -d ~/.zplugin/bin && git clone https://github.com/zdharma/zplugin.git ~/.zplugin/bin
# Get zplugin first: git clone https://github.com/zdharma/zplugin.git ~/.zplugin/bin
# Symlink .zshrc: cd ~; ln -s ~/.zshrc.d/.zshrc

#
# Source files
#
for f in "${HOME}"/.term-config/zsh.d/*.zsh; do
	source "${f}"
done
