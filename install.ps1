New-Item -Path $env:POSH_THEMES_PATH -ItemType "directory" -Force | Out-Null
Copy-Item $PSScriptRoot\themes\nomagic.omp.json $env:POSH_THEMES_PATH
Copy-Item $PSScriptRoot\themes\nomagic.omp.json $env:POSH_PATH

$ProfileFile = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$ThemeSetupScript = '& ([ScriptBlock]::Create((oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\nomagic.omp.json" --print) -join "`n"))'
if (!(Test-Path -Path $ProfileFile)) {
    New-Item -ItemType File -Path $ProfileFile -Force
    Write-Output $ThemeSetupScript > $ProfileFile
}
else {
    if (!(Select-String '^&.+POSH_THEMES_PATH\\nomagic.omp.json.+"`n"\)\)$' $ProfileFile)) {
        Write-Output $ThemeSetupScript >> $ProfileFile
    }
}