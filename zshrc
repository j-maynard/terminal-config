#
# Source files
#

if [ -f "${HOME}/.term-config/.optional" ]; then
    OPTIONAL=$(cat .optional.txt)
fi

for f in "${HOME}"/.term-config/zsh.d/*.zsh; do
	if [[ " ${OPTIONAL[@]} " =~ " ${f} " ]]; then
		continue
	fi
	source "${f}"
done

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
test -e /Users/jamesmaynard/.iterm2_shell_integration.zsh && source /Users/jamesmaynard/.iterm2_shell_integration.zsh || true
