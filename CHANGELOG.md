# Changelog

## Unreleased
### Added
- instead of ActiveRecord::RecordInvalid, raise DenormalizedFields::RelatedRecordInvalid
  - inherits from ActiveRecord::RecordInvalid so rescuing is not affected
  - makes it more obvious where the error is coming from

### Fixed
- fixed NoMethodError when updating related errors that have errors on other, non-denormalized fields

## v1.2.1
### Fixed
- relaxed dependency spec to include rails 7

## v1.2.0
### Added
- `if:`, `unless:` modifiers

## v1.1.2
### Fixed
- wrong number of arguments error on ruby 3
