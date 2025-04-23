# PowerShell script to install Cursor extensions from extensions.txt
$extFile = Join-Path $PSScriptRoot 'extensions.txt'
if (!(Test-Path $extFile)) {
    Write-Error "Error: $extFile not found."
    exit 1
}

Write-Host "Installing Cursor extensions from $extFile..."
Get-Content $extFile | ForEach-Object {
    cursor --install-extension $_
} 