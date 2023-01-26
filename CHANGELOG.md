# Change Log

All notable changes to this module will be documented in this file.

## [v1.0.3] - 2023-01-26

### Added

- Add options to enable or disable encryptions (in-transit, at-rest)
- Add following vars
    - is_enable_at_rest_encryption
    - is_enable_transit_encryption

## [v1.0.2] - 2022-12-22

### Added

- Add alarm.tf with default and custom elasticache alarms
- Add following vars
    - is_enable_default_alarms
    - default_alarm_actions
    - default_ok_actions
    - custom_elasticache_alarms_configure

## [1.0.1] - 2022-05-24
  
Here we would have the update steps for 1.0.1 for people to follow.

### Fix

- change naming support more than 20 character

## [1.0.0] - 2022-04-18

### Added

- init terraform-aws-elasticache module
