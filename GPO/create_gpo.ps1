Import-Module GroupPolicy

$GpoName = "GPO-Disable-USB"

New-GPO -Name $GpoName -Comment "Blocage des périphériques USB"
