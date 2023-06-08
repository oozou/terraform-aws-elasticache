# Change Log

All notable changes to this module will be documented in this file.

## [v2.0.0] - 2023-06-08

### BREAKING CHANGES

- Upgrade the AWS provider to version 5 with the constraint of `>= 5.0.0, < 6.0.0`.


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
