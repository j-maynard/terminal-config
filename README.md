# My Terminal Setup

## Introduction

This is my terminal setup.  It consists of a a zshrc and associated files.
It also includes configuration files for vim, emacs, tmux and a setup
script.  It also contains setup scripts to install programs I use on MacOS
and Ubuntu... These are under development and should be merged in to one 
super setup script at some point.

# Quick Full installation on ubuntu

Grab the installer script, make it executable and then run it:

```
wget -O /tmp/install.sh https://raw.githubusercontent.com/j-maynard/terminal-config/main/scripts/install.sh
chmod +x /tmp/install.sh
/tmp/install.sh --help
```

# Install only apps on Ubuntu

Grab the ubuntu system installer script, make it executable and then run it:

```
wget -O /tmp/ubuntu-setup-system.sh https://raw.githubusercontent.com/j-maynard/terminal-config/main/scripts/ubuntu-setup-system.sh
chmod +x /tmp/ubuntu-setup-system.sh
/tmp/ubuntu-setup-system.sh --help
```