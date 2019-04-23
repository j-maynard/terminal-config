#!/usr/bin/env bash
#custom0=$(echo -e "$labelcolor YOUR LABEL:$textcolor your text"); out_array=( "${out_array[@]}" "$custom0" ); ((display_index++));
custom0=$(echo -e "$labelcolor JAVA:$textcolor  ☕️  $(java --version | head -n 1)"); out_array=( "${out_array[@]}" "$custom0" ); ((display_index++));
custom1=$(echo -e "       $textcolor Use 'java8' or 'java11' to set the java version"); out_array=( "${out_array[@]}" "$custom1" ); ((display_index++));
custom2=$(echo -e ""); out_array=( "${out_array[@]}" "$custom2" ); ((display_index++));
label="MOTD:"
while read line; do
  customn=$(echo -e "$labelcolor $label$textcolor $line"); out_array=( "${out_array[@]}" "$customn" ); ((display_index++));
  label="     "
done <~/.screenfetch/motd.txt