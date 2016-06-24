# distrib_agent.ps1 : This powershell script instructs multiple machines on network to install the Puppet agent
[CmdletBinding()]

Param(
  [string]$server      = "<%= @server_setting %>",
  [string]$certname    = $null,
  [string]$install_dest    = "install.ps1.eps",
  [string]$install_source  = 'https://raw.githubusercontent.com/trevharmon/puppet-pe_install_ps1/METHOD-653/templates/install.ps1.erb',
  [string]$install_log = "$env:temp\puppet-install.log"
)
# Uncomment the following line to enable debugging messages
# $DebugPreference = 'Continue'

function DownloadInstallPS1 {
  Write-Verbose "Downloading the Puppet Agent for Puppet Enterprise <%= @pe_build %> on $env:COMPUTERNAME..."
  [System.Net.ServicePointManager]::ServerCertificateValidationCallback={$true}
  $webclient = New-Object system.net.webclient
  try {
    $webclient.DownloadFile($install_src,$install_dest)
  }
  catch [Net.WebException] {
    Write-Warning "Failed to download the install template: ${install_src}"
    Write-Warning "$_"
    break
  }
}

Write-Verbose 'Download install template.'
DownloadInstallPS1
