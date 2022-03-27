function Install-IISCrypto {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        
    }
    
    end {
        
    }
}

$Test = Test-Path -Path 'C:\IISCrypto'
Write-Output -InputObject $Test
if (!$Test) {
New-Item -Path 'C:\' -Name 'IISCrypto' -Type Directory
Invoke-RestMethod -Uri "https://www.nartac.com/Downloads/IISCrypto/IISCryptoCli.exe" -OutFile "C:\IISCrypto\IISCryptoCli.exe"
$Test = Test-Path -Path 'C:\IISCrypto'
Write-Output -InputObject $Test
}
