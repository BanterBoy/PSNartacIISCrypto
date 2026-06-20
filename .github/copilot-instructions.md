# Copilot Instructions — PSNartacIISCrypto

These rules apply to every Copilot Chat / agent session in this repository. They mirror the conventions captured in [ORCHESTRATOR.md](../ORCHESTRATOR.md); update both files in lockstep.

## Project shape
- This repo ships one PowerShell module: `PSIISCrypto` ([PSIISCrypto/PSIISCrypto.psd1](../PSIISCrypto/PSIISCrypto.psd1)).
- Source of truth is `PSIISCrypto/Public/*.ps1` (exported) and `PSIISCrypto/Private/*.ps1` (internal helpers), loaded by [PSIISCrypto/PSIISCrypto.psm1](../PSIISCrypto/PSIISCrypto.psm1).
- [PSIISCrypto.script.psm1](../PSIISCrypto.script.psm1) is **legacy** and divergent — never add new code there.
- [Uninstall-IISCrypto.ps1](../Uninstall-IISCrypto.ps1) at the repo root is currently outside the module and contains a known path-split bug; do not copy its pattern.

## Coding conventions
- File-per-function. Place exported functions in `PSIISCrypto/Public/`; internal helpers in `PSIISCrypto/Private/`.
- Use approved `Verb-Noun` names (`Get-Verb`).
- Every public cmdlet:
  - `[CmdletBinding(DefaultParameterSetName='Default', SupportsShouldProcess=$true, ConfirmImpact='Medium')]`
  - Gate every side-effecting call (`Invoke-RestMethod`, `Remove-Item`, `Copy-Item`, `& IISCryptoCli.exe`, registry/PATH edits) with `if ($PSCmdlet.ShouldProcess(...))`.
  - Provide full comment-based help: `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, `.NOTES`, `.LINK`.
  - Use `[ValidateSet(...)]` for enumerated values.
- Resolve the IIS Crypto install dir via `Get-EnvPath -Container Machine | Where-Object { $_ -like '*IISCrypto*' }` (existing pattern).
- Don't reuse the `IISC` alias; it already collides between `Install-IISCrypto` and `Set-IISCrypto`.
- Don't widen `FunctionsToExport` further — prefer moving toward an explicit list.
- Preserve existing public parameter names (`$backup`, `$template`, `$reboot`, etc.) — renaming is a breaking change.

## Style
- Match the surrounding file's indentation (tabs vs spaces). Do not retab files as a drive-by change.
- Keep helpers in `Private/` unless they are intentionally part of the public API.

## Security
- Never invoke the Nartac download URLs without considering hash/signature verification.
- Never run executables downloaded at runtime without `ShouldProcess` guards.
- Do not log secrets, tokens, or full registry dumps.

## Verification (run after every change inside `PSIISCrypto/`)
```powershell
Test-ModuleManifest -Path .\PSIISCrypto\PSIISCrypto.psd1
Import-Module       .\PSIISCrypto\PSIISCrypto.psd1 -Force -ErrorAction Stop
Get-Command -Module PSIISCrypto
# Optional when installed:
Invoke-ScriptAnalyzer -Path .\PSIISCrypto -Recurse
```
At minimum, `Test-ModuleManifest` and `Import-Module -Force` must succeed before a change is considered done.

## Orchestrator workflow (agent sessions)
- The orchestrator agent must delegate implementation to subagents with an explicit **Scope** (allow-list of files), **Constraints**, **Verification** commands, **Definition of Done**, and **Failure Protocol** (`STATUS: FAILED` on inability to complete).
- Subagents must not modify files outside their declared scope.
- After every subagent run, append a row to the *Subagent Activity Log* in [ORCHESTRATOR.md](../ORCHESTRATOR.md) and capture any new decision in the *Decisions Log*.
- Before any potential context loss, sync new insights into [ORCHESTRATOR.md](../ORCHESTRATOR.md).

## Known fragile areas (see [ORCHESTRATOR.md §4](../ORCHESTRATOR.md))
- `Install-IISCrypto`: `$Test`-ordering bug; missing `CustomPath` validation.
- `Set-IISCrypto`: `pci32` vs `pci40` mismatch with vendor docs; custom-template branch uses `/template`.
- `Update-IISCrypto`: assumes GUI binary exists; logs stale `FileVersion` after copy.
- `Uninstall-IISCrypto`: `Split('IISCrypto')` uses `char[]` overload — path corruption risk.
- Alias `IISC` collides between two cmdlets.
- No tests, no PSScriptAnalyzer settings, no CI.
