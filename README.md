## version_assist

![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

A CLI tool for managing version numbers in Flutter/Dart projects.

## Installation 🚀

If the CLI application is available on [pub](https://pub.dev), activate globally via:

```sh
dart pub global activate version_assist
```

## Local Development 🛠️

1. Clone the repository:
```sh
git clone <repository-url>
cd version_assist
```

2. Install dependencies:
```sh
dart pub get
```

3. Run locally during development:
```sh
# Run directly with Dart
dart run bin/version_assist.dart bump

# Or use the make command if available
dart run bin/version_assist.dart bump --path=/path/to/pubspec.yaml
```

4. Activate locally for testing:
```sh
# From the version_assist directory
dart pub global activate --source path .

# Now you can run it like a global command
version_assist bump
```

## Usage

### Bump Version

The tool supports two versioning formats:

1. Simple increment: Increases the build number by 1
2. Date-based format: Uses format `yymmddbn` where:
   - `yy`: Year (e.g., 24 for 2024)
   - `mm`: Month (01-12)
   - `dd`: Day (01-31)
   - `bn`: Build number for the day (00-99)

Example date-based versions:
- `24111700`: First build on Nov 17, 2024
- `24111701`: Second build on Nov 17, 2024

```sh
# Simple increment
$ version_assist bump

# Date-based versioning (e.g., 24111700)
$ version_assist bump --date-based

# Specify custom pubspec.yaml path
$ version_assist bump --path path/to/pubspec.yaml

# Preview changes without making them (dry run)
$ version_assist bump --dry-run
```

The tool will automatically:
1. Update the version in pubspec.yaml
2. Create a git commit with the message format:
   ```
   build(versionCode+buildNumber): Automated version bump using version_assist
   ```
3. Create a git tag with the new version

### Update CLI

Update the CLI tool to the latest version.

```sh
$ version_assist update
```

### General Commands

```sh
# Show CLI version
$ version_assist --version

# Show usage help
$ version_assist --help
```

## Running Tests with coverage 🧪

To run all unit tests use the following command:

```sh
$ dart pub global activate coverage 1.2.0
$ dart test --coverage=coverage
$ dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
$ genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
$ open coverage/index.html
```

---

[coverage_badge]: coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli
