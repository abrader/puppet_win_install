# Distributed Puppet Agent installer for Windows

---

* **Overview**
* **Usage**
* **Caveats**
* **License**
* **Contributing**

---

## _Overview_


This is tool created to install Puppet agents in a distributed manner on Windows systems.  It uses [WinRM](https://msdn.microsoft.com/en-us/library/aa384426.aspx) to allow a local system to send a PowerShell script to a remote system to be executed.  Aforementioned remote script downloads the latest version of the install script from the Puppet Master and executes the contents.

---

## _Usage_

### Single-agent:
The Agent argument supports hostname or IP Address.

```PowerShell
.\distrib_agent.ps1 -Agent fqdn.example.com -PMHostname master.puppet.vm -PMIpAddress 192.168.1.66
```

### Multiple agents (using agents.txt)
Placing the FQDN of each of the respective agents in a file called agents.txt in the working directory where the distrib_agent.ps1 executable will be run.

```PowerShell
.\distrib_agent.ps1 -PMHostname master.puppet.vm -PMIpAddress 192.168.1.66
```
### Multiple agents (using provided file)
Placing the FQDN of each of the respective agents in a file and file path of your choosing then referencing said path with the FilePath argument.

```PowerShell
.\distrib_agent.ps1 -FilePath C:\ProgramData\agent_list.txt -PMHostname master.puppet.vm -PMIpAddress 192.168.1.66
```

---

## _Caveats_

### Domain Member vs Standalone System
Regardless if the system running the remote script is a domain member or a standalone system, an entry for the each remote system will be created in the [Trusted Hosts](https://msdn.microsoft.com/en-us/library/aa384372.aspx) file.

If this is not a desired result, at the completion of the distributed install script execution you can clean out the [Trusted Hosts](https://msdn.microsoft.com/en-us/library/aa384372.aspx) file.  One method to complete this task programmatically is as follows:

[Use PowerShell to clear the Trusted Hosts file](https://blogs.technet.microsoft.com/heyscriptingguy/2013/11/29/powertip-use-powershell-to-clear-the-trusted-hosts-file/)

---

## _License_

[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt)

---

## _Contributing_

We want to keep it as easy as possible to contribute changes so that our tools work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

Even though this guide is meant for Puppet modules, where applicable the same processes apply.

Read the complete module [contribution guide](https://docs.puppetlabs.com/forge/contributing.html)
