# distrib_agent.ps1 : This powershell script instructs multiple machines on network to install the Puppet agent
[CmdletBinding()]

Param(
  [string]$Agent       = $null,         # Singular Agent install
  [string]$FilePath    = 'agents.txt',  # File containing hostnames of agents
  [string]$PMHostname  = $null,         # Puppet Master Hostname
  [string]$PMIpAddress = $null          # Puppet Master IP Address
)
# Uncomment the following line to enable debugging messages
# $DebugPreference = 'Continue'

function Add-Remote-Trusted-Host ([string]$hostname) {
  $current_value = (get-item wsman:\\localhost\Client\TrustedHosts).value
  if (($current_value -match $hostname) -eq $false) {
    Write-Verbose "Adding TrustedHosts entry for remote agent: $hostname"
    if ([string]::IsNullOrEmpty($current_value)) {
      set-item wsman:\localhost\Client\TrustedHosts -value $hostname
    }
    else {
      set-item wsman:\localhost\Client\TrustedHosts -value "$current_value, $hostname"
    }
  }
}

function Mass-Install-Puppet {
  # If user doesn't supply comma separated list on command line
  if ([string]::IsNullOrEmpty($Agent)) {
    if (Test-Path $FilePath) {
      $agent_list = Get-Content $FilePath
    }
    else {
      Write-Error -Message "You must either pass -Agent on the command line, -FilePath for a list of agents in a file, or the agents.txt file must exist." -Category InvalidArgument
      Exit
    }
  }
  else {
    $agent_list = $Agent
  }

  foreach ($agent in $agent_list) {
    Add-Remote-Trusted-Host($agent)

    if (Test-Connection -Computername $agent -Quiet) {
      if (Test-WSMan -ComputerName $agent -Authentication Default -ErrorAction Ignore) {
        Invoke-Command -ComputerName $agent -FilePath "$PSScriptRoot/install_pa.ps1" -ArgumentList $PMHostname, $PMIpAddress
      }
      else {
        Write-Warning "Unable to contact remote computer: $agent"
      }
    }
  }
}

Mass-Install-Puppet
