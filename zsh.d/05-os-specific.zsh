#!/bin/zsh
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
    PATH="/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/2.6.0/bin:/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
    eval "$(rbenv init -)"
    eval "$(nodenv init -)"
    gpg-agent > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
      eval $(gpg-agent --daemon)
    fi
    if [ -f "${HOME}/.gpg-agent-info" ]; then
        . "${HOME}/.gpg-agent-info"
        export GPG_AGENT_INFO
        export SSH_AUTH_SOCK
    fi
    ;;
  Linux)
    # Set up multiple Java installs
    # Setup jEnv on linux
    which java > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        export PATH="$HOME/bin:$HOME/.jenv/bin:$PATH"
        eval "$(jenv init -)"
        alias java8='jenv global 1.8'
        alias java11='jenv global 11.0'
    fi

    #Set up snaps on linux
    if [[ $(uname) == 'Linux' ]]; then
        emulate sh -c 'source /etc/profile.d/01-locale-fix.sh'
        emulate sh -c 'source /etc/profile.d/apps-bin-path.sh'
        emulate sh -c 'source /etc/profile.d/flatpak.sh'
        emulate sh -c 'source /etc/profile.d/input-method-config.sh'
    fi
    ;;
  # Linux Specific
  *)
    echo "Unknwon Environment"
    ;;
esac
