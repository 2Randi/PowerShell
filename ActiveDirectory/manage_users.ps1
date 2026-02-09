Import-Module ActiveDirectory

$InputCsv  = ".\data\users.csv"
$ReportCsv = ".\reports\report_users.csv"

$results = @()

$users = Import-Csv $InputCsv -Delimiter ";"

# Parcours de chaque utilisateur et exécution de l'action correspondante
foreach ($user in $users) {
    try {
        switch ($user.Action) {
            #   CREATE : Création d'un nouvel utilisateur
            #   MODIFY : Modification d'un utilisateur existant
            #   DELETE : Suppression d'un utilisateur
            #   En cas d'erreur, l'exception est capturée et le message d'erreur est enregistré dans le rapport
            "CREATE" {

                if (Get-ADUser -Filter "SamAccountName -eq '$($user.SamAccountName)'" -ErrorAction SilentlyContinue) {
                    throw "Utilisateur existe déjà"
                }

                $password = ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force

                New-ADUser `
                    -SamAccountName $user.SamAccountName `
                    -Name "$($user.Prenom) $($user.Nom)" `
                    -GivenName $user.Prenom `
                    -Surname $user.Nom `
                    -Path $user.OU `
                    -AccountPassword $password `
                    -Enabled $true

                if ($user.Groupes) {
                    $groups = $user.Groupes -split ","
                    foreach ($group in $groups) {
                        Add-ADGroupMember -Identity $group -Members $user.SamAccountName
                    }
                }

                $status = "CREATED"
            }

            "MODIFY" {

                Set-ADUser `
                    -Identity $user.SamAccountName `
                    -GivenName $user.Prenom `
                    -Surname $user.Nom

                if ($user.Groupes) {
                    $groups = $user.Groupes -split ","
                    foreach ($group in $groups) {
                        Add-ADGroupMember -Identity $group -Members $user.SamAccountName
                    }
                }

                $status = "MODIFIED"
            }

            "DELETE" {

                Remove-ADUser `
                    -Identity $user.SamAccountName `
                    -Confirm:$false

                $status = "DELETED"
            }

            default {
                throw "Action inconnue"
            }
        }

        $message = "Succès"
    }
    catch {
        $status  = "ERROR"
        $message = $_.Exception.Message
    }

    $results += [PSCustomObject]@{
        SamAccountName = $user.SamAccountName
        Action         = $user.Action
        Status         = $status
        Message        = $message
        Date           = Get-Date
    }
}

$results | Export-Csv $ReportCsv -NoTypeInformation -Delimiter ";"
Write-Host "Traitement terminé. Rapport généré : $ReportCsv"