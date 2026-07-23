# # ==========================================
# # Daily IT Activity Report
# # ==========================================

# $Today = Get-Date -Format "yyyy-MM-dd"
# $ReportFolder = "C:\Martins\ITReports"

# if (!(Test-Path $ReportFolder)) {
#     New-Item -ItemType Directory -Path $ReportFolder | Out-Null
# }

# $Report = "$ReportFolder\IT_Report_$Today.txt"

# "======================================" | Out-File $Report
# "Daily IT Activity Report" | Add-Content $Report
# "Date: $(Get-Date)" | Add-Content $Report
# "Computer: $env:COMPUTERNAME" | Add-Content $Report
# "User: $env:USERNAME" | Add-Content $Report
# "======================================" | Add-Content $Report

# Add-Content $Report ""
# Add-Content $Report "Installed Programs"

# Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
# Where-Object DisplayName |
# Select DisplayName,DisplayVersion |
# Sort DisplayName |
# Format-Table -AutoSize | Out-String |
# Add-Content $Report

# Add-Content $Report ""
# Add-Content $Report "Windows Updates Installed Today"

# Get-HotFix |
# Where-Object {$_.InstalledOn -eq (Get-Date).Date} |
# Format-Table HotFixID,InstalledOn |
# Out-String |
# Add-Content $Report

# Add-Content $Report ""
# Add-Content $Report "Recent System Errors"

# Get-EventLog System -Newest 20 -EntryType Error |
# Select TimeGenerated,Source,Message |
# Format-Table -Wrap |
# Out-String |
# Add-Content $Report

# Add-Content $Report ""
# Add-Content $Report "Running Processes"

# Get-Process |
# Sort ProcessName |
# Select ProcessName,CPU,WorkingSet |
# Format-Table |
# Out-String |
# Add-Content $Report

# Write-Host "Report Generated Successfully"

# ============================================================
# Weekly IT Activity Report
# Author: Martins
# ============================================================

# Report Dates
$EndDate = Get-Date
$StartDate = $EndDate.AddDays(-7)

# Report Folder
$ReportFolder = "C:\Martins\ITReports"

if (!(Test-Path $ReportFolder))
{
    New-Item -ItemType Directory -Path $ReportFolder | Out-Null
}

$Report = "$ReportFolder\IT_Weekly_Report_$($StartDate.ToString('yyyy-MM-dd'))_to_$($EndDate.ToString('yyyy-MM-dd')).txt"

# ============================================================
# Report Header
# ============================================================

"==========================================================" | Out-File $Report
"               WEEKLY IT ACTIVITY REPORT                  " | Add-Content $Report
"==========================================================" | Add-Content $Report
"Period      : $($StartDate.ToShortDateString()) - $($EndDate.ToShortDateString())" | Add-Content $Report
"Generated   : $(Get-Date)" | Add-Content $Report
"Computer    : $env:COMPUTERNAME" | Add-Content $Report
"User        : $env:USERNAME" | Add-Content $Report

$OS = Get-CimInstance Win32_OperatingSystem

"Operating OS: $($OS.Caption)" | Add-Content $Report
"Windows Ver : $($OS.Version)" | Add-Content $Report
"==========================================================" | Add-Content $Report

# ============================================================
# WINDOWS UPDATES
# ============================================================

Add-Content $Report ""
Add-Content $Report "******** WINDOWS UPDATES INSTALLED ********"

$Updates = Get-HotFix | Where-Object {
    $_.InstalledOn -ge $StartDate
}

if($Updates)
{
    $Updates |
    Sort InstalledOn |
    Format-Table HotFixID,Description,InstalledOn -AutoSize |
    Out-String |
    Add-Content $Report
}
else
{
    Add-Content $Report "No Windows updates installed this week."
}

# ============================================================
# SYSTEM ERRORS
# ============================================================

Add-Content $Report ""
Add-Content $Report "******** SYSTEM ERRORS ********"

Get-WinEvent -FilterHashtable @{
    LogName='System'
    Level=2
    StartTime=$StartDate
} -ErrorAction SilentlyContinue |
Select-Object TimeCreated,ProviderName,Id,Message |
Format-Table -Wrap |
Out-String |
Add-Content $Report

# ============================================================
# SYSTEM WARNINGS
# ============================================================

Add-Content $Report ""
Add-Content $Report "******** SYSTEM WARNINGS ********"

Get-WinEvent -FilterHashtable @{
    LogName='System'
    Level=3
    StartTime=$StartDate
} -ErrorAction SilentlyContinue |
Select-Object TimeCreated,ProviderName,Id,Message |
Format-Table -Wrap |
Out-String |
Add-Content $Report

# ============================================================
# COMPUTER RESTARTS
# ============================================================

Add-Content $Report ""
Add-Content $Report "******** COMPUTER RESTART HISTORY ********"

Get-WinEvent -FilterHashtable @{
    LogName='System'
    ID=6005
    StartTime=$StartDate
} -ErrorAction SilentlyContinue |
Select TimeCreated |
Format-Table |
Out-String |
Add-Content $Report

# ============================================================
# SYSTEM UPTIME
# ============================================================

Add-Content $Report ""
Add-Content $Report "******** SYSTEM UPTIME ********"

$Boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime

"Last Boot Time : $Boot" | Add-Content $Report

# ============================================================
# DISK SPACE
# ============================================================

Add-Content $Report ""
Add-Content $Report "******** DISK SPACE ********"

Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
Select-Object DeviceID,
@{Name="Size(GB)";Expression={[math]::Round($_.Size/1GB,2)}},
@{Name="Free(GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}},
@{Name="Used(GB)";Expression={[math]::Round(($_.Size-$_.FreeSpace)/1GB,2)}} |
Format-Table -AutoSize |
Out-String |
Add-Content $Report

# ============================================================
# INSTALLED PROGRAMS
# ============================================================

Add-Content $Report ""
Add-Content $Report "******** INSTALLED SOFTWARE ********"

Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
Where-Object DisplayName |
Select DisplayName,DisplayVersion |
Sort DisplayName |
Format-Table -AutoSize |
Out-String |
Add-Content $Report

# ============================================================
# RUNNING SERVICES
# ============================================================

Add-Content $Report ""
Add-Content $Report "******** RUNNING SERVICES ********"

Get-Service |
Where-Object {$_.Status -eq "Running"} |
Sort DisplayName |
Select DisplayName,Status |
Format-Table -AutoSize |
Out-String |
Add-Content $Report

# ============================================================
# NETWORK INFORMATION
# ============================================================

Add-Content $Report ""
Add-Content $Report "******** NETWORK CONFIGURATION ********"

Get-NetIPConfiguration |
Format-List |
Out-String |
Add-Content $Report

# ============================================================
# TOP CPU PROCESSES
# ============================================================

Add-Content $Report ""
Add-Content $Report "******** TOP CPU PROCESSES ********"

Get-Process |
Sort CPU -Descending |
Select -First 15 ProcessName,CPU |
Format-Table -AutoSize |
Out-String |
Add-Content $Report

# ============================================================
# TOP MEMORY PROCESSES
# ============================================================

Add-Content $Report ""
Add-Content $Report "******** TOP MEMORY PROCESSES ********"

Get-Process |
Sort WorkingSet -Descending |
Select -First 15 ProcessName,
@{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet/1MB,2)}} |
Format-Table -AutoSize |
Out-String |
Add-Content $Report

# ============================================================
# SUMMARY
# ============================================================

Add-Content $Report ""
Add-Content $Report "=========================================================="
Add-Content $Report "SUMMARY"
Add-Content $Report "=========================================================="

$UpdateCount = ($Updates | Measure-Object).Count
$ErrorCount = (Get-WinEvent -FilterHashtable @{
    LogName='System'
    Level=2
    StartTime=$StartDate
} -ErrorAction SilentlyContinue | Measure-Object).Count

$WarningCount = (Get-WinEvent -FilterHashtable @{
    LogName='System'
    Level=3
    StartTime=$StartDate
} -ErrorAction SilentlyContinue | Measure-Object).Count

Add-Content $Report "Windows Updates Installed : $UpdateCount"
Add-Content $Report "System Errors             : $ErrorCount"
Add-Content $Report "System Warnings           : $WarningCount"

Add-Content $Report ""
Add-Content $Report "Report Generated Successfully."

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host " Weekly IT Report Generated Successfully " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Report Location:"
Write-Host $Report -ForegroundColor Yellow
Write-Host ""