# This script works with both Linux (with PowerShell installed) or Windows
$files_discovered = @()
# On Windows $path would be something like @("C:\","D:\folder")
$path = @("/etc","/home","/usr")
foreach($folder in $path){
    $files_discovered += Get-ChildItem -Path $folder -Recurse -Include *.csv -ErrorAction SilentlyContinue | Select-String -Pattern "4[0-9]{12}(?:[0-9]{3})?|3[47][0-9]{13}|6(?:011|5[0-9]{2})[0-9]{12}"
}
$files_discovered | Group-Object -Property 