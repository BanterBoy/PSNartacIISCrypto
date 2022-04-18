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

