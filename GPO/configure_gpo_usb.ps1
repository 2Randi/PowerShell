Import-Module GroupPolicy

$GpoName = "GPO-Disable-USB"

Set-GPRegistryValue `
 -Name $GpoName `
 -Key "HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR" `
 -ValueName "Start" `
 -Type DWord `
 -Value 4
Write-Host "La GPO '$GpoName' a été configurée pour bloquer les périphériques USB"