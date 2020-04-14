#
# Source files
#
for f in "${HOME}"/.term-config/zsh.d/*.zsh; do
	source "${f}"
done
export PATH="$HOME/.rbenv/bin:$PATH"
