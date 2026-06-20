function Update-IISCrypto {
    <#
    .SYNOPSIS
        Updates the installed Nartac IIS Crypto CLI (and GUI, if present) to the latest version.

    .DESCRIPTION
        Locates the IIS Crypto installation via the machine PATH, downloads the current
        IISCryptoCli.exe (and IISCrypto.exe when the GUI is installed) from nartac.com,
        verifies each download with Authenticode (and optional SHA256), enforces a
        MinimumVersion floor, compares FileVersion against the installed binaries, and
        replaces them in-place when newer. The GUI lookup is guarded by Test-Path so
        CLI-only installs are handled cleanly. All download, copy, and cleanup
        operations honour -WhatIf and -Confirm via SupportsShouldProcess.

    .PARAMETER ExpectedSha256Cli
        Optional SHA256 hash for the downloaded IISCryptoCli.exe. When supplied,
        verification fails if the hash does not match (case-insensitive).

    .PARAMETER ExpectedSha256Gui
        Optional SHA256 hash for the downloaded IISCrypto.exe (GUI).

    .PARAMETER MinimumVersion
        Minimum acceptable FileVersion for downloaded binaries. Defaults to 4.0.

    .EXAMPLE
        Update-IISCrypto -WhatIf

        Reports what would be downloaded, replaced, or removed without making any changes.

    .EXAMPLE
        Update-IISCrypto

        Updates the installed IIS Crypto binaries if the upstream versions are newer.

    .EXAMPLE
        Update-IISCrypto -MinimumVersion '4.0.18.0' -ExpectedSha256Cli 'ABCDEF0123...'

        Updates only if the downloaded CLI passes Authenticode + SHA256 verification
        and reports a FileVersion of at least 4.0.18.0.

    .NOTES
        Requires that IIS Crypto has been installed via Install-IISCrypto so that its
        directory is present on the machine PATH. Network access to nartac.com is
        required when not running with -WhatIf.

    .LINK
        https://www.nartac.com/Products/IISCrypto
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ExpectedSha256Cli,

        [Parameter(Mandatory = $false)]
        [string]$ExpectedSha256Gui,

        [Parameter(Mandatory = $false)]
        [Version]$MinimumVersion = [Version]'4.0'
    )

    process {
        $EnvPath = Get-EnvPath -Container Machine | Where-Object -FilterScript { $_ -Like '*IISCrypto*' }
        if (!$EnvPath) {
            Write-Output "IISCrypto not found"
            return
        }

        $CLIPath = Join-Path -Path $EnvPath -ChildPath 'IISCryptoCli.exe'
        $GUIPath = Join-Path -Path $EnvPath -ChildPath 'IISCrypto.exe'
        $TempCLIPath = Join-Path -Path $env:TEMP -ChildPath 'IISCryptoCli.exe'
        $TempGUIPath = Join-Path -Path $env:TEMP -ChildPath 'IISCrypto.exe'

        if (-not (Test-Path -Path $CLIPath)) {
            Write-Output "IISCrypto CLI not found at $CLIPath"
            return
        }

        try {
            $tls13 = [Net.SecurityProtocolType]::Tls13
        }
        catch {
            $tls13 = 0
        }
        [Net.ServicePointManager]::SecurityProtocol =
        [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 -bor $tls13

        $CLIFile = Get-Item -Path $CLIPath

        if ($PSCmdlet.ShouldProcess($TempCLIPath, 'Download IISCryptoCli.exe from nartac.com')) {
            Invoke-RestMethod -Uri 'https://www.nartac.com/Downloads/IISCrypto/IISCryptoCli.exe' -OutFile $TempCLIPath
        }

        if (Test-Path -Path $TempCLIPath) {
            try {
                if ($ExpectedSha256Cli) {
                    [void](Test-NartacBinary -Path $TempCLIPath -ExpectedSha256 $ExpectedSha256Cli)
                }
                else {
                    [void](Test-NartacBinary -Path $TempCLIPath)
                }

                $TempCLI = Get-Item -Path $TempCLIPath
                $TempCLIVersion = [Version]$TempCLI.VersionInfo.FileVersion
                if ($TempCLIVersion -lt $MinimumVersion) {
                    Remove-Item -Path $TempCLIPath -ErrorAction SilentlyContinue
                    Write-Error -Category InvalidData -Message "Downloaded $TempCLIPath is below MinimumVersion $MinimumVersion (got $TempCLIVersion)." -ErrorAction Stop
                }
            }
            catch {
                Remove-Item -Path $TempCLIPath -ErrorAction SilentlyContinue
                throw
            }

            if ($CLIFile.VersionInfo.FileVersion -eq $TempCLI.VersionInfo.FileVersion) {
                Write-Output "IISCrypto CLI up-to-date - $($CLIFile.VersionInfo.FileVersion)"
                if ($PSCmdlet.ShouldProcess($TempCLIPath, 'Remove temporary download')) {
                    Remove-Item -Path $TempCLIPath
                }
            }
            else {
                if ($PSCmdlet.ShouldProcess($CLIPath, 'Replace IISCryptoCli.exe with downloaded version')) {
                    Copy-Item -Path $TempCLIPath -Destination $EnvPath -Force
                    $CLIFile = Get-Item -Path $CLIPath
                    Write-Output "IISCrypto CLI updated to version - $($CLIFile.VersionInfo.FileVersion)"
                }
                if ($PSCmdlet.ShouldProcess($TempCLIPath, 'Remove temporary download')) {
                    Remove-Item -Path $TempCLIPath
                }
            }
        }
        else {
            Write-Verbose "Skipping CLI comparison; download not present at $TempCLIPath."
        }

        if (Test-Path -Path $GUIPath) {
            $GUIFile = Get-Item -Path $GUIPath

            if ($PSCmdlet.ShouldProcess($TempGUIPath, 'Download IISCrypto.exe from nartac.com')) {
                Invoke-RestMethod -Uri 'https://www.nartac.com/Downloads/IISCrypto/IISCrypto.exe' -OutFile $TempGUIPath
            }

            if (Test-Path -Path $TempGUIPath) {
                try {
                    if ($ExpectedSha256Gui) {
                        [void](Test-NartacBinary -Path $TempGUIPath -ExpectedSha256 $ExpectedSha256Gui)
                    }
                    else {
                        [void](Test-NartacBinary -Path $TempGUIPath)
                    }

                    $TempGUI = Get-Item -Path $TempGUIPath
                    $TempGUIVersion = [Version]$TempGUI.VersionInfo.FileVersion
                    if ($TempGUIVersion -lt $MinimumVersion) {
                        Remove-Item -Path $TempGUIPath -ErrorAction SilentlyContinue
                        Write-Error -Category InvalidData -Message "Downloaded $TempGUIPath is below MinimumVersion $MinimumVersion (got $TempGUIVersion)." -ErrorAction Stop
                    }
                }
                catch {
                    Remove-Item -Path $TempGUIPath -ErrorAction SilentlyContinue
                    throw
                }

                if ($GUIFile.VersionInfo.FileVersion -eq $TempGUI.VersionInfo.FileVersion) {
                    Write-Output "IISCrypto GUI up-to-date - $($GUIFile.VersionInfo.FileVersion)"
                    if ($PSCmdlet.ShouldProcess($TempGUIPath, 'Remove temporary download')) {
                        Remove-Item -Path $TempGUIPath
                    }
                }
                else {
                    if ($PSCmdlet.ShouldProcess($GUIPath, 'Replace IISCrypto.exe with downloaded version')) {
                        Copy-Item -Path $TempGUIPath -Destination $EnvPath -Force
                        $GUIFile = Get-Item -Path $GUIPath
                        Write-Output "IISCrypto GUI updated to version - $($GUIFile.VersionInfo.FileVersion)"
                    }
                    if ($PSCmdlet.ShouldProcess($TempGUIPath, 'Remove temporary download')) {
                        Remove-Item -Path $TempGUIPath
                    }
                }
            }
            else {
                Write-Verbose "Skipping GUI comparison; download not present at $TempGUIPath."
            }
        }
        else {
            Write-Verbose "IISCrypto GUI binary not present at $GUIPath; skipping GUI update."
        }
    }
}
