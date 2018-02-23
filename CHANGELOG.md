## Changelog

## v0.5.0 - 2018-02-23

### Changed

* All null mac addresses are now excluded when choosing the default interface for
generating worker ids.

## v0.4.0 - 2016-12-22

### Changed

* Bump [base62](https://github.com/igas/base62) to 1.2.1.

### Fixed

* Fix compiler warnings for Elixir 1.5.

## v0.3.0 - 2016-03-15

### Removed

* `Ecto.Bigflake.UUID` has been removed. This module doesn't belong in the library. More documentation has been added
showing how to use Bigflake ids with Ecto.

## v0.2.0 - 2016-03-12

### Added

* Add support for minting base62 encoded Bigflake ids

### Changed

* Update module namespace of `Bigflake.Ecto.UUID` to `Ecto.Bigflake.UUID`

## v0.1.0

* Initial version
