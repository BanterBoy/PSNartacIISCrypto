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
