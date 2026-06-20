function Test-NartacBinary {
    <#
    .SYNOPSIS
        Verifies an Authenticode-signed Nartac binary and (optionally) its SHA256 hash.

    .DESCRIPTION
        Performs defence-in-depth verification on a downloaded Nartac Software binary
        (e.g. IISCryptoCli.exe or IISCrypto.exe) before it is moved into a trusted
        location. Always validates the Authenticode signature and checks that the
        signer certificate Subject contains the expected publisher substring
        (default 'Nartac'). When -ExpectedSha256 is supplied, additionally compares
        the file's SHA256 hash against the supplied value (case-insensitive).

        On failure, this function throws a terminating error via Write-Error
        -ErrorAction Stop. It does NOT delete the file under inspection; callers
        are responsible for cleanup of quarantined artefacts.

    .PARAMETER Path
        Full path to the file under verification.

    .PARAMETER ExpectedSha256
        Optional SHA256 hash (hex, any case). When supplied, the file hash must match
        exactly (case-insensitive) or verification fails.

    .PARAMETER ExpectedPublisherSubstring
        Substring that must appear in the Authenticode signer certificate Subject.
        Defaults to 'Nartac'.

    .EXAMPLE
        Test-NartacBinary -Path "$env:TEMP\IISCryptoCli.exe"

        Validates the Authenticode signature only and returns $true on success.

    .EXAMPLE
        Test-NartacBinary -Path "$env:TEMP\IISCryptoCli.exe" -ExpectedSha256 'ABCDEF...'

        Validates the Authenticode signature and confirms the SHA256 matches.

    .NOTES
        Internal helper for Install-IISCrypto and Update-IISCrypto. Does not perform
        cleanup; callers should Remove-Item the file on verification failure.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$ExpectedSha256,

        [Parameter(Mandatory = $false)]
        [string]$ExpectedPublisherSubstring = 'Nartac'
    )

    if (-not (Test-Path -Path $Path)) {
        Write-Error -Category ObjectNotFound -Message "File not found: $Path" -ErrorAction Stop
    }

    $sig = Get-AuthenticodeSignature -FilePath $Path
    $subject = if ($sig.SignerCertificate) { $sig.SignerCertificate.Subject } else { '<no signer>' }
    $publisherPattern = "*$ExpectedPublisherSubstring*"
    if ($sig.Status -ne 'Valid' -or -not ($subject -like $publisherPattern)) {
        Write-Error -Category SecurityError -Message "Authenticode verification failed for ${Path}: Status=$($sig.Status); Subject=$subject" -ErrorAction Stop
    }

    if ($PSBoundParameters.ContainsKey('ExpectedSha256') -and -not [string]::IsNullOrWhiteSpace($ExpectedSha256)) {
        $actual = (Get-FileHash -Path $Path -Algorithm SHA256).Hash.ToUpperInvariant()
        $expected = $ExpectedSha256.ToUpperInvariant()
        if ($actual -ne $expected) {
            Write-Error -Category SecurityError -Message "SHA256 mismatch for ${Path}: expected $expected; actual $actual" -ErrorAction Stop
        }
    }

    return $true
}
