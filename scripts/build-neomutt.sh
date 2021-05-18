#!/bin/bash
STARTDIR=$(pwd)
cd /tmp
which neomutt
# Check to see if have neomutt installed
if [[ $? == 0 ]]; then
    sudo apt install libslang2-dev libnotmuch-dev libgettextpo-dev \
    libncursesw5-dev libidn11-dev libldap2-dev xsltproc libncursesw5-dev ncurses-dev \
    libgpgme-dev libtokyocabinet-dev libsasl2-dev libgss-dev 
else
    sudo apt install libslang2 libslang2-dev notmuch notmuch-mutt libnotmuch-dev  \
    libgpgme11 libgpgme-dev libtokyocabinet-dev tokyocabinet-bin \
    libldap2-dev libidn11-dev libncursesw5-dev libncursesw5-dev gettext libgettextpo-dev \
    xsltproc ncurses-dev libsasl2-dev gnutls-bin libgss-dev libgss3 xsltproc 
fi

# Clone neomutt
git clone https://github.com/neomutt/neomutt
cd neomutt
./configure --ssl \
 --prefix=/usr \
 --sysconfdir=/etc \
 --with-tokyocabinet=/usr/include \
 --with-ncurses=/usr/include \
 --with-ui=ncurses \
 --gpgme \
 --pkgconf \
 --with-slang=/usr/include \
 --with-notmuch=/usr/include \
 --sasl \
 --gnutls

make clean
make
sudo make install
cd ..

# remove neomutt build directory
rm -rf neomutt

# remove dev libraries
sudo apt remove libslang2-dev libnotmuch-dev libgettextpo-dev \
libncursesw5-dev libidn11-dev libldap2-dev ncurses-dev \
libgpgme-dev libtokyocabinet-dev libsasl2-dev libgss-dev libncursesw5-dev

cd $STARTDIR
