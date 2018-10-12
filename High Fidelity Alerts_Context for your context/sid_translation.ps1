$rules = get-content -Path C:\Users\jhenderson\Downloads\rules\*.rules | Where-Object { $_ -notmatch "^#" }

foreach($rule in $rules){
    if($sid = [regex]::match($rule, "sid:(?<sid>[0-9]+);").Groups[1].Value){
        $modified_rule = $rule -replace "'","" -replace '"','' -replace ",",""
        "$($sid),$($modified_rule)" | Out-File -FilePath rules.csv -Append -Encoding utf8
    }
}