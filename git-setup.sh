#!/bin/bash
SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`
profiles=$(cd ${SCRIPTPATH}/encrypted && ls git*)
declare -a profile_names
for profile in $profiles
do
    profile_names+=($(echo $profile | cut -d '-' -f 2 | cut -d '.' -f 1))
done
echo "Select a profile?"
select profile in ${profile_names[@]}; do
    case $profile in
        * ) echo $profile is selected
            source <(gpg -d -q ${SCRIPTPATH}/encrypted/git-$profile.gpg)
            break;;
    esac
done
git config --global user.name "${USERNAME}"
git config --global user.email "${EMAIL}"
git config --global user.signingkey ${SIGNING_KEY}
git config --global commit.gpgsign true