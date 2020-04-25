#!/usr/bin/sudo /bin/bash

if [[ -z $(grep "debian" /etc/os-release) ]]; then
    echo "This script can only run on debian like distributions... Exiting..."
    echo 1
fi

if ! [[ -d "/usr/share/consolefonts" ]]; then
    echo "consolefonts directory at: /usr/share/consolefonts could no be found... Exiting..."
    exit 1
fi

if ! [[ -f "/etc/default/console-setup" ]]; then
    echo "console-setup file at: /etc/default/console-setup could no be found... Exiting..."
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root..."
   exec sudo "$0" "$@"
   exit 0
fi

cd /usr/share/consolefonts
FONTFILES=("ter-powerline-v12n" "ter-powerline-v14b" "ter-powerline-v14n" "ter-powerline-v14v" "ter-powerline-v16b" "ter-powerline-v16n" "ter-powerline-v16v" "ter-powerline-v18b" "ter-powerline-v18n" "ter-powerline-v20b" "ter-powerline-v20n" "ter-powerline-v22b" "ter-powerline-v22n" "ter-powerline-v24b" "ter-powerline-v24n" "ter-powerline-v28b" "ter-powerline-v28n" "ter-powerline-v32b" "ter-powerline-v32n")
for f in ${FONTFILES[@]}; do
    echo "Getting font file $f..."
    wget https://github.com/powerline/fonts/raw/master/Terminus/PSF/$f.psf.gz > /dev/null 2>&1
    if ! [[ $? == 0 ]]; then
        echo "Something seems to have gone wrong downloading font files.  Exiting..."
        exit $?
    fi
done

echo "Updating console-setup..."
cat << EOF > /etc/default/console-setup
# CONFIGURATION FILE FOR SETUPCON

# Consult the console-setup(5) manual page.

ACTIVE_CONSOLES="/dev/tty[1-6]"

CHARMAP="UTF-8"

# CODESET="guess"
# FONTFACE="Fixed"
# FONTSIZE="8x16"

FONT="ter-powerline-v32n"

VIDEOMODE=

# The following is an example how to use a braille font
# FONT='lat9w-08.psf.gz brl-8x8.psf'
EOF

