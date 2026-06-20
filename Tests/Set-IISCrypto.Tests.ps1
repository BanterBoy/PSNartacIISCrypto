#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
    $script:ModuleRoot = Split-Path -Parent $PSScriptRoot
    $script:ManifestPath = Join-Path $script:ModuleRoot 'PSIISCrypto\PSIISCrypto.psd1'
    $script:SetSourcePath = Join-Path $script:ModuleRoot 'PSIISCrypto\Public\Set-IISCrypto.ps1'
    Remove-Module PSIISCrypto -ErrorAction SilentlyContinue
    Import-Module $script:ManifestPath -Force
}

Describe 'Set-IISCrypto' {

    Context 'F8 regression - IISC alias no longer collides' {
        It 'Alias IISC resolves only to Install-IISCrypto' {
            (Get-Alias IISC -ErrorAction Stop).ResolvedCommandName | Should -Be 'Install-IISCrypto'
        }
    }

    Context 'F11 regression - single CLI invocation' {
        It 'Source contains exactly one consolidated & "$EnvPath\IISCryptoCli.exe" @cliArgs invocation' {
            # F11 invariant: backup/template/reboot share ONE invocation via splatted $cliArgs.
            # Phase B+F may add additional read-only invocations (e.g. /view) with literal
            # argument lists; those are tolerated. Only the consolidated @cliArgs call is constrained.
            $consolidated = Select-String -Path $script:SetSourcePath -Pattern '\& "\$EnvPath\\IISCryptoCli\.exe" @cliArgs'
            ($consolidated | Measure-Object).Count | Should -Be 1
        }

        It 'Source contains at least one & "$EnvPath\IISCryptoCli.exe" invocation' {
            $any = Select-String -Path $script:SetSourcePath -Pattern '\& "\$EnvPath\\IISCryptoCli\.exe"'
            ($any | Measure-Object).Count | Should -BeGreaterOrEqual 1
        }
    }

    Context 'F2 regression - template/custom mutual exclusion' {
        It 'Throws when both -template and -custom are supplied' {
            InModuleScope PSIISCrypto {
                Mock Get-EnvPath { 'C:\Fake\IISCrypto' }
                { Set-IISCrypto -template best -custom 'C:\x.ictpl' -WhatIf -ErrorAction Stop } |
                Should -Throw
            }
        }
    }

    Context 'ValidateSet for -template' {
        BeforeAll {
            $script:TemplateValues = (Get-Command Set-IISCrypto).Parameters['template'].Attributes |
            Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] } |
            ForEach-Object { $_.ValidValues }
        }

        It 'Contains pci40' {
            $script:TemplateValues | Should -Contain 'pci40'
        }

        It 'Does not contain pci32' {
            $script:TemplateValues | Should -Not -Contain 'pci32'
        }
    }
}
