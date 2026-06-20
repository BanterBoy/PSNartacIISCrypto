# PSNartacIISCrypto

`PSNartacIISCrypto` is a PowerShell wrapper around [Nartac Software](https://www.nartac.com/)'s `IISCryptoCli.exe`. It automates downloading, installing, configuring, updating, and uninstalling IIS Crypto so that hardening Windows TLS / cipher-suite configuration can be driven from scripts, build pipelines, and DSC-style workflows instead of the GUI.

## Supported platforms

- **Operating system:** Windows Server 2012+ with .NET Framework 4.6.2+ (per Nartac IIS Crypto v4.0 system requirements).
- **PowerShell:** Windows PowerShell 5.1 (Desktop edition). The module is not currently validated against PowerShell 7 / Core.
- **Architecture:** x64 Windows hosts where `IISCryptoCli.exe` is supported by Nartac.

## Installation

The module is not yet published to the PowerShell Gallery (publication TBD). For now, clone the repository and import the module manifest directly:

```powershell
git clone https://github.com/BanterBoy/PSNartacIISCrypto.git
Set-Location .\PSNartacIISCrypto
Import-Module .\PSIISCrypto\PSIISCrypto.psd1 -Force
Get-Command -Module PSIISCrypto
```

To make the import persistent, copy the `PSIISCrypto` folder into a path on `$env:PSModulePath` (for example `C:\Program Files\WindowsPowerShell\Modules\PSIISCrypto`).

Four public cmdlets are exported:

| Cmdlet                | Purpose                                                                                        |
| --------------------- | ---------------------------------------------------------------------------------------------- |
| `Install-IISCrypto`   | Download (CLI + optional GUI) and install IIS Crypto, register on Machine PATH. Alias: `IISC`. |
| `Set-IISCrypto`       | Apply a template, take a backup, view current settings, and/or reboot — in a single CLI call.  |
| `Update-IISCrypto`    | Refresh installed binaries when Nartac publishes a newer version.                              |
| `Uninstall-IISCrypto` | Remove the install directory and PATH entry. `ConfirmImpact = High`.                           |

## Usage

All side-effecting cmdlets support `-WhatIf` and `-Confirm`. Run them with `-WhatIf` first to preview what will happen.

### Install IIS Crypto (standard location)

```powershell
Install-IISCrypto -InstallType Standard -WhatIf
```

### Install IIS Crypto to a custom location

```powershell
Install-IISCrypto -InstallType Custom -CustomPath 'D:\Software\IISCrypto'
```

### Install with explicit version floor and hash pin

```powershell
Install-IISCrypto `
    -InstallType Standard `
    -MinimumVersion '4.0' `
    -ExpectedSha256Cli '<known-good-SHA256-of-IISCryptoCli.exe>'
```

`-MinimumVersion` (default `4.0`) aborts the install if the downloaded binary's `FileVersion` is lower than the pinned floor — protection against silently absorbing future Nartac major-version breaks.

### Apply a built-in template with a registry backup

```powershell
Set-IISCrypto -template best -backup 'C:\backup\bk.reg'
```

### Apply the PCI 4.0 template and reboot

```powershell
Set-IISCrypto -template pci40 -reboot
```

### View the current Schannel settings

```powershell
Set-IISCrypto -View
```

`-View` wraps `IISCryptoCli.exe /view` (added by Nartac in v4.0). It is mutually exclusive with `-backup`, `-template`, `-custom`, and `-reboot`.

### Update an existing IIS Crypto install

```powershell
Update-IISCrypto -WhatIf
```

### Uninstall IIS Crypto

```powershell
Uninstall-IISCrypto -WhatIf
```

## Templates

`Set-IISCrypto -template <name>` accepts the templates shipped by Nartac IIS Crypto:

| Template  | Purpose                                                                |
| --------- | ---------------------------------------------------------------------- |
| `best`    | Nartac's recommended modern best-practice cipher suite / protocol set. |
| `pci40`   | PCI DSS 4.0 compliance profile.                                        |
| `strict`  | A tighter superset of `best`, suitable for hardened internal systems.  |
| `fips140` | FIPS 140-2/3 compliant subset.                                         |
| `default` | Restores Windows defaults for the current OS version.                  |

> See the [IIS Crypto release notes / changelog](https://www.nartac.com/Products/IISCrypto/Download) for the authoritative list of templates and protocol/cipher changes per release (Nartac updated the PCI template to `pci40` in v3.3).

## Security

Downloads from `nartac.com` are verified before being moved into the install directory:

- **Authenticode (always on).** Every downloaded binary must have a `Valid` signature whose subject contains `Nartac`. Nartac dual-signs (SHA1 + SHA256) all releases since v2.0 Build 10.
- **TLS 1.2 / 1.3** is enforced on the `Invoke-RestMethod` channel.
- **Optional SHA-256 pinning.** Pass `-ExpectedSha256Cli` (and `-ExpectedSha256Gui` when using `-installGUI`) on `Install-IISCrypto`/`Update-IISCrypto` for air-gapped or change-controlled environments.
- **Version floor.** `-MinimumVersion` (default `4.0`) refuses binaries below the pinned `FileVersion`.
- **Temp staging.** Downloads land in `$env:TEMP` first, are verified there, and are only moved/copied into `C:\Program Files\IISCrypto` (or your `-CustomPath`) after verification succeeds. Verification failures delete the temp file and abort.

If a download ever fails verification, do **not** suppress the error — capture the actual Authenticode `Subject` / hash and report it as a potential supply-chain incident.

## Development

The repo ships with a local CI pipeline. Run the same checks GitHub Actions runs:

```powershell
.\build.ps1 -Task All        # manifest + analyzer + Pester
.\build.ps1 -Task Test       # Pester only
.\build.ps1 -Task Analyze    # PSScriptAnalyzer only
```

- **Tests:** Pester 5 suite under [Tests/](Tests/) (22 tests, no live network).
- **Lint:** PSScriptAnalyzer driven by [PSScriptAnalyzerSettings.psd1](PSScriptAnalyzerSettings.psd1).
- **CI:** [.github/workflows/ci.yml](.github/workflows/ci.yml) runs `build.ps1 -Task All` on `windows-latest` for every push and PR.

Version history is in [CHANGELOG.md](CHANGELOG.md).

## Contributing

Coding conventions, agent workflow, known fragile areas, and the verification checklist live in [ORCHESTRATOR.md](ORCHESTRATOR.md). Read it before opening a PR or running an automated coding agent against this repo.

## License

Released under the terms of the [LICENSE](LICENSE) file in the repository root.
