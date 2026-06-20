[CmdletBinding()]
param([ValidateSet('Build', 'Test', 'Analyze', 'All')][string]$Task = 'All')
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

function Invoke-Build {
    Test-ModuleManifest -Path .\PSIISCrypto\PSIISCrypto.psd1
    Remove-Module PSIISCrypto -EA SilentlyContinue
    Import-Module .\PSIISCrypto\PSIISCrypto.psd1 -Force
}

function Invoke-Analyze {
    if (-not (Get-Module -ListAvailable PSScriptAnalyzer)) {
        Install-Module PSScriptAnalyzer -Scope CurrentUser -Force
    }
    Invoke-ScriptAnalyzer -Path .\PSIISCrypto -Recurse -Settings .\PSScriptAnalyzerSettings.psd1 -EnableExit
}

function Invoke-Test {
    if (-not (Get-Module -ListAvailable Pester | Where-Object { $_.Version -ge [version]'5.0' })) {
        Install-Module Pester -MinimumVersion 5.0 -Scope CurrentUser -Force -SkipPublisherCheck
    }
    Import-Module Pester -MinimumVersion 5.0 -Force
    $cfg = New-PesterConfiguration
    $cfg.Run.Path = '.\Tests'
    $cfg.Output.Verbosity = 'Detailed'
    $cfg.Run.Exit = $true
    Invoke-Pester -Configuration $cfg
}

switch ($Task) {
    'Build' { Invoke-Build }
    'Test' { Invoke-Build; Invoke-Test }
    'Analyze' { Invoke-Build; Invoke-Analyze }
    'All' { Invoke-Build; Invoke-Analyze; Invoke-Test }
}
