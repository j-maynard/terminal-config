setopt promptsubst         # Allow funky stuff in prompt
setopt autocd              # cd to directory if it's put in on cli
setopt auto_list           # ambiguous = list
setopt auto_pushd          # cd = pushd
setopt hash_list_all       # Hash everything before completion
setopt always_to_end       # When completing from the middle of a word, move the cursor to the end of the word
setopt list_ambiguous      # Complete as much of a completion until it gets ambiguous.
setopt auto_menu           # show menu with double tab
setopt complete_in_word    # allows completion midway through a word
setopt hist_ignore_dups    # Ignore consecutive duplicates.
setopt hist_reduce_blanks  # Trim blanks
setopt share_history       # shared history between tabs
setopt interactivecomments # Treat '#' on cli as a comment
setopt chase_links         # Resolve symlinks


HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/jamie/.zshrc'

autoload -Uz compinit
compinit
