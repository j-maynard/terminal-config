#!/bin/bash
REPOLANG=$(cat ~/.repos.csv|grep $(git config --get remote.origin.url)|cut -d ',' -f3)
ICON=$(cat ~/.icons.csv|grep SH|cut -d ':' -f2)
PROGLANG=$(cat icons.csv|grep SH|cut -d ':' -f3)
echo $ICON $PROGLANG
