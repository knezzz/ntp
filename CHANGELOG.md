## [1.0.8] - 19.01.2021.

- Change DNS resolver to DoH
- Change default lookupAddress to `time.google.com`
- You can change lookupAddress on `NTP.now()`

## [1.0.7] - 02.07.2020.

- Support for IPv6 and IPv4 addresses
- Fix timing on first getNtpOffset call

## [1.0.6] - 13.01.2019.

- Fix [Issue #13](https://github.com/knezzz/ntp/issues/13)

## [1.0.5] - 13.01.2019.

- Move test to example (since it uses Flutter dependency)
- Update package

## [1.0.4] - 12.07.2019.

- Fix now() function

## [1.0.3] - 25.03.2019.

- Fix returning future, may fix #1

## [1.0.2] - 22.10.2018.

- Updated description and code cleanup

## [1.0.1] - 22.07.2018.

- Added example
- Updated README.md

## [1.0.0] - 18.07.2018.

- Methods in NTP are now static.
- Added now() for returning current DateTime object with calculated NTP offset

- getNtpTime was renamed to getNtpOffset (since it is returning int offset in milliseconds)

## [0.0.1] - 16.04.2018.

- Get NTP clock offset
