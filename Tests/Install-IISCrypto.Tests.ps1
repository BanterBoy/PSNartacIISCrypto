#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
    $script:ModuleRoot = Split-Path -Parent $PSScriptRoot
    $script:ManifestPath = Join-Path $script:ModuleRoot 'PSIISCrypto\PSIISCrypto.psd1'
    Remove-Module PSIISCrypto -ErrorAction SilentlyContinue
    Import-Module $script:ManifestPath -Force
}

Describe 'Install-IISCrypto' {

    Context 'F4 regression - already installed branch' {
        It 'Emits "already installed" and does not call Invoke-RestMethod or New-Item when Test-Path returns true' {
            InModuleScope PSIISCrypto {
                Mock Test-Path { $true }
                Mock Invoke-RestMethod { }
                Mock New-Item { }
                Mock Add-EnvPath { }

                $output = Install-IISCrypto -InstallType Standard -Confirm:$false

                ($output -join ' ') | Should -Match 'already installed'
                Should -Invoke Invoke-RestMethod -Times 0 -Exactly
                Should -Invoke New-Item -Times 0 -Exactly
            }
        }
    }

    Context 'F5 regression - empty CustomPath rejected' {
        It 'Throws when -InstallType Custom -CustomPath '''' is supplied' {
            { Install-IISCrypto -InstallType Custom -CustomPath '' -Confirm:$false } |
            Should -Throw
        }
    }

    Context 'WhatIf safety' {
        It 'Performs no side-effecting calls under -WhatIf' {
            InModuleScope PSIISCrypto {
                Mock Invoke-RestMethod { }
                Mock New-Item { }
                Mock Add-EnvPath { }
                Mock Test-Path { $false }

                $null = Install-IISCrypto -InstallType Standard -WhatIf

                Should -Invoke Invoke-RestMethod -Times 0 -Exactly
                Should -Invoke New-Item -Times 0 -Exactly
                Should -Invoke Add-EnvPath -Times 0 -Exactly
            }
        }
    }
}
