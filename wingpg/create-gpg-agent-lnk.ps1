#########################################
# Update the Variables Below as Desired #
#########################################
$USER="Jamie"

# Name and Path of LNK to Create/Edit
$LNKFile="C:\Users\$USER\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\gpg-agent.lnk"
# Name of Executable/Script to Run in Shortcut
$LNKExe="C:\Program Files (x86)\GnuPG\bin\gpg-connect-agent.exe"
# Command line Parameter to Pass to Executable
$LNKParm="/bye"
# Working Directory if Desired
$LNKWorkDir="C:\Users\$USER\AppData\Roaming\gnupg"
# Setting Icon Example
$LNKIcon="C:\Program Files (x86)\Gpg4win\gpg4win-uninstall.exe,0"
# Setting Icon Example 2
#$LNKIcon="C:\windows\system32\shell32.dll,99"
# LNK Description Field.
$LNKDescription="GPG Agent Startup Link"
# Window Start Size 1=Norm, 3=Maximized, 7=Minimized
$LNKWinStart=7
# Set LNKRunAsAdmin to 1 to enable "Run As Administrator CheckBox"
$LNKRunAsAdmin=0 

#######################################
### Main Code Only Edit Lines Above ###
#######################################

$Shell = New-Object -ComObject ("WScript.Shell")
$ShortCut = $Shell.CreateShortcut("$LNKFile")
$ShortCut.TargetPath="$LNKExe"
$ShortCut.Arguments="$LNKParm"
$ShortCut.WorkingDirectory = "$LNKWorkDir";
$ShortCut.WindowStyle = $LNKwinStart;
$ShortCut.Hotkey = $LNKHotKey
$ShortCut.IconLocation = "$LNKIcon";
$ShortCut.Description = $LNKDescription;
$ShortCut.Save()
