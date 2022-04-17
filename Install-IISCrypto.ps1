function Install-IISCrypto {
	<#
	.SYNOPSIS
		A brief description of the Install-IISCrypto function.
	
	.DESCRIPTION
		A detailed description of the Install-IISCrypto function.
	
	.PARAMETER InstallType
		A description of the InstallType parameter.
	
	.PARAMETER CustomPath
		A description of the CustomPath parameter.
	
	.EXAMPLE
		PS C:\> Install-IISCrypto -InstallType 'value1'
	
	.NOTES
		Additional information about the function.
	#>
	
	[CmdletBinding(defaultParameterSetName = "Default",
				   SupportsShouldProcess = $true,
				   ConfirmImpact = "Medium")]
	[alias("IISC")]
	param (
		[Parameter(Mandatory = $true,
				   ParameterSetName = "Default",
				   HelpMessage = "Select the Installation type. Custom or Standard install. Standard install file path - 'C:\Program Files\IISCrypto'.",
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true)]
		[ValidateSet ('Standard', 'Custom')]
		[string]$InstallType,
		
		[Parameter(Mandatory = $false,
				   ParameterSetName = "Default",
				   HelpMessage = "Please enter a custom file path for the IISCrypto installation. Enter base path only. Example: 'D:\Software' IISCrypto will be installed to 'D:\Software\IISCrypto'.",
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true)]
		[string]$CustomPath
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
							New-Item -Path $Path -Name 'IISCrypto' -Type Directory
							Invoke-RestMethod -Uri "https://www.nartac.com/Downloads/IISCrypto/IISCryptoCli.exe" -OutFile "$Path\IISCryptoCli.exe"
							$Test = Test-Path -Path $Path
							Write-Output "IISCrypto installed"
						}
						else
						{
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
							New-Item -Path $Path -Name 'IISCrypto' -Type Directory
							Invoke-RestMethod -Uri "https://www.nartac.com/Downloads/IISCrypto/IISCryptoCli.exe" -OutFile "$Path\IISCryptoCli.exe"
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
