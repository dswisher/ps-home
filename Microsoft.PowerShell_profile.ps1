# echo Hi

# This is a just a bootstrapper that locates the real profile and executes that.
# The hope is that once this file is installed, it won't ever have to change.

$locations = @("c:\git\ps-home", "d:\git\ps-home", "c:\junk")

foreach ($loc in $locations) {
  $file = $loc + "\MyProfile.ps1"
  if([IO.File]::Exists($file) -eq $true)
  {
    . $file
    break
  }
}

# Load Jump-Location profile
# Import-Module 'D:\ProgramData\Chocolatey\lib\Jump-Location.0.6.0\tools\Jump.Location.psd1'


# Load posh-git example profile
# . 'D:\Users\Doug\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'
