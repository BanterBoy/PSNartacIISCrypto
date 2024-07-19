function Set-IISCrypto {
	<#
    .SYNOPSIS
        Configure your server to use a strong cryptographic algorithm. This tool is a wrapper for the IISCryptoCli.exe tool.
    
    .DESCRIPTION
        Configure your server to use a strong cryptographic algorithm. This tool is a wrapper for the IISCryptoCli.exe tool which is a free tool that gives administrators the ability to enable or disable protocols, ciphers, hashes, and key exchange algorithms on Windows Server 2008, 2012, 2016, and 2019. It also lets you reorder SSL/TLS cipher suites offered by IIS, change advanced settings, implement Best Practices, and import custom templates. The GUI available on the Nartac Software site can be used to create a custom template that can be imported with this tool and can be installed using the Install-IISCrypto command.

    .PARAMETER backup
        Specify a file to backup the registry to. Provide the filename and path for the backup.

    .PARAMETER template
        Select a preconfigured template. The available templates are:
        
        - default: Restores the server to the default settings.
        - best: Uses best practices for TLS, compatible with as many browsers as possible while disabling weak protocols and cipher suites.
        - pci40: Makes your server PCI 4.0 compliant, disabling TLS 1.0 and 1.1 which may break client connections to your website. Ensure that RDP will continue to function as Windows 2008 R2 requires an update. See our FAQ for more information.
        - strict: Uses the strictest settings possible, disabling TLS 1.0 and 1.1 and all non-forward secrecy cipher suites which may break client connections to your website. Ensure that RDP will continue to function as Windows 2008 R2 requires an update. See our FAQ for more information.
        - fips140: Makes your server FIPS 140-2 compliant, similar to the Best Practices template but not as secure as Best Practices because some weaker cipher suites are enabled.

    .PARAMETER custom
        Specify a custom template to use. Provide the filename and path of the custom template.

    .PARAMETER reboot
        Reboot the server after the settings are applied.

    .EXAMPLE
        Set-IISCrypto -backup "C:\backup\backup.reg" -template best -reboot

        This example backs up the registry to a file named backup.reg, applies the best practices template, and reboots the server.
    
    .EXAMPLE
        Set-IISCrypto -custom "C:\templates\MyCustomTemplate.ictpl" -reboot

        This example applies a custom template named MyCustomTemplate.ictpl and reboots the server.

    .EXAMPLE
        Set-IISCrypto -template pci40 -backup "C:\backup\backup.reg"

        This example backs up the registry to a file named backup.reg and applies the PCI 4.0 compliance template.

    .OUTPUTS
        System.String
    
    .NOTES
        Author: Luke Leigh
        Website: https://scripts.lukeleigh.com/
        LinkedIn: https://www.linkedin.com/in/lukeleigh/
        GitHub: https://github.com/BanterBoy/
        GitHubGist: https://gist.github.com/BanterBoy
    
    .INPUTS
        backup - You can pipe objects to this parameter.
        template - You can pipe objects to this parameter.
        custom - You can pipe objects to this parameter.
        reboot - You can pipe objects to this parameter.

    .LINK
        https://scripts.lukeleigh.com
    #>

	[CmdletBinding(DefaultParameterSetName = 'Default', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
	[alias("IISC")]
	param (
		[Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Specify a file to backup the registry to.")]
		[string]
		$backup,

		[Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Select a preconfigured template.")]
		[ValidateSet('best', 'pci40', 'strict', 'fips140', 'default')]
		[string]
		$template,

		[Parameter(Mandatory = $false, Position = 2, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Specify the file path and filename of the custom template.")]
		[string]
		$custom,

		[Parameter(Mandatory = $false, Position = 3, HelpMessage = "Reboot the computer after the template has been applied.")]
		[switch]
		$reboot
	)

	process {
		$EnvPath = Get-EnvPath -Container Machine | Where-Object -FilterScript { $_ -Like '*IISCrypto*' }

		if ($backup) {
			if ($PSCmdlet.ShouldProcess("Backup", "Backing up registry to $backup")) {
				& "$EnvPath\IISCryptoCli.exe" /backup $backup
			}
		}

		if ($template) {
			if ($PSCmdlet.ShouldProcess("Template", "Applying template $template")) {
				& "$EnvPath\IISCryptoCli.exe" /template $template
			}
		}

		if ($custom) {
			if ($PSCmdlet.ShouldProcess("Custom Template", "Applying custom template $custom")) {
				& "$EnvPath\IISCryptoCli.exe" /template $custom
			}
		}

		if ($reboot.IsPresent) {
			if ($PSCmdlet.ShouldProcess("Reboot", "Rebooting the computer")) {
				& "$EnvPath\IISCryptoCli.exe" /reboot
			}
		}
	}
}
