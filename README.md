# PSNartacIISCrypto

`PSNartacIISCrypto` is a PowerShell wrapper around [Nartac Software](https://www.nartac.com/)'s `IISCryptoCli.exe`. It automates downloading, installing, configuring, updating, and uninstalling IIS Crypto so that hardening Windows TLS / cipher-suite configuration can be driven from scripts, build pipelines, and DSC-style workflows instead of the GUI.

## Supported platforms

- **Operating system:** Windows Server 2012+ with .NET Framework 4.6.2+ (per Nartac IIS Crypto v4.0 system requirements).
- **PowerShell:** Windows PowerShell 5.1 (Desktop edition). The module is not currently validated against PowerShell 7 / Core.
- **Architecture:** x64 Windows hosts where `IISCryptoCli.exe` is supported by Nartac.

## Installation

The module is not yet published to the PowerShell Gallery (publication TBD). For now, clone the repository and import the module manifest directly:

```powershell
git clone https://github.com/<your-fork>/PSNartacIISCrypto.git
Set-Location .\PSNartacIISCrypto
Import-Module .\PSIISCrypto\PSIISCrypto.psd1 -Force
Get-Command -Module PSIISCrypto
```

To make the import persistent, copy the `PSIISCrypto` folder into a path on `$env:PSModulePath` (for example `C:\Program Files\WindowsPowerShell\Modules\PSIISCrypto`).

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

### Apply a built-in template with a registry backup

```powershell
Set-IISCrypto -template best -backup 'C:\backup\bk.reg'
```

### Apply the PCI 4.0 template and reboot

```powershell
Set-IISCrypto -template pci40 -reboot
```

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

> **Warning:** the current release does **not** verify the integrity or authenticity of `IISCryptoCli.exe` after download.

- Downloaded binaries are executed as-is. There is no Authenticode signature check and no SHA-256 comparison against a known-good hash.
- Phase B of the module roadmap (in flight — see [ORCHESTRATOR.md](ORCHESTRATOR.md)) introduces Authenticode verification plus an optional `-ExpectedSha256` parameter on `Install-IISCrypto` and `Update-IISCrypto`.
- Until that lands, verify downloads yourself: compare the file hash against the value published on [nartac.com](https://www.nartac.com/Products/IISCrypto/Download) and confirm the Authenticode signature with `Get-AuthenticodeSignature` before running any installer in production.

## Contributing

Coding conventions, agent workflow, known fragile areas, and the verification checklist live in [ORCHESTRATOR.md](ORCHESTRATOR.md). Read it before opening a PR or running an automated coding agent against this repo.

## License

Released under the terms of the [LICENSE](LICENSE) file in the repository root.
