#
# Source files
#
OPTIONAL=$(cat .optional.txt)
for f in "${HOME}"/.term-config/zsh.d/*.zsh; do
	if [[ " ${OPTIONAL[@]} " =~ " ${f} " ]]; then
		continue
	fi
	source "${f}"
done
