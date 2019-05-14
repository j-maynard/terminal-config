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

# Font mode for powerlevel9k
P9K_MODE="nerdfont-complete"

# Prompt elements
P9K_LEFT_PROMPT_ELEMENTS=(os_icon custom_user dir dir_writable vcs root_indicator)
#P9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs docker_machine java_version node_version go_version rbenv)
P9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs docker_machine time)

# Prompt settings
P9K_PROMPT_ON_NEWLINE=true
P9K_RPROMPT_ON_NEWLINE=false
P9K_MULTILINE_FIRST_PROMPT_PREFIX_ICON=$'%K{white}%k'
P9K_MULTILINE_LAST_PROMPT_PREFIX_ICON=$'%K{green}%F{black} \uf155 %f%F{green}%k\ue0b0 %f '

# Command Execution time
P9K_COMMAND_EXECUTION_TIME_THRESHOLD='0'

# Separators
P9K_LEFT_SEGMENT_SEPARATOR_ICON=$'\ue0b0'
P9K_LEFT_SUBSEGMENT_SEPARATOR_ICON=$'\ue0b1'
P9K_RIGHT_SEGMENT_SEPARATOR_ICON=$'\ue0b2'
P9K_RIGHT_SUBSEGMENT_SEPARATOR_ICON=$'\ue0b7'

# Dir colours
P9K_DIR_HOME_BACKGROUND='black'
P9K_DIR_HOME_FOREGROUND='white'
P9K_DIR_HOME_SUBFOLDER_BACKGROUND='black'
P9K_DIR_HOME_SUBFOLDER_FOREGROUND='white'
P9K_DIR_DEFAULT_BACKGROUND='yellow'
P9K_DIR_DEFAULT_FOREGROUND='black'
P9K_DIR_SHORTEN_LENGTH=2
P9K_DIR_SHORTEN_STRATEGY="truncate_from_right"

# OS segment
P9K_OS_ICON_BACKGROUND='black'
P9K_LINUX_ICON='%F{cyan} \uf303 %F{white} arch %F{cyan}linux%f'
if [[ "$(uname)" == "Darwin" ]]; then
  P9K_OS_ICON_ICON='\uF535'
fi

# VCS icons
P9K_VCS_GIT_ICON=$'\uf1d2 '
P9K_VCS_GIT_GITHUB_ICON=$'\uf113 '
P9K_VCS_GIT_GITLAB_ICON=$'\uf296 '
P9K_VCS_BRANCH_ICON=$''
P9K_VCS_STAGED_ICON=$'\uf055'
P9K_VCS_UNSTAGED_ICON=$'\uf421'
P9K_VCS_UNTRACKED_ICON=$'\uf00d'
P9K_VCS_INCOMING_CHANGES_ICON=$'\uf0ab '
P9K_VCS_OUTGOING_CHANGES_ICON=$'\uf0aa '

# VCS colours
P9K_VCS_MODIFIED_BACKGROUND='blue'
P9K_VCS_MODIFIED_FOREGROUND='black'
P9K_VCS_UNTRACKED_BACKGROUND='green'
P9K_VCS_UNTRACKED_FOREGROUND='black'
P9K_VCS_CLEAN_BACKGROUND='green'
P9K_VCS_CLEAN_FOREGROUND='black'

# VCS CONFIG
P9K_VCS_SHOW_CHANGESET=false

# Status
P9K_STATUS_OK_ICON=$'\uf164'
P9K_STATUS_ERROR_ICON=$'\uf165'
P9K_STATUS_ERROR_CR_ICON=$'\uf165'

# Battery
P9K_BATTERY_LOW_FOREGROUND='red'
P9K_BATTERY_CHARGING_FOREGROUND='blue'
P9K_BATTERY_CHARGED_FOREGROUND='green'
P9K_BATTERY_DISCONNECTED_FOREGROUND='blue'
P9K_BATTERY_VERBOSE=true

# Programming languages
P9K_RBENV_PROMPT_ALWAYS_SHOW=false
P9K_GO_VERSION_PROMPT_ALWAYS_SHOW=false
P9K_JAVA_VERSION_PROMPT_ALWAYS_SHOW=false
P9K_NODE_VERSION__ALWAYS_SHOW=false
P9K_NODE_VERSION_BACKGROUND='green'
P9K_NODE_VERSION_FOREGROUND='black'

# User with skull
user_with_skull() {
  if [[ "$(whoami)" == "jamesmaynard" ]]; then
    echo -n "\ufb8a jamie"
  else
    echo -n "\ufb8a $(whoami)"
  fi
}

P9K_CUSTOM_USER="user_with_skull"

# Command auto-correction.
ENABLE_CORRECTION="true"

# Command execution time stamp shown in the history command output.
HIST_STAMPS="dd/mm/yyyy"

# Plugins to load
plugins=(git
         gitfast
         golang
         zsh-syntax-highlighting
         zsh-autosuggestions
         zsh-completions
         history-substring-search)

# Activate antibody
source <(antibody init)
antibody bundle < ~/.zsh_plugins.txt
antibody bundle bhilburn/powerlevel9k branch:next

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

# LS with icons when available
which colorls > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    alias ls='colorls'
else
    alias ls='ls --color'
fi

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
