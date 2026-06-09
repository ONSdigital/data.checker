# Changelog

## data.checker 2.0.0

CRAN release: 2026-06-08

### Added

- Support for SparklyR
- Extended schema checks for types and expected checks based on type
- Backseries checks
- Interquartile range checks
- Z score check

### Changed

- Rewrote backend for checks, now using pointblank for validation
- `allowed_strings` renamed `allowed_values` and now works for all data
  types
- `forbidden_strings` renamed `forbidden_values` and now works for all
  data types

### Removed

- Number of decimal place checks

### Fixed

- misc bugs
- issue where using a column named `i` would cause unexpected failures
  with unclear error message

## data.checker 1.0.0

- Package release

- Added documentation and vignettes

## data.checker v0.1.0

Initial package creation
