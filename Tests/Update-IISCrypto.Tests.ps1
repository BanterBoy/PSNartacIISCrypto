#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
    $script:ModuleRoot = Split-Path -Parent $PSScriptRoot
    $script:ManifestPath = Join-Path $script:ModuleRoot 'PSIISCrypto\PSIISCrypto.psd1'
    Remove-Module PSIISCrypto -ErrorAction SilentlyContinue
    Import-Module $script:ManifestPath -Force
}

Describe 'Update-IISCrypto' {

    Context 'WhatIf parameter' {
        It 'Binds -WhatIf via SupportsShouldProcess' {
            (Get-Command Update-IISCrypto).Parameters.ContainsKey('WhatIf') | Should -BeTrue
        }
    }

    Context 'F6 regression - CLI-only install does not throw on missing GUI' {
        It 'Does not throw when CLI exists but GUI is absent' {
            InModuleScope PSIISCrypto {
                $fake = 'C:\Fake\IISCrypto'
                Mock Get-EnvPath { $fake }
                Mock Test-Path {
                    param($Path)
                    if ($Path -eq (Join-Path $fake 'IISCryptoCli.exe')) { return $true }
                    return $false
                }
                Mock Get-Item {
                    param($Path)
                    [pscustomobject]@{
                        FullName    = $Path
                        VersionInfo = [pscustomobject]@{ FileVersion = '4.0.0.0' }
                    }
                }
                Mock Invoke-RestMethod { }
                Mock Copy-Item { }
                Mock Remove-Item { }

                { Update-IISCrypto -WhatIf -ErrorAction Stop } | Should -Not -Throw
            }
        }
    }
}
