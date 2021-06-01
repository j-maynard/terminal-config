#!/bin/zsh
# If an incompatible terminal load spaceship otherwise
# load Powerlevel10K
if [[ "$TERMINAL_EMULATOR" == "JetBrains-JediTerm" ]] ; then
      #source ~/.term-config/theme/spaceship.zsh
      source ~/.term-config/theme/powerlevel10k.zsh
elif [[ "$NF_SAFE" == "false" ]]; then
      source ~/.term-config/theme/spaceship-safe.zsh
else
      source ~/.term-config/theme/powerlevel10k.zsh
fi
