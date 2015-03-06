Write-Host "Initializing shell..."

function find-and-run ($dirs, $name, $desc)
{
  $found = $FALSE
  foreach ($loc in $dirs) {
    $file = $loc + "\" + $name
    if([IO.File]::Exists($file) -eq $true)
    {
      if ($name.EndsWith(".psd1") -or $name.EndsWith(".psm1"))
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
    return $FALSE;
  }
  
  return $TRUE
}

# Load Jump-Location profile
if (find-and-run @("C:\Users\Doug\Documents\WindowsPowerShell\Modules\Jump.Location", "D:\Users\Doug\Documents\WindowsPowerShell\Modules\Jump.Location") "Jump.Location.psd1" "Jump Location")
{
  # No special init for this
}

# Load posh-git
if (find-and-run @("C:\Users\Doug\Documents\WindowsPowerShell\Modules\posh-git", "D:\Users\Doug\Documents\WindowsPowerShell\Modules\posh-git") "posh-git.psm1" "Posh-Git")
{
  # Initialize Posh-Git
  $GitPromptSettings.EnableFileStatus = $false
  $global:poshgitinstalled = $TRUE
  Enable-GitColors
}
else
{
  # TODO - should there be one settings object with properties?
  $global:poshgitinstalled = $FALSE
}


# One-time setup of some things for the prompt
$Global:Admin=":"
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = new-object System.Security.principal.windowsprincipal($CurrentUser)
if ($principal.IsInRole("Administrators")) 
{
  $Admin="#"
}

# Set up a simple prompt, adding the git prompt parts inside git repos
# TODO: this depends on posh-git - what to do if it isn't installed?
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    Write-Host($(Get-Location | Split-Path -Leaf)) -nonewline

    if ($global:poshgitinstalled)
    {
      Write-VcsStatus
    }

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "$Admin "
}

Write-Host "Ready."
