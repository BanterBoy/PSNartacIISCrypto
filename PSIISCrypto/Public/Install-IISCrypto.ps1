function Install-IISCrypto {
	<#
	.SYNOPSIS
		The Install-IISCrypto function, installs the IISCrypto application.
	
	.DESCRIPTION
		The Install-IISCrypto function installs the IISCrypto application by downloading
		binaries from the Nartac website to the default location C:\Program Files\IISCrypto
		or to the custom path entered by the user. Downloads are first staged in $env:TEMP
		and verified with Authenticode (and optional SHA256) plus a minimum-version floor
		before being moved into the target directory.

	.PARAMETER InstallType
		Standard: Installs the IISCrypto application to the default location C:\Program Files\IISCrypto.
		Custom: Installs the IISCrypto application to the custom path entered by the user.
	
	.PARAMETER CustomPath
		The custom path entered by the user for the IISCrypto installation. Example: 'D:\Software' IISCrypto will be installed to 'D:\Software'.
	
	.PARAMETER installGUI
		If the installGUI parameter is used, the IISCrypto GUI application will also be installed.

	.PARAMETER ExpectedSha256Cli
		Optional SHA256 hash for the downloaded IISCryptoCli.exe. When supplied, verification
		fails if the hash does not match (case-insensitive).

	.PARAMETER ExpectedSha256Gui
		Optional SHA256 hash for the downloaded IISCrypto.exe (GUI). Only used when
		-installGUI is specified.

	.PARAMETER MinimumVersion
		Minimum acceptable FileVersion for downloaded binaries. Defaults to 4.0. The
		install aborts if the staged download reports a FileVersion below this floor.
	
	.EXAMPLE
		Install-IISCrypto -InstallType Standard
		Installs the IISCrypto application to the default location C:\Program Files\IISCrypto.
	
	.EXAMPLE
		Install-IISCrypto -InstallType Custom -CustomPath "C:\CustomPath\IISCrypto"
		Installs the IISCrypto application to the custom path "C:\CustomPath\IISCrypto".

	.EXAMPLE
		Install-IISCrypto -InstallType Standard -MinimumVersion '4.0.18.0' -ExpectedSha256Cli 'ABCDEF0123...'
		Installs IISCrypto only if the downloaded CLI's Authenticode signature is valid,
		its SHA256 matches the expected value, and its FileVersion is at least 4.0.18.0.
	
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
			HelpMessage = "Please enter a custom file path for the IISCrypto installation. Example: D:\Software IISCrypto will be installed to D:\Software. Required when -InstallType Custom.")]
		[ValidateNotNullOrEmpty()]
		[string]$CustomPath,
		[Parameter(ParameterSetName = 'Default',
			Mandatory = $false,
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true,
			HelpMessage = "If enabled, the GUI application will also be downloaded and can be located in the install directory.")]
		[switch]$installGUI,
		[Parameter(Mandatory = $false, HelpMessage = "Optional SHA256 hash for IISCryptoCli.exe.")]
		[string]$ExpectedSha256Cli,
		[Parameter(Mandatory = $false, HelpMessage = "Optional SHA256 hash for IISCrypto.exe (GUI).")]
		[string]$ExpectedSha256Gui,
		[Parameter(Mandatory = $false, HelpMessage = "Minimum acceptable FileVersion for downloaded binaries.")]
		[Version]$MinimumVersion = [Version]'4.0'
	)
	
	begin {
		
	}
	
	process {
		try {
			if ($InstallType -eq 'Custom' -and [string]::IsNullOrWhiteSpace($CustomPath)) {
				Write-Error -Message "CustomPath is required when InstallType is 'Custom' and must not be empty or whitespace." -Category InvalidArgument -ErrorAction Stop
			}

			$resolvedType = if ([string]::IsNullOrWhiteSpace($InstallType)) { 'Standard' } else { $InstallType }
			$Path = if ($resolvedType -eq 'Custom') { $CustomPath } else { 'C:\Program Files\IISCrypto' }

			if ($PSCmdlet.ShouldProcess($Path, "Installing IISCrypto")) {
				if (Test-Path -Path $Path) {
					Write-Output "IISCrypto already installed"
					return
				}
				Write-Output "IISCrypto not installed"

				try {
					$tls13 = [Net.SecurityProtocolType]::Tls13
				}
				catch {
					$tls13 = 0
				}
				[Net.ServicePointManager]::SecurityProtocol =
				[Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 -bor $tls13

				$downloads = @(
					[pscustomobject]@{
						FileName     = 'IISCryptoCli.exe'
						Uri          = 'https://www.nartac.com/Downloads/IISCrypto/IISCryptoCli.exe'
						ExpectedHash = $ExpectedSha256Cli
					}
				)
				if ($installGUI) {
					$downloads += [pscustomobject]@{
						FileName     = 'IISCrypto.exe'
						Uri          = 'https://www.nartac.com/Downloads/IISCrypto/IISCrypto.exe'
						ExpectedHash = $ExpectedSha256Gui
					}
				}

				$staged = @()
				foreach ($item in $downloads) {
					$tempPath = Join-Path -Path $env:TEMP -ChildPath $item.FileName
					Invoke-RestMethod -Uri $item.Uri -OutFile $tempPath

					try {
						if ($item.ExpectedHash) {
							[void](Test-NartacBinary -Path $tempPath -ExpectedSha256 $item.ExpectedHash)
						}
						else {
							[void](Test-NartacBinary -Path $tempPath)
						}

						$version = [Version]((Get-Item -Path $tempPath).VersionInfo.FileVersion)
						if ($version -lt $MinimumVersion) {
							Remove-Item -Path $tempPath -ErrorAction SilentlyContinue
							Write-Error -Category InvalidData -Message "Downloaded $tempPath is below MinimumVersion $MinimumVersion (got $version)." -ErrorAction Stop
						}
					}
					catch {
						Remove-Item -Path $tempPath -ErrorAction SilentlyContinue
						throw
					}

					$staged += [pscustomobject]@{ TempPath = $tempPath; FileName = $item.FileName }
				}

				New-Item -Path $Path -Type Directory -Force | Out-Null
				foreach ($s in $staged) {
					Move-Item -Path $s.TempPath -Destination (Join-Path -Path $Path -ChildPath $s.FileName) -Force
				}

				Add-EnvPath -Path $Path -Container Machine
				Write-Output "IISCrypto installed"
			}
		}
		catch {
			Write-Error -ErrorRecord $_
		}
	}
	
	end {
		
	}
}
