
function Update-IISCrypto {
    Invoke-RestMethod -Uri "https://www.nartac.com/Downloads/IISCrypto/IISCryptoCli.exe" -OutFile "$env:TEMP\IISCrypto.exe"
    $File = Get-Item -Path "$env:TEMP\IISCrypto.exe"
    $IISCrypto = Get-ChildItem -Path C:\CustomPath\IISCrypto\IISCryptoCli.exe
    
    if ($IISCrypto.VersionInfo.FileVersion -eq $File.VersionInfo.FileVersion) {
        Write-Output "Curent Version up-to-date - $($File.VersionInfo.FileVersion)"
    }
    else {
        Copy-Item -Path $File -Destination $IISCrypto
        Write-Output "Updated to latest version - $($File.VersionInfo.FileVersion)"
    }
    Remove-Item -Path $File
}
