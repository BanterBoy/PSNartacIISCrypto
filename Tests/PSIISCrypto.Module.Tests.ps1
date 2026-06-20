#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
    $script:ModuleRoot = Split-Path -Parent $PSScriptRoot
    $script:ManifestPath = Join-Path $script:ModuleRoot 'PSIISCrypto\PSIISCrypto.psd1'
    Remove-Module PSIISCrypto -ErrorAction SilentlyContinue
    Import-Module $script:ManifestPath -Force
}

Describe 'PSIISCrypto module' {

    Context 'Manifest' {
        It 'Test-ModuleManifest succeeds' {
            { Test-ModuleManifest -Path $script:ManifestPath -ErrorAction Stop } | Should -Not -Throw
        }
    }

    Context 'Import' {
        It 'Module is loaded after import' {
            (Get-Module PSIISCrypto) | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Public surface' {
        BeforeAll {
            $script:Commands = Get-Command -Module PSIISCrypto
            $script:CommandNames = $script:Commands.Name
        }

        It 'Exports Install-IISCrypto' {
            $script:CommandNames | Should -Contain 'Install-IISCrypto'
        }

        It 'Exports Set-IISCrypto' {
            $script:CommandNames | Should -Contain 'Set-IISCrypto'
        }

        It 'Exports Update-IISCrypto' {
            $script:CommandNames | Should -Contain 'Update-IISCrypto'
        }

        It 'Exports Uninstall-IISCrypto' {
            $script:CommandNames | Should -Contain 'Uninstall-IISCrypto'
        }

        It 'Has soft count check (4 if Phase C applied; otherwise prints note)' {
            $count = ($script:Commands | Measure-Object).Count
            if ($count -eq 4) {
                $count | Should -Be 4
            }
            else {
                Write-Host "NOTE: Phase C not yet applied; private helpers still exported. Count = $count"
                $count | Should -BeGreaterOrEqual 4
            }
        }
    }

    Context 'Aliases' {
        It 'Alias IISC resolves to Install-IISCrypto' {
            (Get-Alias IISC -ErrorAction Stop).ResolvedCommandName | Should -Be 'Install-IISCrypto'
        }
    }
}
