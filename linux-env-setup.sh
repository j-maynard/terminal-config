#!/bin/bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
mkdir -p ~/.rbenv/plugins
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
git clone https://github.com/gcuisinier/jenv.git ~/.jenv
mkdir ~/.jenv/versions
~/.jenv/bin/jenv add /usr/lib/jvm/java-11-openjdk-amd64
~/.jenv/bin/jenv add /usr/lib/jvm/java-8-openjdk-amd64
