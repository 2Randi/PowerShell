Import-Module ActiveDirectory

Get-GPO -All |
Select DisplayName, CreationTime, Owner
