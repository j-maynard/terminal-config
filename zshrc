# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
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

# Mac Specific
case $(uname) in
  Darwin)
    which java > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
    # Set up multiple Java installs
        export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
        export JAVA_11_HOME=$(/usr/libexec/java_home -v11)
        alias java8='export JAVA_HOME=$JAVA_8_HOME'
        alias java11='export JAVA_HOME=$JAVA_11_HOME'
    fi
    PATH="/opt/local/bin:/opt/local/sbin:/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/2.6.0/bin:/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
    eval "$(rbenv init -)"
    ;;
  Linux)
    # Set up multiple Java installs
    # Setup jEnv on linux
    which java > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        export PATH="$HOME/.jenv/bin:$PATH"
        eval "$(jenv init -)"
        alias java8='jenv global 1.8'
        alias java11='jenv global 11.0'
    fi
    ;;
  # Linux Specific
  *)
    echo "Unknwon Environment"
    ;;
esac

alias ls='ls --color'
alias tree='tree -C'
which docker > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    alias browsh="docker run -e 'browsh_supporter=I have shown my support for Browsh' -it --rm browsh/browsh"
fi
# Git aliases
which git > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    alias ga='git add'
    alias gc='git commit'
    alias gr='git rm --cache'
    alias gi='git init'
    alias gclone='git clone'
    alias greset='git reset'
    alias glog='git log'
    alias gdiff='git diff'
    alias gstat='git status'
    alias push='git push'
    alias pull='git pull'
    alias groot='groot=$(git rev-parse --show-toplevel);cd $groot'
fi

which java > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    java11
fi

export EXIT_SESSION=0
if [[ -z "$TMUX" ]]; then
  ~/.term-config/tmux-attach.sh
  if [[ "$?" == "0" ]]; then
    echo "Script exited 0"
    exit
  elif [[ "$?" == "666" ]]; then
     "Script exited 666"
    ~/.screenfetch/screenfetch-dev -a ~/.screenfetch/ft.txt
  fi
fi
