$path = "C:\Users\jhenderson\Downloads"

Add-Type -AssemblyName System.IO.Compression.FileSystem
Invoke-WebRequest -Uri http://s3.amazonaws.com/alexa-static/top-1m.csv.zip -OutFile "$path\top-1m.csv.zip"
Remove-Item "$path\top-1m.csv" -Force
[System.IO.Compression.ZipFile]::ExtractToDirectory("$path\top-1m.csv.zip", $path)
$output = ""
Import-csv -Delimiter "," -Header "rank","site" -Path "$path\top-1m.csv" | ForEach-Object {
    $output += "$_.site,$_.rank"
}
$output | Out-File -FilePath "$path\top1m.csv" -force -Encoding utf8