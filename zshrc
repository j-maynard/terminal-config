#
# Source files
#

# Automatically update .term-config
# Disable if working on it.
if [[ $AUTO_UPDATE == 'true' ]]; then
    git --git-dir=${HOME}/.term-config/.git pull -q
fi

if [ -f "${HOME}/.term-config/.optional" ]; then
    OPTIONAL=$(cat .optional.txt)
fi

for f in "${HOME}"/.term-config/zsh.d/*.zsh; do
	if [[ " ${OPTIONAL[@]} " =~ " ${f} " ]]; then
		continue
	fi
	source "${f}"
done
