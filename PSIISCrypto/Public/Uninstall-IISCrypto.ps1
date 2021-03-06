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
