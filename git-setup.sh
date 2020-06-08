#!/bin/bash
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
