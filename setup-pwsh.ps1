#!/usr/bin/pwsh
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
# This would be needed only if its Powershell Core
Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
