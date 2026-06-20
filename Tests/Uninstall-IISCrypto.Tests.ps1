#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
    $script:ModuleRoot = Split-Path -Parent $PSScriptRoot
    $script:ManifestPath = Join-Path $script:ModuleRoot 'PSIISCrypto\PSIISCrypto.psd1'
    $script:UninstallSourcePath = Join-Path $script:ModuleRoot 'PSIISCrypto\Public\Uninstall-IISCrypto.ps1'
    Remove-Module PSIISCrypto -ErrorAction SilentlyContinue
    Import-Module $script:ManifestPath -Force
}

Describe 'Uninstall-IISCrypto' {

    Context 'F7 regression - Split path-corruption bug removed' {
        It 'Source contains zero matches for .Split(''IISCrypto'')' {
            $matches = Select-String -Path $script:UninstallSourcePath -Pattern ".Split('IISCrypto')" -SimpleMatch
            ($matches | Measure-Object).Count | Should -Be 0
        }
    }

    Context 'ConfirmImpact' {
        It 'Declares ConfirmImpact = High' {
            $cmd = Get-Command Uninstall-IISCrypto
            $cmdletBinding = $cmd.ScriptBlock.Attributes |
            Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] } |
            Select-Object -First 1
            $cmdletBinding.ConfirmImpact | Should -Be 'High'
        }
    }

    Context 'WhatIf safety' {
        It 'Does not invoke Remove-Item under -WhatIf' {
            InModuleScope PSIISCrypto {
                Mock Get-EnvPath { 'C:\Fake\IISCrypto' }
                Mock Test-Path { $true }
                Mock Remove-Item { }
                Mock Remove-EnvPath { }

                $null = Uninstall-IISCrypto -WhatIf

                Should -Invoke Remove-Item -Times 0 -Exactly
            }
        }
    }
}
