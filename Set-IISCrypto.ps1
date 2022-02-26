function Set-IISCrypto {

	<#
	.SYNOPSIS
		Set-IISCrypto
	
	.DESCRIPTION
		Set-IISCrypto - Configure your server to use a strong cryptographic algorithm. This tool is a wrapper for the IISCryptoCli.exe tool which is a free tool that gives administrators the ability to enable or disable protocols, ciphers, hashes and key exchange algorithms on Windows Server 2008, 2012, 2016 and 2019. It also lets you reorder SSL/TLS cipher suites offered by IIS, change advanced settings, implement Best Practices and import custom templates. The GUI available on the Nartac Software site can be used to create a custom template that can be imported with this tool.

	.PARAMETER ComputerName
		This parameter accepts the Name of the computer you would like to connect to.
		Supports IP/Name/FQDN
	
		backup
		template
		customtemplate
		filename
		reboot

	.EXAMPLE
		Connect-RDPSession -ComputerName COMPUTERNAME
		Starts an RDP session to COMPUTERNAME
	
	.OUTPUTS
		System.String. Connect-RDPSession
	
	.NOTES
		Author:     Luke Leigh
		Website:    https://scripts.lukeleigh.com/
		LinkedIn:   https://www.linkedin.com/in/lukeleigh/
		GitHub:     https://github.com/BanterBoy/
		GitHubGist: https://gist.github.com/BanterBoy
	
	.INPUTS
		ComputerName - You can pipe objects to this perameter.
		backup - You can pipe objects to this perameter.
		template - You can pipe objects to this perameter.
		filename - You can pipe objects to this perameter.
		reboot - You can pipe objects to this perameter.

	.LINK
		https://scripts.lukeleigh.com
		Get-Date
		Start-Process
		Write-Output
#>


	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$false,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		ParameterSetName="Default",
		HelpMessage="This switch can be enabled to provide a backup of the current registry key.")]
		[bool]
		$backup,

		[Parameter(Mandatory=$true,Position=1)]
		[string]
		$template,

		[Parameter(Mandatory=$true,Position=2)]
		[string]
		$filename,

		[Parameter(Mandatory=$true,Position=3)]
		[bool]
		$reboot
	)
	
	begin {
		
	}
	
	process {
		FunctionName
	}
	
	end {
		
	}
}

<#
IIS Crypto Help

The following are the switches for the command line version of IIS Crypto. All parameters are optional.


Switch	Option			Description
/backup	<filename>		Specify a file to backup the current registry settings too.

/template	default			This template restores the server to the default settings.

best	This template sets your server to use the best practices for TLS. It aims to be compatible with as many browsers as possible while disabling weak protocols and
cipher suites.

pci32	This template is used to make your server PCI 3.2 compliant. It will disable TLS 1.0 and 1.1 which may break client connections to your website. Please make 
		sure that RDP will continue to function as Windows 2008 R2 requires an update. See our FAQ for more information.

strict	This template sets your server to use the strictest settings possible. It will disable TLS 1.0 and 1.1 and all non forward secrecy cipher suites which may break
		client connections to your website. Please make sure that RDP will continue to function as Windows 2008 R2 requires an update. See our FAQ for more information.

fips140	This template makes your server FIPS 140-2 compliant. It is similar to the Best Practices template, however, it is not as secure as Best Practices because some
		of the weaker cipher suites are enabled.

<filename>	Specify the filename of a template to use.

/reboot	Reboot the server after a template is applied.


EXAMPLE.
iiscryptocli /backup backup.reg /template "C:\temp\MyServers.ictpl" /reboot

Here is an example that backs up the registry to a file named backup.reg, applies a custom template named MyServers.ictpl and reboots the server.

#>
