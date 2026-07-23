# ==============================================
# Windows 11 Backup Automation Script
# Author: Your Name
# Description: Backup important folders
# ==============================================

# Backup destination
$BackupRoot = "D:\Company_Backups"

# Number of days to keep backups
$RetentionDays = 30

# Current date
$Date = Get-Date -Format "yyyy-MM-dd_HH-mm"

# Computer name
$Computer = $env:COMPUTERNAME

# Username
$User = $env:USERNAME

# Backup Folder
$BackupFolder = "$BackupRoot\$Computer\$Date"

# Create folder if it doesn't exist
New-Item -ItemType Directory -Force -Path $BackupFolder | Out-Null

# Folders to backup
$Folders = @(
"$env:USERPROFILE\Desktop",
"$env:USERPROFILE\Documents",
"$env:USERPROFILE\Downloads",
"$env:USERPROFILE\Pictures"
)

# Log file
$LogFile = "$BackupRoot\BackupLog.txt"

Add-Content $LogFile ""
Add-Content $LogFile "========================================"
Add-Content $LogFile "Backup Started : $(Get-Date)"
Add-Content $LogFile "Computer : $Computer"
Add-Content $LogFile "User : $User"

foreach ($Folder in $Folders)
{
    if(Test-Path $Folder)
    {
        $FolderName = Split-Path $Folder -Leaf

        robocopy `
        $Folder `
        "$BackupFolder\$FolderName" `
        /E `
        /COPY:DAT `
        /R:2 `
        /W:5 `
        /MT:8 `
        /NFL `
        /NDL `
        /NP

        Add-Content $LogFile "SUCCESS : $Folder"
    }
    else
    {
        Add-Content $LogFile "NOT FOUND : $Folder"
    }
}

# Delete backups older than retention period
Get-ChildItem "$BackupRoot\$Computer" -Directory |
Where-Object {
    $_.CreationTime -lt (Get-Date).AddDays(-$RetentionDays)
} |
Remove-Item -Recurse -Force

Add-Content $LogFile "Backup Completed : $(Get-Date)"