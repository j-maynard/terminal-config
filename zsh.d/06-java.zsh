#!/bin/zsh
which java > /dev/null 2>&1
if [[ $? > 0 ]]; then
    return
fi

case $(uname) in

  Darwin)       # Set up multiple Java installs on Mac OS
                export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
                export JAVA_11_HOME=$(/usr/libexec/java_home -v11)
                alias java8='export JAVA_HOME=$JAVA_8_HOME'
                alias java11='export JAVA_HOME=$JAVA_11_HOME'
                ;;
                
  Linux)        # Setup jEnv on linux
                export PATH="$HOME/.jenv/bin:$PATH"
                eval "$(jenv init -)"
                alias java8='jenv global 1.8'
                alias java11='jenv global 11.0'
                ;;
                
  *)            echo "Unknwon Environment"
                ;;
                
esac

java11
