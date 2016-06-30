# install_pa.ps1 : This powershell script that downloads and executes the Puppet Agent install script.
[CmdletBinding()]

Param(
  [string]$pm_hostname    = $null,                                     # Puppet Master Hostname
  [string]$pm_ipaddr      = $null,                                     # Puppet Master IP Address
  [string]$hosts_file     = "$env:windir\System32\drivers\etc\hosts",  # File containing host records
  [string]$install_script = 'install.ps1',                             # Name of PS1 script on Puppet Master
  [string]$install_dest   = "$env:temp\$install_script"                # Local directory for PS1 install script
)
# Uncomment the following line to enable debugging messages
# $DebugPreference = 'Continue'

function DownloadAgentInstallPS1 {
  Write-Output "Downloading the Puppet agent installer on $env:COMPUTERNAME..."

  $install_src = "https://$pm_hostname`:8140/packages/current/install.ps1"

  [System.Net.ServicePointManager]::ServerCertificateValidationCallback={$true}
  $webclient = New-Object system.net.webclient

  try {
    $webclient.DownloadFile($install_src,$install_dest)
  }
  catch [Net.WebException] {
    Write-Warning "Failed to download the Puppet agent installer script: ${install_src}"
    Write-Warning "$_"
    break
  }
}

function Set-Hostname {
  # Write out a hosts file record for Puppet Master
  Write-Output "Creating host entry for $pm_hostname in $hosts_file."
  $pm_ipaddr + "`t`t" + $pm_hostname | Out-File -encoding ASCII -append $hosts_file
}

function Get-Hostname {
  # Attempt to resolve hostname for Puppet Master
  Try {
    $ips = [System.Net.Dns]::GetHostAddresses($pm_hostname)
    Write-Verbose "Host/DNS Record confirmed: $ips"
  }
  Catch {
    Write-Verbose "Unable to resolve hostname: $pm_hostname"
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
  & "$install_dest"
  Write-Output "Complete!"
}

Install-Puppet
