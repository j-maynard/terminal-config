#!/bin/zsh
# If an incompatible terminal load spaceship otherwise
# load Powerlevel10K
if [[ "$TERMINAL_EMULATOR" == "JetBrains-JediTerm" ]] ; then
      source ~/.term-config/theme/spaceship.zsh
else
      source ~/.term-config/theme/powerlevel10k.zsh
fi
