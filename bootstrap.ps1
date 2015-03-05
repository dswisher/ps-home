# This is a bootstrapper that locates the real profile and executes that.
# The hope is that once this file is installed, it won't ever have to change.

$locations = @("c:\git\ps-home", "d:\git\ps-home")

foreach ($loc in $locations) {
  $file = $loc + "\MyProfile.ps1"
  if([IO.File]::Exists($file) -eq $true)
  {
    . $file
    break
  }
}
