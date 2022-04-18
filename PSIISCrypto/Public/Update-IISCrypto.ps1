function Update-IISCrypto {
    $EnvPath = Get-EnvPath -Container Machine | Where-Object -FilterScript { $_ -Like '*IISCrypto*' }
    Invoke-RestMethod -Uri "https://www.nartac.com/Downloads/IISCrypto/IISCryptoCli.exe" -OutFile "$env:TEMP\IISCryptoCli.exe"
    Invoke-RestMethod -Uri "https://www.nartac.com/Downloads/IISCrypto/IISCrypto.exe" -OutFile "$env:TEMP\IISCrypto.exe"
    $CLIFile = Get-Item -Path "$EnvPath\IISCryptoCli.exe"
    $GUIFile = Get-Item -Path "$EnvPath\IISCrypto.exe"
            
    $TempCLI = Get-ChildItem -Path $env:TEMP\IISCryptoCli.exe
    $TempGUI = Get-ChildItem -Path $env:TEMP\IISCrypto.exe
        
    if ($CLIFile.VersionInfo.FileVersion -eq $TempCLI.VersionInfo.FileVersion) {
        Write-Output "Curent Version up-to-date - $($CLIFile.VersionInfo.FileVersion)"
    }
    else {
        Copy-Item -Path $TempCLI -Destination $EnvPath
        Write-Output "Updated to latest version - $($CLIFile.VersionInfo.FileVersion)"
        Remove-Item -Path $TempCLI
    }

    if ($GUIFile.VersionInfo.FileVersion -eq $TempGUI.VersionInfo.FileVersion) {
        Write-Output "Curent Version up-to-date - $($GUIFile.VersionInfo.FileVersion)"
    }
    else {
        Copy-Item -Path $TempGUI -Destination $EnvPath
        Write-Output "Updated to latest version - $($GUIFile.VersionInfo.FileVersion)"
        Remove-Item -Path $TempGUI
    }
}
