@{
    IncludeDefaultRules = $true
    Severity            = @('Error', 'Warning')
    ExcludeRules        = @(
        # Justify each exclusion here.
        # Private helpers (Add-EnvPath/Remove-EnvPath) are internal-only and not part
        # of the public ShouldProcess-bearing surface. Repo convention reserves
        # SupportsShouldProcess for exported cmdlets in PSIISCrypto/Public/. See
        # ORCHESTRATOR.md §2 "Do" guidance.
        'PSUseShouldProcessForStateChangingFunctions'
    )
}
