
echo "Hello from MyProfile!"

function find-and-run ($dirs, $name, $desc)
{
  $found = $FALSE
  foreach ($loc in $dirs) {
    $file = $loc + "\" + $name
    if([IO.File]::Exists($file) -eq $true)
    {
      if ($name.EndsWith(".psd1"))
      {
        # A module...import it.
        # Write-Host "Found module! Path: " $file
        Import-Module $file
      }
      else
      {
        # Assume a script
        # Write-Host "Found script! Path: " $file
        . $file
      }

      $found = $TRUE
      break
    }
  }
  
  if (-not $found)
  {
    Write-Host $desc "was NOT initialized."
  }
}

# Load Jump-Location profile
find-and-run @("D:\Users\Doug\Documents\WindowsPowerShell\Modules\Jump.Location") "Jump.Location.psd1" "Jump Location"

# Load posh-git example profile
# TODO - pull this into this file! Or at least, a bunch of it...
# . 'D:\Users\Doug\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'
find-and-run @("D:\Users\Doug\Documents\WindowsPowerShell\Modules\posh-git") "profile.example.ps1" "Posh-Git Profile"



# -----------------


# Load posh-git example profile
# . 'D:\Users\Doug\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'

# Temporary hack while working on 'pig'
# $env:Path += ";C:\git\pig\src\GitPowerShellUi\bin\Debug"

# Load Jump-Location profile
# Import-Module 'C:\Chocolatey\lib\Jump-Location.0.6.0\tools\Jump.Location.psd1'



# Import-Module 'D:\Users\Doug\Documents\WindowsPowerShell\Modules\Jump.Location\Jump.Location.psd1'
