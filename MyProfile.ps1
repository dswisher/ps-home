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


function add-dir-to-path-if-found ($dirs)
{
  foreach ($loc in $dirs) {
    if (Test-Path $loc)
    {
      $env:Path += ";" + $loc
      break
    }
  }
}


function add-app-to-path-if-found ($dirs, $name, $subdir)
{
  foreach ($loc in $dirs) {
    $path = $loc + "\" + $name
    if ($subdir -ne $null)
    {
      $path += "\" + $subdir
    }
    
    if (Test-Path $path)
    {
      $env:Path += ";" + $path
      Write-Host "Added" $name "to the path."
      break
    }
  }
}


# Set a base path
$env:Path = "$Env:SystemRoot\system32;$Env:SystemRoot"

# TODO - look for other PS versions?
$env:Path += ";$Env:SystemRoot\system32\WindowsPowerShell\v1.0"

# TODO - C:\Windows\System32\Wbem  ?

# Local tools
add-dir-to-path-if-found @("C:\Tools\local", "D:\Tools\local")

# Add some fun tools to the path, if they're present on this machine...
add-app-to-path-if-found @("C:\ProgramData", "D:\ProgramData") "Chocolatey" "bin"
add-app-to-path-if-found @("C:\Program Files", "D:\Program Files") "7-Zip"
add-app-to-path-if-found @("C:\Program Files", "C:\Program Files (x86)", "D:\Program Files") "nodejs"
add-app-to-path-if-found @("C:\Program Files", "C:\Program Files (x86)") "Git" "cmd"
add-app-to-path-if-found @("C:\git\kurdle\src\", "D:\git\kurdle\src\") "Kurdle" "bin\Debug"

# Anaconda (python, pandas, etc)
#    http://pandas-docs.github.io/pandas-docs-travis/install.html#installing-pandas-with-anaconda
#    TODO: clean this up - should really be an app with multiple dirs...
add-dir-to-path-if-found @("C:\Users\$Env:USERNAME\Anaconda3", "D:\Users\$Env:USERNAME\Anaconda3")
add-dir-to-path-if-found @("C:\Users\$Env:USERNAME\Anaconda3\Scripts", "D:\Users\$Env:USERNAME\Anaconda3\Scripts")
add-dir-to-path-if-found @("C:\Users\$Env:USERNAME\Anaconda3\Library\bin", "D:\Users\$Env:USERNAME\Anaconda3\Library\bin")

# Add global npm packages to the path
add-dir-to-path-if-found @("$Env:USERPROFILE\AppData\Roaming\npm")

# Add current directory to path...
$env:Path += ";."


# Load Jump-Location profile
#if (find-and-run @("C:\Users\Doug\Documents\WindowsPowerShell\Modules\Jump.Location", "C:\Users\swish\Documents\WindowsPowerShell\Modules\Jump.Location", "D:\Users\swish\Documents\WindowsPowerShell\Modules\Jump.Location", "D:\Users\Doug\Documents\WindowsPowerShell\Modules\Jump.Location") "Jump.Location.psd1" "Jump Location")
#{
  # No special init for this
#}

# Load posh-git
if (find-and-run @("C:\Users\Doug\Documents\WindowsPowerShell\Modules\posh-git", "C:\Users\swish\Documents\WindowsPowerShell\Modules\posh-git", "D:\Users\swish\Documents\WindowsPowerShell\Modules\posh-git", "D:\Users\Doug\Documents\WindowsPowerShell\Modules\posh-git") "posh-git.psm1" "Posh-Git")
{
  # Initialize Posh-Git
  $GitPromptSettings.EnableFileStatus = $false
  $global:poshgitinstalled = $TRUE
  #Enable-GitColors
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

# Make things look purty...
#$shell = $Host.UI.RawUI

#$shell.BackgroundColor = “DarkBlue”
#$shell.ForegroundColor = “Yellow”

# Set up a customized version of powerls
Import-Module $PSScriptRoot\powerls

Set-Alias -Name ls -Value PowerLS -Option AllScope
Set-Alias -Name dir -Value PowerLS -Option AllScope

# Start out in a good place...
if (Test-Path f:\git)
{
  Set-Location f:\git
}
elseif (Test-Path c:\git)
{
  Set-Location c:\git
}
elseif (Test-Path d:\git)
{
  Set-Location d:\git
}

# Done!
Write-Host "Ready."
