function swish-init()
{

Write-Host "Initializing shell..."

function find-and-run ($dirs, $name, $desc)
{
  $found = $FALSE
  foreach ($loc in $dirs)
  {
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
  foreach ($loc in $dirs)
  {
    if (Test-Path $loc)
    {
      $env:Path += ";" + $loc
      break
    }
  }
}


function add-app-to-path-if-found ($dirs, $name, $subdir)
{
  foreach ($loc in $dirs)
  {
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


function set-java-home ($dirs)
{
  # Set JAVA_HOME (or report that one is already set)
  if ($env:JAVA_HOME -ne $null)
  {
    Write-Host "Using pre-set JAVA_HOME:" $env:JAVA_HOME
  }
  else
  {
    foreach ($path in $dirs) {
      if (Test-Path $path)
      {
        $env:JAVA_HOME = $path
        Write-Host "Set JAVA_HOME to" $path
        break
      }
    }
  }
  
  # Add JAVA_HOME/bin to the path
  if ($env:JAVA_HOME -ne $null)
  {
    Write-Host "Adding JAVA_HOME\bin to the path."
    $env:Path += ";" + $env:JAVA_HOME + "\bin"
  }
}


function setup-python ($dirs)
{
  foreach ($loc in $dirs)
  {
    $path = $loc + "python27"
    if (Test-Path $path)
    {
      Write-Host "Adding python in " $path
      $env:Path += ";" + $path + ";" + $path + "\Scripts"
      break
    }
  }
}


function add-from-global-path ($origPath)
{
  $origBits = $origPath.Split(";")
  $newBits = $env:Path.Split(";")
  
  $origBits | foreach {
    if ($newBits -notcontains $_)
    {
      if ($_.StartsWith($env:userprofile))
      {
        Write-Host "Copied from orig path:" $_
        $env:Path += ";" + $_
      }
      else
      {
        # Write-Host "Not adding" $_ "to path"
      }
    }
  }
}


# Set a base path after saving the original path
$origPath = $env:Path
$env:Path = "$Env:SystemRoot\system32;$Env:SystemRoot"

# TODO - look for other PS versions?
$env:Path += ";$Env:SystemRoot\system32\WindowsPowerShell\v1.0"

# TODO - C:\Windows\System32\Wbem  ?

# Local tools
add-dir-to-path-if-found @("C:\Tools\local", "D:\Tools\local")

# .NET
# add-dir-to-path-if-found @("C:\Windows\Microsoft.NET\Framework64\v4.0.30319")

# Add some fun tools to the path, if they're present on this machine...
add-app-to-path-if-found @("C:\ProgramData", "D:\ProgramData") "Chocolatey" "bin"
# add-app-to-path-if-found @("C:\Program Files", "D:\Program Files") "7-Zip"
# add-app-to-path-if-found @("C:\Program Files", "C:\Program Files (x86)", "D:\Program Files") "nodejs"
add-app-to-path-if-found @("C:\Program Files") "dotnet" 
add-app-to-path-if-found @("C:\Program Files", "C:\Program Files (x86)") "Git" "cmd"
add-app-to-path-if-found @("C:\Program Files (x86)") "vim" "vim80"
# add-app-to-path-if-found @("C:\git\kurdle\src\", "D:\git\kurdle\src\") "Kurdle" "bin\Debug"
# add-app-to-path-if-found @("D:\Tools\") "apache-maven-3.3.9" "bin"
# add-app-to-path-if-found @("D:\Tools\") "apache-storm-0.10.0" "bin"
add-app-to-path-if-found @("C:\Program Files\Docker\") "Docker" "resources\bin"

# Python seems like fun
setup-python @("C:\")

# Add global npm packages to the path
add-dir-to-path-if-found @("$Env:USERPROFILE\AppData\Roaming\npm")

# Add anything in the original path that we care about
add-from-global-path $origPath

# Add current directory to path...
$env:Path += ";."

# JAVA_HOME
set-java-home @("C:\Java\jdk1.8.0_102\", "D:\java\jdk1.8.0_74", "C:\java\jdk1.8.0_74", "D:\java\jdk1.8.0_25")

# ANDROID_HOME
# TODO - do a search-path thing, like set-java-home!
$env:ANDROID_HOME = "C:\Users\swish\AppData\Local\Android\Sdk"

# Load posh-git
if (find-and-run @("C:\Users\Doug\Documents\WindowsPowerShell\Modules\posh-git", "C:\Users\swish\Documents\WindowsPowerShell\Modules\posh-git", "D:\Users\swish\Documents\WindowsPowerShell\Modules\posh-git", "D:\Users\Doug\Documents\WindowsPowerShell\Modules\posh-git", "\\Mac\Home\Documents\WindowsPowerShell\Modules\posh-git") "posh-git.psm1" "Posh-Git")
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

#$shell.BackgroundColor = �DarkBlue�
#$shell.ForegroundColor = �Yellow�

# Set up a customized version of powerls
Import-Module $PSScriptRoot\powerls

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
}

swish-init

# Clean up some aliases
# TODO - wrap this in a function so if the alias is missing, it doesn't error out
Remove-Item alias:wget
Remove-Item alias:curl

# Set some aliases
Set-Alias -Name ls -Value PowerLS -Option AllScope
Set-Alias -Name dir -Value PowerLS -Option AllScope
Set-Alias -Name vi -Value vim
