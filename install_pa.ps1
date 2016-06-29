# install_pa.ps1 : This powershell script that downloads and executes the Puppet Agent install script.
[CmdletBinding()]

Param(
  [string]$PMHostname    = $null,                                     # Puppet Master Hostname
  [string]$PMIpAddress   = $null,                                     # Puppet Master IP Address
  [string]$HostsFile     = "$env:windir\System32\drivers\etc\hosts",  # File containing host records
  [string]$InstallScript = 'install.ps1',                             # Name of PS1 script on Puppet Master
  [string]$InstallDest   = "$env:temp\$InstallScript"                # Local directory for PS1 install script
)
# Uncomment the following line to enable debugging messages
# $DebugPreference = 'Continue'

function DownloadAgentInstallPS1 {
  Write-Output "Downloading the Puppet agent installer on $env:COMPUTERNAME..."

  $InstallSrc = "https://$PMHostname`:8140/packages/current/install.ps1"

  [System.Net.ServicePointManager]::ServerCertificateValidationCallback={$true}
  $webclient = New-Object system.net.webclient

  try {
    $webclient.DownloadFile($InstallSrc,$InstallDest)
  }
  catch [Net.WebException] {
    Write-Warning "Failed to download the Puppet agent installer script: ${InstallSrc}"
    Write-Warning "$_"
    break
  }
}

function Set-Hostname {
  # Write out a hosts file record for Puppet Master
  Write-Output "Creating host entry for $PMHostname in $HostsFile."
  $PMIpAddress + "`t`t" + $PMHostname | Out-File -encoding ASCII -append $HostsFile
}

function Get-Hostname {
  # Attempt to resolve hostname for Puppet Master
  Try {
    $ips = [System.Net.Dns]::GetHostAddresses($PMHostname)
    Write-Verbose "Host/DNS Record confirmed: $ips"
  }
  Catch {
    Write-Verbose "Unable to resolve hostname: $PMHostname"
    Set-Hostname
  }
}

function Get-Puppet {
  Write-Verbose 'Download install template.'
  DownloadAgentInstallPS1
}

function Install-Puppet {
  Get-Hostname
  Get-Puppet

  Write-Output "Running the Puppet agent installer on $env:COMPUTERNAME..."
  try {
    & "$InstallDest"
    Write-Output "Successfully installed Puppet agent on $env:COMPUTERNAME"
  }
  catch {
    Write-Warning "Unsuccessful install of Puppet agent on $env:COMPUTERNAME"
    Write-Warning "$_"
  }
}

Install-Puppet
