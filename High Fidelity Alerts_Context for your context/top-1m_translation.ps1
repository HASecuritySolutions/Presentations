$path = "C:\Users\jhenderson\Downloads"

Add-Type -AssemblyName System.IO.Compression.FileSystem
Invoke-WebRequest -Uri http://s3.amazonaws.com/alexa-static/top-1m.csv.zip -OutFile "$path\top-1m.csv.zip"
Remove-Item "$path\top-1m.csv" -Force
[System.IO.Compression.ZipFile]::ExtractToDirectory("$path\top-1m.csv.zip", $path)
$top1m = Import-csv -Delimiter "," -Header "rank","site" -Path "$path\top-1m.csv"
foreach($record in $top1m){
    "$record.site,$record.rank" | Out-File -FilePath top1m.csv -Append -Encoding utf8
}