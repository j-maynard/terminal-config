#!/usr/bin/env bash
#custom0=$(echo -e "$labelcolor YOUR LABEL:$textcolor your text"); out_array=( "${out_array[@]}" "$custom0" ); ((display_index++));
custom0=$(echo -e "$labelcolor JAVA:$textcolor  ☕️  $(java --version | head -n 1)"); out_array=( "${out_array[@]}" "$custom0" ); ((display_index++));
custom1=$(echo -e "       $textcolor Use 'java8' or 'java11' to set the java version"); out_array=( "${out_array[@]}" "$custom1" ); ((display_index++));
custom2=$(echo -e ""); out_array=( "${out_array[@]}" "$custom2" ); ((display_index++));
custom3=$(echo -e "$labelcolor MOTD:$textcolor Do fairies have tails?"); out_array=( "${out_array[@]}" "$custom3" ); ((display_index++));
custom4=$(echo -e "$labelcolor      $textcolor More than that, do fairies even exist?"); out_array=( "${out_array[@]}" "$custom4" ); ((display_index++));
custom5=$(echo -e "$labelcolor      $textcolor Nobody knows for sure.  So this guild is like them,"); out_array=( "${out_array[@]}" "$custom5" ); ((display_index++));
custom6=$(echo -e "$labelcolor      $textcolor an eternal mystery, an eternal adventure."); out_array=( "${out_array[@]}" "$custom6" ); ((display_index++));

