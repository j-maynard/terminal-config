#!/bin/bash
if [ ! -d "${HOME}/.rbenv" ]; then
  echo "Setting RBEnv up...." > /dev/tty
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  cd ~/.rbenv && src/configure && make -C src
  mkdir -p ~/.rbenv/plugins
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
fi

if [ ! -d "${HOME}/.jenv" ]; then
  echo "Setting JEnv up...." > /dev/tty
  git clone https://github.com/gcuisinier/jenv.git ~/.jenv
  mkdir ~/.jenv/versions
  ~/.jenv/bin/jenv add /usr/lib/jvm/java-11-openjdk-amd64
  ~/.jenv/bin/jenv add /usr/lib/jvm/java-8-openjdk-amd64
fi
