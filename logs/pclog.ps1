# ==========================================================
# PC Activity Logger
# Author: Martins
# Version: 1.0
# ==========================================================

$LogFolder = "C:\Martins\PCLogs"

if (!(Test-Path $LogFolder))
{
    New-Item -ItemType Directory -Path $LogFolder | Out-Null
}

$LogFile = "$LogFolder\PC_Activity_Log.txt"

if (!(Test-Path $LogFile))
{
    "Timestamp,Computer,User,CPU(%),MemoryUsed(%),DiskFreeGB,IPAddress,Internet,Uptime(Hours),TopProcess,LastBoot" |
    Out-File $LogFile
}

while ($true)
{
    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $Computer = $env:COMPUTERNAME

    $User = $env:USERNAME

    # CPU Usage
    $CPU = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    $CPU = [math]::Round($CPU,2)

    # Memory Usage
    $OS = Get-CimInstance Win32_OperatingSystem

    $TotalRAM = $OS.TotalVisibleMemorySize
    $FreeRAM = $OS.FreePhysicalMemory

    $UsedRAM = (($TotalRAM-$FreeRAM)/$TotalRAM)*100
    $UsedRAM = [math]::Round($UsedRAM,2)

    # Disk Space
    $Drive = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"

    $DiskFree = [math]::Round($Drive.FreeSpace/1GB,2)

    # IP Address
    $IP = (Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object {
        $_.IPAddress -notlike "169.*" -and
        $_.InterfaceAlias -notmatch "Loopback"
    } |
    Select-Object -First 1 -ExpandProperty IPAddress)

    # Internet Test
    if(Test-Connection google.com -Count 1 -Quiet)
    {
        $Internet="Connected"
    }
    else
    {
        $Internet="Disconnected"
    }

    # Uptime

    $Boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime

    $Uptime = New-TimeSpan -Start $Boot -End (Get-Date)

    $Hours = [math]::Round($Uptime.TotalHours,10)

    # Highest CPU Process

    $TopProcess = Get-Process |
    Sort-Object CPU -Descending |
    Select-Object -First 1 -ExpandProperty ProcessName

    # Write Log

    "$Time,$Computer,$User,$CPU,$UsedRAM,$DiskFree,$IP,$Internet,$Hours,$TopProcess,$Boot" |
    Add-Content $LogFile

    Start-Sleep -Seconds 300
}