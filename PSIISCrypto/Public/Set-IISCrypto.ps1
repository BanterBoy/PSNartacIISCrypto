function Set-IISCrypto {

	<#
	.SYNOPSIS
		Set-IISCrypto - Configure your server to use a strong cryptographic algorithm. This tool is a wrapper for the IISCryptoCli.exe tool.
	
	.DESCRIPTION
		Set-IISCrypto - Configure your server to use a strong cryptographic algorithm. This tool is a wrapper for the IISCryptoCli.exe tool which is a free tool that gives administrators the ability to enable or disable protocols, ciphers, hashes and key exchange algorithms on Windows Server 2008, 2012, 2016 and 2019. It also lets you reorder SSL/TLS cipher suites offered by IIS, change advanced settings, implement Best Practices and import custom templates. The GUI available on the Nartac Software site can be used to create a custom template that can be imported with this tool and can be installed using the Install-IISCrypto command.

	.PARAMETER backup
		Specify this switch to backup the current registry settings.

	.PARAMETER template
		There are several predevined templates that can be used. The following are the templates that are available.

		default		This template restores the server to the default settings.

		best		This template sets your server to use the best practices for TLS. It aims to be compatible with as many browsers as possible while disabling weak
					protocols and cipher suites.

		pci32		This template is used to make your server PCI 3.2 compliant. It will disable TLS 1.0 and 1.1 which may break client connections to your website. Please
					make sure that RDP will continue to function as Windows 2008 R2 requires an update. See our FAQ for more information.

		strict		This template sets your server to use the strictest settings possible. It will disable TLS 1.0 and 1.1 and all non forward secrecy cipher suites which
					may break client connections to your website. Please make sure that RDP will continue to function as Windows 2008 R2 requires an update. See our FAQ for more information.

		fips140		This template makes your server FIPS 140-2 compliant. It is similar to the Best Practices template, however, it is not as secure as Best Practices
					because some of the weaker cipher suites are enabled.

	.PARAMETER custom
		This parameter allows you to specify a custom template to use. Please enter the filename and path of the template you wish to use.

	.PARAMETER filename
		The filename and path of registry settings to backup.

	.PARAMETER reboot
		This switch will reboot the server after the settings are applied.

	.EXAMPLE
		iiscryptocli /backup backup.reg /template "C:\temp\MyServers.ictpl" /reboot

		Here is an example that backs up the registry to a file named backup.reg, applies a custom template named MyServers.ictpl and reboots the server.
	
	.OUTPUTS
		System.String. 
	
	.NOTES
		Author:     Luke Leigh
		Website:    https://scripts.lukeleigh.com/
		LinkedIn:   https://www.linkedin.com/in/lukeleigh/
		GitHub:     https://github.com/BanterBoy/
		GitHubGist: https://gist.github.com/BanterBoy
	
	.INPUTS
		backup - You can pipe objects to this parameter.
		template - You can pipe objects to this parameter.
		filename - You can pipe objects to this parameter.
		reboot - You can pipe objects to this parameter.

	.LINK
		https://scripts.lukeleigh.com
		Get-Date
		Start-Process
		Write-Output
	#>

	[CmdletBinding(DefaultParameterSetName = 'Default',
		ConfirmImpact = 'Medium',
		SupportsShouldProcess = $true)]
	[alias("IISC")]

	param (
		[Parameter(Mandatory = $false,
			Position = 0,
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true,
			ParameterSetName = ('Default'),
			HelpMessage = "This switch can be enabled to provide a backup of the current registry key.")]
		[string]
		$backup,
		[Parameter(Mandatory = $false,
			Position = 0,
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true,
			ParameterSetName = ('Template'),
			HelpMessage = "This switch can be enabled to select a preconfigured template.")]
		[ValidateSet ('best', 'pci32', 'strict', 'fips140', 'default')]
		[string]
		$template,
		[Parameter(Mandatory = $false,
			Position = 1,
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true,
			ParameterSetName = ('Default', 'Template', 'Custom'),
			HelpMessage = "Please enter a filename.")]
		[string]
		$filename,
		[Parameter(Mandatory = $false,
			Position = 2,
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true,
			ParameterSetName = ('Default', 'Template', 'Custom'),
			HelpMessage = "This switch can be enabled to reboot the computer after the template has been applied.")]
		[bool]
		$reboot,
		[Parameter(Mandatory = $false,
			position = 0,
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true,
			ParameterSetName = ('Custom'),
			HelpMessage = "Please enter the file path and filename of the custom template.")]
		[string]
		$templateFile
	)
	begin {
		
	}
	process {
		if ($custom) {
			$EnvPath = Get-EnvPath -Container Machine | Where-Object -FilterScript { $_ -Like '*IISCrypto*' }
			if ($reboot) {
				if ($PSCmdlet.ShouldProcess("$templateFile", "Applying custom templatefile and rebooting the computer.")) {
					& $EnvPath\IISCryptoCli.exe /custom $templateFile /reboot
				}
			}
			else {
				if ($PSCmdlet.ShouldProcess("$templateFile", "Applying custom templatefile")) {
					& $EnvPath\IISCryptoCli.exe /custom $templateFile
				}	
			}
		}
		elseif ($backup) {
			$EnvPath = Get-EnvPath -Container Machine | Where-Object -FilterScript { $_ -Like '*IISCrypto*' }
			if ($reboot) {
				if ($PSCmdlet.ShouldProcess("$templateFile", "Performing backup of registry to $filename settings and applying template")) {
					& $EnvPath\IISCryptoCli.exe /backup $filename /template $templateFile /reboot
				}
			}
			else {
				if ($PSCmdlet.ShouldProcess("$templateFile", "Performing backup of registry to $filename settings and applying template")) {
					& $EnvPath\IISCryptoCli.exe /backup $filename /template $templateFile
				}
			}
		}
		else {
			switch ($template) {
				best {
					$EnvPath = Get-EnvPath -Container Machine | Where-Object -FilterScript { $_ -Like '*IISCrypto*' }
					if ($reboot) {
						if ($PSCmdlet.ShouldProcess("$template", "Applying predefined template and rebooting the computer.")) {
							& $EnvPath\IISCryptoCli.exe /template $template /reboot
						}
					}
					else {
						if ($PSCmdlet.ShouldProcess("$template", "Applying predefined template")) {
							& $EnvPath\IISCryptoCli.exe /template $template
						}	
					}
				}
				pci32 {
					$EnvPath = Get-EnvPath -Container Machine | Where-Object -FilterScript { $_ -Like '*IISCrypto*' }
					if ($reboot) {
						if ($PSCmdlet.ShouldProcess("$template", "Applying predefined template and rebooting the computer.")) {
							& $EnvPath\IISCryptoCli.exe /template $template /reboot
						}
					}
					else {
						if ($PSCmdlet.ShouldProcess("$template", "Applying predefined template")) {
							& $EnvPath\IISCryptoCli.exe /template $template
						}	
					}
				}
				strict {
					$EnvPath = Get-EnvPath -Container Machine | Where-Object -FilterScript { $_ -Like '*IISCrypto*' }
					if ($reboot) {
						if ($PSCmdlet.ShouldProcess("$template", "Applying predefined template and rebooting the computer.")) {
							& $EnvPath\IISCryptoCli.exe /template $template /reboot
						}
					}
					else {
						if ($PSCmdlet.ShouldProcess("$template", "Applying predefined template")) {
							& $EnvPath\IISCryptoCli.exe /template $template
						}	
					}
				}
				fips140 {
					$EnvPath = Get-EnvPath -Container Machine | Where-Object -FilterScript { $_ -Like '*IISCrypto*' }
					if ($reboot) {
						if ($PSCmdlet.ShouldProcess("$template", "Applying predefined template and rebooting the computer.")) {
							& $EnvPath\IISCryptoCli.exe /template $template /reboot
						}
					}
					else {
						if ($PSCmdlet.ShouldProcess("$template", "Applying predefined template")) {
							& $EnvPath\IISCryptoCli.exe /template $template
						}	
					}
				}
				default {
					$EnvPath = Get-EnvPath -Container Machine | Where-Object -FilterScript { $_ -Like '*IISCrypto*' }
					if ($reboot) {
						if ($PSCmdlet.ShouldProcess("$template", "Applying predefined template and rebooting the computer.")) {
							& $EnvPath\IISCryptoCli.exe /template $template /reboot
						}
					}
					else {
						if ($PSCmdlet.ShouldProcess("$template", "Applying predefined template")) {
							& $EnvPath\IISCryptoCli.exe /template $template
						}	
					}
				}
			}
		}
	}
	end {
		
	}
}
