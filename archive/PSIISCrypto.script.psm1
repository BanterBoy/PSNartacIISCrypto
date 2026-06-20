function Add-EnvPath {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [ValidateSet('Machine', 'User', 'Session')]
        [string] $Container = 'Session'
    )
    if ($Container -ne 'Session') {
        $containerMapping = @{
            Machine = [EnvironmentVariableTarget]::Machine
            User    = [EnvironmentVariableTarget]::User
        }
        $containerType = $containerMapping[$Container]

        $persistedPaths = [Environment]::GetEnvironmentVariable('Path', $containerType) -split ';'
        if ($persistedPaths -notcontains $Path) {
            $persistedPaths = $persistedPaths + $Path | Where-Object { $_ }
            [Environment]::SetEnvironmentVariable('Path', $persistedPaths -join ';', $containerType)
        }
    }
    $envPaths = $env:Path -split ';'
    if ($envPaths -notcontains $Path) {
        $envPaths = $envPaths + $Path | Where-Object { $_ }
        $env:Path = $envPaths -join ';'
    }
}
function Get-EnvPath {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Machine', 'User', 'Process')]
        [string] $Container
    )
    $containerMapping = @{
        Machine = [EnvironmentVariableTarget]::Machine
        User    = [EnvironmentVariableTarget]::User
        Process = [EnvironmentVariableTarget]::Process
    }
    $containerType = $containerMapping[$Container]
    [Environment]::GetEnvironmentVariable('Path', $containerType) -split ';' |
    Where-Object { $_ }
}
function Install-IISCrypto {
	<#
	.SYNOPSIS
		The Install-IISCrypto function, installs the IISCrypto application.
	
	.DESCRIPTION
		The Install-IISCrypto function, installs the IISCrypto application by downloading binaries from the IISCrypto website to the default location C:\Program Files\IISCrypto or to the custom path entered by the user.
	
	.PARAMETER InstallType
		Standard: Installs the IISCrypto application to the default location C:\Program Files\IISCrypto.
		Custom: Installs the IISCrypto application to the custom path entered by the user.
	
	.PARAMETER CustomPath
		The custom path entered by the user for the IISCrypto installation. Example: 'D:\Software' IISCrypto will be installed to 'D:\Software'.
	
	.PARAMETER installGUI
		If the installGUI parameter is used, the IISCrypto GUI application will also be installed.
	
	.EXAMPLE
		Install-IISCrypto -InstallType Standard
		Installs the IISCrypto application to the default location C:\Program Files\IISCrypto.
	
	.EXAMPLE
		Install-IISCrypto -InstallType Custom -CustomPath "C:\CustomPath\IISCrypto"
		Installs the IISCrypto application to the custom path "C:\CustomPath\IISCrypto".
	
	.NOTES
		Additional information about the function.
	#>
	[CmdletBinding(DefaultParameterSetName = 'Default',
		ConfirmImpact = 'Medium',
		SupportsShouldProcess = $true)]
	[alias("IISC")]
	param
	(
		[Parameter(ParameterSetName = 'Default',
			Mandatory = $false,
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true,
			HelpMessage = "Select the Installation type. Custom or Standard install. Standard install file path - C:\Program Files\IISCrypto.")]
		[ValidateSet ('Standard', 'Custom')]
		[string]$InstallType,
		[Parameter(ParameterSetName = 'Default',
			Mandatory = $false,
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true,
			HelpMessage = "Please enter a custom file path for the IISCrypto installation. Example: D:\Software IISCrypto will be installed to D:\Software.")]
		[string]$CustomPath,
		[Parameter(ParameterSetName = 'Default',
			Mandatory = $false,
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true,
			HelpMessage = "If enabled, the GUI application will also be downloaded and can be located in the install directory.")]
		[switch]$installGUI
	)
	
	begin {
		
	}
	
	process {
		try {
			switch ($InstallType) {
				Standard {
					$Path = "C:\Program Files\IISCrypto"
					if ($PSCmdlet.ShouldProcess("$Path", "Installing IISCrypto")) {
						if (!$Test) {
							$Test = Test-Path -Path $Path
							Write-Output "IISCrypto not installed"
							New-Item -Path $Path -Type Directory
							Invoke-RestMethod -Uri "https://www.nartac.com/Downloads/IISCrypto/IISCryptoCli.exe" -OutFile "$Path\IISCryptoCli.exe"
							if ($installGUI) {
								Invoke-RestMethod -Uri "https://www.nartac.com/Downloads/IISCrypto/IISCrypto.exe" -OutFile "$Path\IISCrypto.exe"
							}
							Add-EnvPath -Path $Path -Container Machine
							$Test = Test-Path -Path $Path
							Write-Output "IISCrypto installed"
						}
						else {
							Write-Output "IISCrypto already installed"
						}
					}
				}
				Custom {
					if ($PSCmdlet.ShouldProcess("$CustomPath", "Installing IISCrypto")) {
						if (!$Test) {
							$Test = Test-Path -Path $CustomPath
							Write-Output "IISCrypto not installed"
							New-Item -Path $CustomPath -Type Directory
							Invoke-RestMethod -Uri "https://www.nartac.com/Downloads/IISCrypto/IISCryptoCli.exe" -OutFile "$CustomPath\IISCryptoCli.exe"
							if ($installGUI) {
								Invoke-RestMethod -Uri "https://www.nartac.com/Downloads/IISCrypto/IISCrypto.exe" -OutFile "$CustomPath\IISCrypto.exe"
							}
							Add-EnvPath -Path $CustomPath -Container Machine
							$Test = Test-Path -Path $CustomPath
							Write-Output "IISCrypto installed"
						}
						else {
							Write-Output "IISCrypto already installed"
						}
					}
				}
				Default {
					if ($PSCmdlet.ShouldProcess("$Path", "Installing IISCrypto")) {
						if (!$Test) {
							$Path = "C:\Program Files\IISCrypto"
							$Test = Test-Path -Path $Path
							Write-Output "IISCrypto not installed"
							New-Item -Path $Path -Type Directory
							Invoke-RestMethod -Uri "https://www.nartac.com/Downloads/IISCrypto/IISCryptoCli.exe" -OutFile "$Path\IISCryptoCli.exe"
							if ($installGUI) {
								Invoke-RestMethod -Uri "https://www.nartac.com/Downloads/IISCrypto/IISCrypto.exe" -OutFile "$Path\IISCrypto.exe"
							}
							Add-EnvPath -Path $Path -Container Machine
							$Test = Test-Path -Path $Path
							Write-Output "IISCrypto installed"
						}
						else {
							Write-Output "IISCrypto already installed"
						}
					}
				}
			}
		}
		catch {
			Write-Error -ErrorRecord $_
		}
	}
	
	end {
		
	}
}
function Remove-EnvPath {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [ValidateSet('Machine', 'User', 'Session')]
        [string] $Container = 'Session'
    )
    if ($Container -ne 'Session') {
        $containerMapping = @{
            Machine = [EnvironmentVariableTarget]::Machine
            User    = [EnvironmentVariableTarget]::User
        }
        $containerType = $containerMapping[$Container]

        $persistedPaths = [Environment]::GetEnvironmentVariable('Path', $containerType) -split ';'
        if ($persistedPaths -contains $Path) {
            $persistedPaths = $persistedPaths | Where-Object { $_ -and $_ -ne $Path }
            [Environment]::SetEnvironmentVariable('Path', $persistedPaths -join ';', $containerType)
        }
    }
    $envPaths = $env:Path -split ';'
    if ($envPaths -contains $Path) {
        $envPaths = $envPaths | Where-Object { $_ -and $_ -ne $Path }
        $env:Path = $envPaths -join ';'
    }
}
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
function Uninstall-IISCrypto {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    $EnvPath = Get-EnvPath -Container Machine | Where-Object -FilterScript { $_ -Like '*IISCrypto*' }
    if ($null -eq $EnvPath) {
        Write-Output "IISCrypto is not installed on this machine"
    }
    else {
        $Path = ($EnvPath).Split('IISCrypto')
        Remove-Item -Path $Path -Recurse -Force
        Remove-EnvPath -Path $EnvPath -Container Machine
        Write-Output "IISCrypto is uninstalled from this machine"
    }
}
function Update-IISCrypto {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    $EnvPath = Get-EnvPath -Container Machine | Where-Object -FilterScript { $_ -Like '*IISCrypto*' }
    if (!$EnvPath) {
        Write-Output "IISCrypto not found"
        return
    }
    else {
        $CLIFile = Get-Item -Path "$EnvPath\IISCryptoCli.exe"
        $GUIFile = Get-Item -Path "$EnvPath\IISCrypto.exe"
        Invoke-RestMethod -Uri "https://www.nartac.com/Downloads/IISCrypto/IISCryptoCli.exe" -OutFile "$env:TEMP\IISCryptoCli.exe"
        Invoke-RestMethod -Uri "https://www.nartac.com/Downloads/IISCrypto/IISCrypto.exe" -OutFile "$env:TEMP\IISCrypto.exe"
        $TempCLI = Get-Item -Path $env:TEMP\IISCryptoCli.exe
        $TempGUI = Get-Item -Path $env:TEMP\IISCrypto.exe
        if (Test-Path -Path $CLIFile) {
            if ($CLIFile.VersionInfo.FileVersion -eq $TempCLI.VersionInfo.FileVersion) {
                Write-Output "IISCrypto CLI up-to-date - $($CLIFile.VersionInfo.FileVersion)"
                Remove-Item -Path $TempCLI
            }
            else {
                Copy-Item -Path $TempCLI -Destination $EnvPath
                Write-Output "IISCrypto CLI updated to version - $($CLIFile.VersionInfo.FileVersion)"
                Remove-Item -Path $TempCLI
            }
            if ($GUIFile.VersionInfo.FileVersion -eq $TempGUI.VersionInfo.FileVersion) {
                Write-Output "IISCrypto GUI up-to-date - $($GUIFile.VersionInfo.FileVersion)"
                Remove-Item -Path $TempGUI
            }
            else {
                Copy-Item -Path $TempGUI -Destination $EnvPath
                Write-Output "IISCrypto GUI updated to version - $($GUIFile.VersionInfo.FileVersion)"
                Remove-Item -Path $TempGUI
            }
        }
    }
}
