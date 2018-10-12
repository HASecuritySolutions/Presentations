& ([scriptblock]::Create((iwr -uri http://tinyurl.com/Install-GitHubHostedModule).Content)) `
  -GitHubUserName Positronic-IO -ModuleName PSImaging -Branch 'master'
Export-ImageText -Path "C:\Users\jhenderson\Downloads\Slide Deck - SEC487.jpg"