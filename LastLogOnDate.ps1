$UserPath = "$($env:USERPROFILE)\Desktop\lastlogon.csv"

Get-ADUser -Filter * -Properties LastLogonDate | Sort-Object -Property LastLogonDate -descending | Select-Object Name, LastLogonDate |
Export-Csv -NoTypeInformation -Path $UserPath -UseCulture
