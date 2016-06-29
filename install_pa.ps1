# install_pa.ps1 : This powershell script instructs multiple machines on network to install the Puppet agent
[CmdletBinding()]

Param(
  [string]$hosts_file     = "$env:windir\System32\drivers\etc\hosts",
  [string]$install_script = 'install.ps1',
  [string]$install_dest   = "$env:temp\$install_script",
  [string]$pm_ipaddr      = '192.168.1.207',
  [string]$pm_hostname    = 'master.puppetlabs.vm',
  [string]$install_src    = "https://$pm_ipaddr`:8140/packages/current/install.ps1"
)
# Uncomment the following line to enable debugging messages
# $DebugPreference = 'Continue'

function DownloadAgentInstallPS1 {
  Write-Output "Downloading the Puppet agent installer on $env:COMPUTERNAME..."
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
  Write-Output "Setting hostname for $pm_ipaddr set to $pm_hostname."
  $pm_ipaddr + "`t`t" + $pm_hostname | Out-File -encoding ASCII -append $hosts_file
  # Get-Hostname
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
  & "$install_dest"
}

Install-Puppet
