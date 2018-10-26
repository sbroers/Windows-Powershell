$passwort = Read-Host -Prompt "Passwort für alle Benutzer" -AsSecureString

$test = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwort)
$klartextkennwort = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($test)

if($klartextkennwort -eq "") { 
    Write-Host "Kein Kennwort eingegeben."
    exit
}
else {
    if(((Test-Path "abteilungen.csv") -eq $true) -and ((Test-Path "user.csv") -eq $true)) {
        $domaene = (Get-ADDomain -Current LoggedOnUser).DNSRoot
        $domaene_dn = (Get-ADDomain -Current LoggedOnUser).DistinguishedName
        New-ADOrganizationalUnit -Name Personal -Path $domaene_dn -ProtectedFromAccidentalDeletion $false
        Import-Csv abteilungen.csv -Delimiter ";" | foreach { New-ADOrganizationalUnit -Name $_.Abteilung -Path ( "ou=Personal," + $domaene_dn ) -ProtectedFromAccidentalDeletion $false }
        Import-Csv user.csv -Delimiter ";" | foreach { New-ADUser -Name ( $_.Vorname + " " + $_.Nachname ) -DisplayName ( $_.Vorname + " " + $_.Nachname ) -GivenName $_.Vorname -SurName $_.Nachname -SamAccountName ( $_.Vorname[0] + $_.Nachname ) -UserPrincipalName ( $_.Vorname[0] + $_.Nachname + "@" + $domaene ) -EmailAddress ( $_.Vorname + "." + $_.Nachname + "@" + $domaene ) -AccountPassword $passwort -Enabled $true -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Department $_.Abteilung -Title $_.Position -Path ( "ou=" + $_.Abteilung + ",ou=Personal," + $domaene_dn ) }
    }
    else {
        Write-Host "Mindestens eine CSV-Datei fehlt."
    }
}