Import-Module GroupPolicy

$GpoName = "GPO-Disable-USB"
$OU = "OU=Postes,DC=domaine,DC=local"

New-GPLink -Name $GpoName -Target $OU -Enforced Yes
Write-Host "La GPO '$GpoName' a été liée à l'OU '$OU' avec l'option 'Enforced'"