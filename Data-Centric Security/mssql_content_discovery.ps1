################################
# Author: Justin Henderson
# Last Update: 12/12/2017
#
# Use case: This script converts labs and appendices to markdown
#           It also sets up some navigation pages.
#
# Update server, user, and password to point to a Microsoft SQL box
#
# Current script is a proof of concept looking for credit card numbers
Import-Module SqlServer
$server = "ip_address_or_host"
$user = "user"
# Recommended to change this password piece to utilize a secure string pulled from a text file
# Using PowerShell encryption. See this link for how to do this: http://www.powershellcookbook.com/recipe/PukO/securely-store-credentials-on-disk
$password = 'password'
$credit_card_patterns = @{visa = '4[0-9]{12}(?:[0-9]{3})?'; mastercard = '(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}'; american_express = '3[47][0-9]{13}'; diners_club = '3(?:0[0-5]|[68][0-9])[0-9]{11}'; discover = '6(?:011|5[0-9]{2})[0-9]{12}'; jcb = '(?:2131|1800|35\d{3})\d{11}';}
$databases = Invoke-Sqlcmd -ServerInstance $server -Query "select name from sys.databases WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')" -Username $user -Password $password | Select-Object -ExpandProperty name
foreach($database in $databases){
    $tables = Invoke-Sqlcmd -ServerInstance $server -Query "SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'" -Username $user -Password $password -Database $database | Select-Object -ExpandProperty table_name
    foreach($table in $tables){
        $fields = Invoke-Sqlcmd -ServerInstance $server -Query "SELECT column_name,data_type FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$table'" -Username $user -Password $password -Database $database
        # Possible to limit field types to search
        # This example just cralws them all
        foreach($field in $fields){
            [string]$field_name = $field.column_name
            $field_values = Invoke-Sqlcmd -ServerInstance $server -Query "SELECT $field_name FROM $table" -Username $user -Password $password -Database $database | Select-Object -ExpandProperty $field_name
            foreach($field_data in $field_values){
                foreach($pattern in $credit_card_patterns.Values){
                    if($field_data -match $pattern){
                        foreach ($key in ($credit_card_patterns.GetEnumerator() | Where-Object {$_.Value -eq $pattern})){
                            $card_type = $key.name
                        }
                        Write-Host "Found possible credit card number $field_data found in $database - $table - $field_name with credit card type of $card_type"
                    }
                }
            }
        }
    }
}