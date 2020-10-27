#!/bin/bash

check_requirements() {
    if which apt > /dev/null; then
        INSTALL=false
        if ! dpkg -l git > /dev/null; then
            INSTALL=true
            git_pkgs="git"
        fi
        if ! dpkg -l gnupg2 > /dev/null; then
            INSTALL=true
            gnupg2_pkgs="gnupg2"
        fi
        if ! dpkg -l scdaemon > /dev/null; then
            INSTALL=true
            scdaemon_pkgs="scdaemon"
        fi
        if [[ $INSTALL == "true" ]]; then
            echo "Installing required packages..."
            sudo apt-get install $git_pkgs $gnupg2_pkgs $scdaemon_pkgs
        fi
    else
        echo "Can't check requirements.  If the script fails make"
        echo "sure you have gnupg and the scdeamon (the smart card"
        echo "deamon) installed"
    fi
}

get_profile() {
    if [[ "$1" =~ ^[0-9]+$ && $1>0 && $1<=${#profile_names[@]}+1 ]]; then
        p_name=${profile_names[($1-1)]}
    else
        return 1
    fi
    echo ${p_name} is selected
    if [ -v WSLENV ]; then
        echo -e "Starting WinGPGP Connection script"
        $SCRIPTPATH/wingpg/wingpg-connect.sh &
    fi
    source <(gpg -d -q ${SCRIPTPATH}/encrypted/git-${p_name}.gpg)        
}
check_requirements
SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`
profiles=$(cd ${SCRIPTPATH}/encrypted && ls git*)

declare -a profile_names

exec > /dev/tty 
echo "Profiles fround:"
count=1
for profile in $profiles
do
    p_name=$(echo $profile | cut -d '-' -f 2 | cut -d '.' -f 1)
    echo "${count}) $p_name"
    ((count++))
    profile_names+=($p_name)
done
echo "Total number of profiles = ${#profile_names[@]}"
while true; do
    read -p "Select a profile? [1 - ${#profile_names[@]}] " p
    case $p in
        * )       get_profile $p
                  if [ $? == 0 ]; then
                    break
                  fi
                  echo "Profile selection not valid"
                  ;;
    esac
done

git config --global user.name "${USERNAME}"
git config --global user.email "${EMAIL}"
git config --global user.signingkey ${SIGNING_KEY}
git config --global commit.gpgsign true
