# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/jamie/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
source <(antibody init)
antibody bundle < ~/.zsh_plugins.txt
SPACESHIP_CHAR_SYMBOL="➽  "
SPACESHIP_USER_SHOW="always"
SPACESHIP_HOST_SHOW="always"
SPACESHIP_HOST_PREFIX="on "
SPACESHIP_TIME_SHOW=true
SPACESHIP_PROMPT_ORDER=(
  # time          # Time stamps section
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  hg            # Mercurial section (hg_branch  + hg_status)
  package       # Package version
  node          # Node.js section
  ruby          # Ruby section
  elixir        # Elixir section
  xcode         # Xcode section
  swift         # Swift section
  golang        # Go section
  php           # PHP section
  rust          # Rust section
  haskell       # Haskell Stack section
  julia         # Julia section
  docker        # Docker section
  aws           # Amazon Web Services section
  venv          # virtualenv section
  conda         # conda virtualenv section
  pyenv         # Pyenv section
  dotnet        # .NET section
  ember         # Ember.js section
  kubecontext   # Kubectl context section
  exec_time     # Execution time
  line_sep      # Line break
  battery       # Battery level and status
  vi_mode       # Vi-mode indicator
  # jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)
SPACESHIP_RPROMPT_ORDER=(
  time
  jobs
)

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

alias ls='ls --color'
alias tree='tree -C'
PATH="/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/2.6.0/bin:/usr/local/opt/coreutils/libexec/gnubin:$PATH"
MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
alias ls='ls --color'
alias tree='tree -C'
alias browsh="docker run -e 'browsh_supporter=I have shown my support for Browsh' -it --rm browsh/browsh"
eval "$(rbenv init -)"
# Set up multiple Java installs
export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
export JAVA_11_HOME=$(/usr/libexec/java_home -v11)
alias java8='export JAVA_HOME=$JAVA_8_HOME'
alias java11='export JAVA_HOME=$JAVA_11_HOME'
java11

export EXIT_SESSION=0
if [[ -z "$TMUX" ]]; then
  ./.tmux-attach.sh
  if [[ "$?" == "0" ]]; then
    echo "Script exited 0"
    exit
  elif [[ "$?" == "666" ]]; then
    echo "Script exited 666"
    ~/.screenfetch/screenfetch -a ~/.screenfetch/ft.txt
  fi
fi

# if [[ -n $TMUX_PANE ]]; then
#   if [[ "$TMUX_PANE" == "%0" ]]; then
#     ~/.screenfetch/screenfetch -a ~/.screenfetch/ft.txt
#   fi
# else
#     ~/.screenfetch/screenfetch -a ~/.screenfetch/ft.txt
# fi