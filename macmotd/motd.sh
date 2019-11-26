#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

distro=$(/usr/bin/sw_vers -productName)
version=$(/usr/bin/sw_vers -productVersion)
os="\033[1mOS:\033[0m       $distro $version"
boot=$(sysctl -n kern.boottime | cut -d "=" -f 2 | cut -d "," -f 1)
now=$(date +%s)
uptime=$((now-boot))
mins=$((uptime/60%60))
hours=$((uptime/3600%24))
days=$((uptime/86400))
uptime="${mins}m"
if [ "${hours}" -ne "0" ]; then
    uptime="${hours}h ${uptime}"
fi
if [ "${days}" -ne "0" ]; then
    uptime="${days}d ${uptime}"
fi
uptime="\033[1mUptime:\033[0m 神 ${uptime}"
totaldisk=$(df -H / 2>/dev/null | tail -1)
disktotal=$(awk '{print $2}' <<< "${totaldisk}")
diskused=$(awk '{print $3}' <<< "${totaldisk}")
diskusedper=$(awk '{print $5}' <<< "${totaldisk}")
diskusage="\033[1mDisk:\033[0m     ${diskused} / ${disktotal} (${diskusedper})"
myUser=${USER}
myHost=${HOSTNAME}
myHost=${myHost/.local}
whome="\033[1mUser:\033[0m     ${myUser}@${myHost}"
cpu="\033[1mCPU:\033[0m      $(sysctl -n machdep.cpu.brand_string)"
kernel="\033[1mKernel:\033[0m   $(uname -m) $(uname -sr)"
totalmem=$(echo "$(sysctl -n hw.memsize)" / 1024^2 | bc)
wiredmem=$(vm_stat | grep wired | awk '{ print $4 }' | sed 's/\.//')
activemem=$(vm_stat | grep ' active' | awk '{ print $3 }' | sed 's/\.//')
compressedmem=$(vm_stat | grep occupied | awk '{ print $5 }' | sed 's/\.//')
if [[ ! -z "$compressedmem | tr -d" ]]; then  # FIXME: is this line correct?
    compressedmem=0
fi
usedmem=$(((wiredmem + activemem + compressedmem) * 4 / 1024))
mem="\033[1mMemory:\033[0m   ${usedmem}MiB / ${totalmem}MiB"


#echo -e $whome
#echo -e $os
#echo -e $kernel
#echo -e $uptime
#echo -e $cpu
#echo -e $diskusage
#echo -e $mem
source $SCRIPT_DIR/porygon.txt
