# distrib_agent.ps1 : This powershell script instructs multiple machines on network to install the Puppet agent
[CmdletBinding()]

Param(
  # [string]$server        = "<%= @server_setting %>",
  # [string]$certname      = $null,
  [string]$agent_list     = $null,
  [string]$install_script = 'install.ps1',
  [string]$install_dest   = "$env:temp\$install_script",
  [string]$puppet_master  = '192.168.1.188'
  [string]$install_src    = "https://$puppet_master`:8140/packages/latest/install.ps1"
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

function Get-Puppet {
  Write-Ouput 'Download install template.'
  DownloadAgentInstallPS1
}

function Install-Puppet {
  Get-Puppet
  $ScriptPath = Split-Path $MyInvocation.MyCommand.Path
  & "$ScriptPath/$install_script"
}

function Mass-Install-Puppet {
  invoke-command -computername $agent_list {Install-Puppet}
}
