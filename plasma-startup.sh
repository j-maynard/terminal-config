#!/bin/bash
${HOME}/.term-config/conky/conky-startup.sh

NODISPLAYS=$(xrandr |grep ' connected' | wc -l)
if [[ $NODISPLAYS == '4' ]]; then
    xrandr --output HDMI-0 --pos 0x0 --output DP-4 --primary --pos 0x2160 --output DP-2 --pos 3840x0 --output DP-0 --pos 3840x2160
fi

spotify --minimized --force-device-scale-factor=1.75 &
discord &
konsole &
