# Changelog

All notable changes to this project will be documented in this file. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-06-20

### Added

- Exported `Uninstall-IISCrypto` cmdlet (previously a stand-alone script with a destructive path-corruption bug).
- Comment-based help on `Update-IISCrypto` and `Uninstall-IISCrypto`.
- Explicit `FunctionsToExport`, `CmdletsToExport`, `VariablesToExport`, `AliasesToExport` in the manifest.
- `PowerShellVersion = '5.1'` and `CompatiblePSEditions = @('Desktop')` in the manifest.

### Fixed

- `Install-IISCrypto`: `$Test`-ordering bug — the "already installed" branch is now reachable.
- `Install-IISCrypto`: `CustomPath` is now validated as non-empty.
- `Set-IISCrypto`: `-template` and `-custom` are mutually exclusive; all switches now compose into a single `IISCryptoCli.exe` invocation per call.
- `Set-IISCrypto`: removed duplicate `IISC` alias (kept only on `Install-IISCrypto`).
- `Update-IISCrypto`: GUI binary processing guarded by `Test-Path`; logged `FileVersion` now reflects post-copy state.
- `Uninstall-IISCrypto`: removed `.Split('IISCrypto')` path-corruption bug; added three pre-flight guards.

### Changed

- Module version bumped to 0.2.0.
- Legacy `PSIISCrypto.script.psm1` moved to `archive/` to eliminate divergent source of truth.

## [0.1.0] - 2023-03-15

### Added

- Initial release: `Install-IISCrypto`, `Set-IISCrypto`, `Update-IISCrypto`.
