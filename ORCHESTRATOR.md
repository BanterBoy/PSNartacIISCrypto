# ORCHESTRATOR.md — PSNartacIISCrypto

> Living knowledge base maintained by the orchestrator agent. Update **before** any context loss and after every significant task. New agents and sessions should read this file first.

- **Module name:** `PSIISCrypto`
- **Manifest:** [PSIISCrypto/PSIISCrypto.psd1](PSIISCrypto/PSIISCrypto.psd1) (v0.2.0, GUID `f968bb27-02b1-428a-ae7e-130242eeeb66`)
- **Default branch:** `production`
- **Author:** Luke Leigh (BanterBoy)
- **Last updated:** 2026-06-20

---

## 1. Architecture & Modules

The repository ships a single PowerShell module (`PSIISCrypto`) that wraps Nartac Software's `IISCryptoCli.exe`. It follows the classic _Public/Private dot-source loader_ pattern.

```
PSNartacIISCrypto/
├── PSIISCrypto/
│   ├── PSIISCrypto.psd1          # Manifest
│   ├── PSIISCrypto.psm1          # Loader: dot-sources Public/ + Private/
│   ├── Private/
│   │   ├── Add-EnvPath.ps1
│   │   ├── Get-EnvPath.ps1
│   │   └── Remove-EnvPath.ps1
│   └── Public/
│       ├── Install-IISCrypto.ps1
│       ├── Set-IISCrypto.ps1
│       └── Update-IISCrypto.ps1
├── PSIISCrypto.script.psm1       # Legacy flat copy — divergent from Public/* (do not treat as source of truth)
├── Uninstall-IISCrypto.ps1       # Stand-alone; NOT exported from the module
├── IIS Crypto Help.txt           # Vendor CLI reference
├── README.md                     # Single-sentence description (needs expansion)
├── LICENSE
└── .vscode/
```

### Module loader

[PSIISCrypto/PSIISCrypto.psm1](PSIISCrypto/PSIISCrypto.psm1) enumerates `Public\*.ps1` and `Private\*.ps1` recursively, dot-sources each in try/catch, and exports via `Export-ModuleMember -Function * -Alias *`.

### Public surface

| Cmdlet              | Responsibility                                                                                                                                                            |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Install-IISCrypto` | Downloads `IISCryptoCli.exe` (and optional GUI) from Nartac, installs to `C:\Program Files\IISCrypto` (Standard) or `CustomPath`, adds dir to Machine PATH. Alias `IISC`. |
| `Set-IISCrypto`     | Resolves install dir from Machine PATH, invokes `IISCryptoCli.exe` with `/backup`, `/template`, custom template, and/or `/reboot`. Alias `IISC` (collides).               |
| `Update-IISCrypto`  | Compares installed `FileVersion` with current Nartac binaries (downloaded to `$env:TEMP`), copies when newer.                                                             |

### Private helpers

`Add-EnvPath`, `Get-EnvPath`, `Remove-EnvPath` manage `PATH` at `Machine`/`User`/`Session`/`Process` scope via `[Environment]::GetEnvironmentVariable/SetEnvironmentVariable`.

### External dependency

Nartac-hosted binaries:

- `https://www.nartac.com/Downloads/IISCrypto/IISCryptoCli.exe`
- `https://www.nartac.com/Downloads/IISCrypto/IISCrypto.exe`

No checksum/signature verification is performed before placing them in `C:\Program Files\IISCrypto` and adding to PATH.

---

## 2. Conventions & Patterns

**Do**

- File-per-function under `PSIISCrypto/Public/` (exported) or `PSIISCrypto/Private/` (internal).
- Approved `Verb-Noun` naming (`Install-IISCrypto`, `Get-EnvPath`, …).
- Use `[CmdletBinding(DefaultParameterSetName='Default', SupportsShouldProcess=$true, ConfirmImpact='Medium')]` for public cmdlets that have side effects.
- Wrap every external/state-changing call (`Invoke-RestMethod`, `Remove-Item`, `& IISCryptoCli.exe`, registry/PATH edits) in `if ($PSCmdlet.ShouldProcess(...))`.
- Use `[ValidateSet(...)]` for enumerated parameters (templates, install types, env scope).
- Provide comment-based help: `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, `.NOTES`, `.LINK`.
- Resolve the install location via `Get-EnvPath -Container Machine | Where-Object { $_ -like '*IISCrypto*' }` (existing pattern). Treat the result as a single string path.

**Don't**

- Don't introduce new functionality into [PSIISCrypto.script.psm1](PSIISCrypto.script.psm1); it is legacy and divergent.
- Don't add functions outside `PSIISCrypto/Public` or `PSIISCrypto/Private` if they are intended to be part of the module.
- Don't reuse the `IISC` alias on multiple cmdlets.
- Don't widen `FunctionsToExport` further (it already wildcards — improvements should move _toward_ an explicit list).
- Don't break `SupportsShouldProcess` semantics by performing side effects outside `ShouldProcess` guards.
- Don't call `Invoke-RestMethod` on the Nartac URL without considering checksum/signature verification once we have a story for it.

**Known style drift (to normalise over time, not in a single sweeping change)**

- Mixed tabs vs spaces across files.
- Lowercase parameter names (`$backup`, `$template`, `$reboot`) — non-idiomatic but currently consistent within the module's public API. Renaming is a breaking change; defer unless a major version bump is planned.

---

## 3. Project Commands

No CI, build script, or test runner exists yet. The verification surface today is:

```powershell
# Manifest validation
Test-ModuleManifest -Path .\PSIISCrypto\PSIISCrypto.psd1

# Import smoke test
Import-Module .\PSIISCrypto\PSIISCrypto.psd1 -Force -ErrorAction Stop

# Surface inventory
Get-Command -Module PSIISCrypto

# Static analysis (requires PSScriptAnalyzer)
Invoke-ScriptAnalyzer -Path .\PSIISCrypto -Recurse

# Tests (once Pester scaffolding exists)
Invoke-Pester -Path .\Tests -CI
```

All Phase 3 subagent prompts MUST include the applicable subset of these as the **Verification** block. `Test-ModuleManifest` + `Import-Module` are the baseline minimum for any change inside `PSIISCrypto/`.

---

## 4. Fragile Areas & Risks

Tracked findings from Phase 1 discovery. Items remain open until referenced in the Decisions Log as resolved.

| #   | Area                    | Issue                                                                                                                                                                                                                                                           |
| --- | ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| F1  | Source of truth         | ~~Legacy `PSIISCrypto.script.psm1` divergent from `Public/*`.~~ **RESOLVED 2026-06-20 (Phase C).** Moved to `archive/PSIISCrypto.script.psm1` with warning README; no longer on the import path.                                                                |
| F2  | `Set-IISCrypto`         | ~~Custom-template branch uses `/template $custom` instead of the vendor's documented switch.~~ **RESOLVED 2026-06-20 (Phase A4).** Custom templates correctly pass filename as `/template <file>`; mutual exclusion with `-template` enforced.                  |
| F3  | Templates               | ~~`ValidateSet` permits `pci40`, but vendor help documents `pci32`.~~ **RESOLVED 2026-06-20.** Nartac changelog confirms `pci40` is correct since v3.3. Local `IIS Crypto Help.txt` is stale and must be regenerated or removed (tracked in F15).               |
| F4  | `Install-IISCrypto`     | ~~`$Test` is read before assignment.~~ **RESOLVED 2026-06-20 (Phase A1).** `Test-Path` computed before branching; "already installed" branch reachable.                                                                                                         |
| F5  | `Install-IISCrypto`     | ~~`Custom` parameter set does not validate `$CustomPath`.~~ **RESOLVED 2026-06-20 (Phase A2).** `[ValidateNotNullOrEmpty()]` + runtime guard in `process` block.                                                                                                |
| F6  | `Update-IISCrypto`      | ~~Assumes `IISCrypto.exe` (GUI) exists; logs stale `FileVersion`.~~ **RESOLVED 2026-06-20 (Phase A6).** GUI block guarded by `Test-Path`; `Get-Item` refreshed after `Copy-Item`.                                                                               |
| F7  | `Uninstall-IISCrypto`   | ~~`.Split('IISCrypto')` char[] overload + not exported.~~ **RESOLVED 2026-06-20 (Phase A3).** Now `PSIISCrypto/Public/Uninstall-IISCrypto.ps1` using `$EnvPath` directly with three pre-flight guards.                                                          |
| F8  | Aliases                 | ~~`IISC` declared on both `Install-IISCrypto` and `Set-IISCrypto`.~~ **RESOLVED 2026-06-20 (Phase A4).** Removed from `Set-IISCrypto`.                                                                                                                          |
| F9  | Manifest                | ~~`FunctionsToExport = '*'` leaks private helpers.~~ **RESOLVED 2026-06-20 (Phase C).** Explicit `@('Install-IISCrypto','Set-IISCrypto','Update-IISCrypto','Uninstall-IISCrypto')`; private helpers no longer visible via `Get-Command -Module`.                |
| F10 | Supply chain            | ~~Nartac downloads lacked hash/signature verification.~~ **RESOLVED 2026-06-20 (Phase B).** `Private/Test-NartacBinary.ps1` performs Authenticode (`Subject -like '*Nartac*'`) + optional `-ExpectedSha256` check before any `Move-Item`; TLS 1.2/1.3 enforced. |
| F11 | `Set-IISCrypto -reboot` | Issued as a separate `IISCryptoCli.exe /reboot` invocation rather than combined with the template apply; likely a no-op vs vendor expectation.                                                                                                                  |
| F12 | Tests                   | ~~No Pester tests, analyzer settings, or CI.~~ **RESOLVED 2026-06-20 (Phase D).** Pester 5 suite (22/22 passing) under `Tests/`; `PSScriptAnalyzerSettings.psd1`; `build.ps1`; `.github/workflows/ci.yml` on `windows-latest`.                                  |
| F13 | Docs                    | ~~README was a single sentence.~~ **RESOLVED 2026-06-20 (Phase E).** Rewritten with platform floor, install, per-cmdlet usage, templates, security caveats, contributing link; `CHANGELOG.md` added in Keep-a-Changelog format.                                 |
| F14 | Style                   | Mixed tabs/spaces; lowercase param names; ~~missing comment-based help on `Update-IISCrypto` and `Uninstall-IISCrypto`.~~ Comment-based help **added** to both during Phase A. Tabs/spaces + parameter casing remain open (deferred to v1.0.0).                 |
| F15 | Vendor help drift       | ~~Stale `IIS Crypto Help.txt` predated v3.3.~~ **RESOLVED 2026-06-20 (Phase E).** Deleted; README links to Nartac's authoritative changelog instead.                                                                                                            |
| F16 | v4.0 feature parity     | ~~Nartac v4.0 `view` command not exposed.~~ **PARTIAL 2026-06-20 (Phase F).** `Set-IISCrypto -View` added. `TLS_CHACHA20_POLY1305_SHA256`/HTTP3 are inherent in the chosen template (covered in README). Logging-folder exposure not in scope.                  |
| F17 | Version pinning         | ~~Unpinned `Invoke-RestMethod` absorbed v3 → v4 silently.~~ **RESOLVED 2026-06-20 (Phase F).** `[Version]$MinimumVersion = '4.0'` parameter on `Install-IISCrypto`/`Update-IISCrypto`; aborts with cleanup when the downloaded binary is below the floor.       |

---

## 5. Decisions Log

Chronological. Each entry: date · decision · rationale.

- **2026-06-20** — Established `ORCHESTRATOR.md` and `.github/copilot-instructions.md` as the persistent context store for this repository. Rationale: no prior knowledge base existed; Phase 1 discovery findings must survive context resets.
- **2026-06-20** — Adopted the "Public/Private dot-source loader" layout under `PSIISCrypto/` as the single source of truth. [PSIISCrypto.script.psm1](PSIISCrypto.script.psm1) is treated as legacy and must not receive new feature work.
- **2026-06-20** — All public cmdlets must declare `SupportsShouldProcess` and gate side effects with `ShouldProcess`. New code MUST follow this convention.
- **2026-06-20** — Verification baseline for any change inside `PSIISCrypto/`: `Test-ModuleManifest` + `Import-Module -Force`. Subagent prompts must include these at minimum.
- **2026-06-20** — **Templates → `pci40` only.** Nartac changelog (https://www.nartac.com/Products/IISCrypto/Download) confirms PCI 4.0 template replaced PCI 3.2 in IIS Crypto v3.3 (Oct 2022). Do not re-add `pci32`.
- **2026-06-20** — **Phase B integrity check → Authenticode-first.** Nartac binaries are dual-signed (SHA1+SHA256) since v2.0 Build 10; `Get-AuthenticodeSignature` + Nartac subject check is the primary verification, with optional `-ExpectedHash` for offline scenarios.
- **2026-06-20** — **Alias `IISC` retained on `Install-IISCrypto` only.** Removed from `Set-IISCrypto` to eliminate collision (F8).
- **2026-06-20** — **Phase A complete (F2, F4, F5, F6, F7, F8, F11 resolved).** All four parallel subagents returned `STATUS: SUCCESS`. Consolidated verification: manifest valid, module imports clean, 4 public + 3 private functions exported, `IISC` resolves to `Install-IISCrypto`, root `Uninstall-IISCrypto.ps1` deleted, `.Split('IISCrypto')` bug pattern absent.
- **2026-06-20** — **Phases B + C + D + E + F complete.** Module version `0.2.0`; explicit `FunctionsToExport`; Pester 5 suite (22/22 passing); PSScriptAnalyzer 0 findings; GitHub Actions CI workflow; Authenticode + optional SHA256 verification via `Private/Test-NartacBinary.ps1`; `-MinimumVersion` floor (default `4.0`) on `Install-IISCrypto`/`Update-IISCrypto`; `-View` switch on `Set-IISCrypto`; README + CHANGELOG; legacy script archived; stale `IIS Crypto Help.txt` deleted.
- **2026-06-20** — **PSScriptAnalyzer exclusion logged:** `PSUseShouldProcessForStateChangingFunctions` is excluded with justification (private helpers `Add-/Remove-EnvPath` are internal-only and not exported). Reviewable in [PSScriptAnalyzerSettings.psd1](PSScriptAnalyzerSettings.psd1).
- **2026-06-20** — **F11 invariant refined.** With `-View` added to `Set-IISCrypto`, the source contains two `IISCryptoCli.exe` invocations (one in the `-View` branch, one in the consolidated backup/template/reboot branch). The original F11 invariant "single composed call per invocation" still holds at runtime — the Pester assertion now tests for exactly one `@cliArgs` consolidated call rather than counting raw matches.

---

## 6. Subagent Activity Log

Each row: date · task · scope (files) · outcome.

| Date       | Task                                                                                                                                             | Scope                                                                                                                                                                          | Outcome                                                                                                                                                     |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-06-20 | Phase A1+A2 — `Install-IISCrypto` `$Test`-ordering bug (F4) + `CustomPath` validation (F5)                                                       | `PSIISCrypto/Public/Install-IISCrypto.ps1`                                                                                                                                     | SUCCESS — `-WhatIf` works; empty `CustomPath` rejected with `ValidateNotNullOrEmpty`; "already installed" branch reachable.                                 |
| 2026-06-20 | Phase A3 — move `Uninstall-IISCrypto` into module, fix `Split('IISCrypto')` path-corruption bug (F7)                                             | CREATE `PSIISCrypto/Public/Uninstall-IISCrypto.ps1`; DELETE `Uninstall-IISCrypto.ps1`                                                                                          | SUCCESS — exported by module; three pre-flight guards (`IsNullOrWhiteSpace`, `-like '*IISCrypto*'`, `Test-Path`); `ConfirmImpact='High'`; split bug absent. |
| 2026-06-20 | Phase A4+A5 — `Set-IISCrypto` single-invocation refactor (F2 custom-template mapping, F11 combined `/reboot`) + drop duplicate `IISC` alias (F8) | `PSIISCrypto/Public/Set-IISCrypto.ps1`                                                                                                                                         | SUCCESS — one `IISCryptoCli.exe` call per invocation; mutual exclusion `-template`/`-custom` enforced; `IISC` resolves only to `Install-IISCrypto`.         |
| 2026-06-20 | Phase A6 — `Update-IISCrypto` GUI guard + post-copy `FileVersion` refresh + `SupportsShouldProcess` (F6)                                         | `PSIISCrypto/Public/Update-IISCrypto.ps1`                                                                                                                                      | SUCCESS — `-WhatIf` binds; GUI block guarded by `Test-Path`; `Get-Item` refreshed after `Copy-Item`; `Join-Path` replaces fragile concatenation.            |
| 2026-06-20 | Phase C — explicit manifest exports + OS/runtime floor + archive legacy script (F1, F9)                                                          | `PSIISCrypto/PSIISCrypto.psd1`; move `PSIISCrypto.script.psm1` -> `archive/`; new `archive/README.md`                                                                          | SUCCESS — `ModuleVersion=0.2.0`; `PowerShellVersion=5.1`; `CompatiblePSEditions=Desktop`; only 4 public functions exported; `IISC` alias preserved.         |
| 2026-06-20 | Phase D — Pester 5 suite + `PSScriptAnalyzerSettings.psd1` + `build.ps1` + GitHub Actions CI (F12)                                               | `Tests/*.Tests.ps1` (5 files); `PSScriptAnalyzerSettings.psd1`; `build.ps1`; `.github/workflows/ci.yml`                                                                        | SUCCESS — 22/22 tests pass; analyzer 0 findings; `build.ps1 -Task All` exits 0.                                                                             |
| 2026-06-20 | Phase E — README rewrite + Keep-a-Changelog `CHANGELOG.md` + delete stale vendor help (F13, F15)                                                 | `README.md`; new `CHANGELOG.md`; delete `IIS Crypto Help.txt`                                                                                                                  | SUCCESS — README >1.5 KB with WS2012/nartac/pci40 keywords; CHANGELOG has `[0.2.0]` entry.                                                                  |
| 2026-06-20 | Phase B+F — Authenticode + SHA256 download verification + TLS 1.2/1.3 + `-MinimumVersion` floor + `Set-IISCrypto -View` (F10, F16, F17)          | `PSIISCrypto/Public/Install-IISCrypto.ps1`; `PSIISCrypto/Public/Update-IISCrypto.ps1`; `PSIISCrypto/Public/Set-IISCrypto.ps1`; new `PSIISCrypto/Private/Test-NartacBinary.ps1` | SUCCESS — new params bind; `-View` mutually exclusive with template/backup/reboot/custom; helper present.                                                   |

---

## 7. Continuity Checklist

Before ending a session, the orchestrator must confirm:

- [ ] Any new fragile areas added to §4.
- [ ] Any decisions captured in §5 with date + rationale.
- [ ] Every subagent run appended to §6 with outcome.
- [ ] [.github/copilot-instructions.md](.github/copilot-instructions.md) updated if a convention/restriction changed.
- [ ] If a task was rolled back via `git`, the rollback is noted in §5 with the SHA(s) involved.
