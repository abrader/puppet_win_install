# distrib_agent.ps1 : This powershell script instructs multiple machines on network to install the Puppet agent
[CmdletBinding()]

Param(
  [string]$agent_list     = $null,
  [string]$hosts_file     = "$env:windir\System32\drivers\etc\hosts",
  [string]$install_script = 'install.ps1',
  [string]$install_dest   = "$env:temp\$install_script",
  [string]$pm_ipaddr      = '192.168.1.207',
  [string]$pm_hostname    = 'master.puppetlabs.vm',
  [string]$install_src    = "https://$pm_ipaddr`:8140/packages/current/install.ps1"
  # [string]$install_log   = "$env:temp\puppet-install.log"
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
  $ScriptPath = Split-Path $MyInvocation.MyCommand.Path
  & "$ScriptPath/$install_script"
}

function Test-Remote ([string] $agent) {

}

function Mass-Install-Puppet {
  foreach ($agent in $agent_list) {
    if (Test-Connection -Computername $agent -Quiet) {
      if (Test-WSMan -ComputerName $agent -Authentication Default -ErrorAction Ignore) {
        Invoke-Command -Computername $agent -ScriptBlock {Install-Puppet}
      }
      else {
        Write-Warning "Unable to contact remote computer: $agent"
      }
    }
  }
}

Mass-Install-Puppet
