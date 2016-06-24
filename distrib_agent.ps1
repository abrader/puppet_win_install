# distrib_agent.ps1 : This powershell script instructs multiple machines on network to install the Puppet agent
[CmdletBinding()]

Param(
  [string]$server      = "<%= @server_setting %>",
  [string]$certname    = $null,
  [string]$msi_dest    = "$env:temp\puppet-agent-x64.msi",
  [string]$msi_source  = "https://<%= @msi_host %>:8140/packages/current/windows-x86_64/puppet-agent-x64.msi",
  [string]$install_log = "$env:temp\puppet-install.log"
)
# Uncomment the following line to enable debugging messages
$DebugPreference = 'Continue'

$name = 'ABCD'

Write-Verbose 'Render template.'
EPS-Render -file test.eps
