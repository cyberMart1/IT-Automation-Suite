# =====================================================
# Applications Executed During the Last 7 Days
# Uses Windows Prefetch
# =====================================================

$Days = 7
$Since = (Get-Date).AddDays(-$Days)

$OutputFolder = "C:\Martins\ITReports"

if (!(Test-Path $OutputFolder))
{
    New-Item -ItemType Directory -Path $OutputFolder | Out-Null
}

$Report = "$OutputFolder\Applications_Last_7_Days.txt"

"==========================================" | Out-File $Report
"Applications Opened During Last 7 Days" | Add-Content $Report
"Generated: $(Get-Date)" | Add-Content $Report
"==========================================" | Add-Content $Report
Add-Content $Report ""

$PrefetchFolder = "C:\Windows\Prefetch"

Get-ChildItem $PrefetchFolder -Filter *.pf |
Where-Object {$_.LastWriteTime -ge $Since} |
Sort-Object LastWriteTime -Descending |
Select-Object @{
    Name="Application"
    Expression={
        $_.BaseName.Split("-")[0]
    }
}, LastWriteTime |
Format-Table -AutoSize |
Out-String |
Add-Content $Report

Write-Host "Report saved to:"
Write-Host $Report -ForegroundColor Green