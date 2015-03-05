# Copy the bootstrap folder to the system profile location

# Make a backup?
# TODO

$folderPath =  Split-Path $profile -parent

if (-not (Test-Path $folderPath))
{
  Write-Host Directory not found!
  New-Item -ItemType Directory -Force -Path $folderPath
}

Copy-Item .\Microsoft.PowerShell_profile.ps1 $profile
