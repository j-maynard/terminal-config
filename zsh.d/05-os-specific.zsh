#!/bin/zsh
# Mac Specific
case $(uname) in
  Darwin)     PATH="/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/2.6.0/bin:/usr/local/opt/coreutils/libexec/gnubin:$PATH"
              MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
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
              
  Linux)      # Windows Subsystem for Linux requires some special care
              export PATH="${HOME}/.local/bin:${PATH}"
              export AWS_VAULT_BACKEND=kwallet
              if [ -v WSLENV ]; then
                ${HOME}/.term-config/wingpg/wingpg-connect.sh &
              fi
              ;;
  *)          echo "Unknwon Environment"
              ;;
esac
