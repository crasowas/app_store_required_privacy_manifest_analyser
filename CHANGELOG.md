## 2024-12-19
- Rename `privacy_manifest_analyser.sh` to `analyser.sh`.

## 2024-12-01
- Enhance recognition for commonly used SDKs.

## 2024-05-13
- Add `-d` command line option.

## 2024-05-08
- Add support for analyzing dependencies managed by Carthage.
- Rename `ios_spm_example` to `ios_swiftpm_example`.
- Add ios carthage example.

## 2024-05-03
- Add support for analyzing dependencies managed by Swift Package Manager.
- Add ios spm example.
- Add `-i` command line option.
- Update example output.

## 2024-05-01
- Improve the accuracy of CocoaPods project analysis.
- Add `-v` command line option.

## 2024-04-23
- Add support for scanning `.c`, `.cc`, `.hpp`, and `.cpp` source files.

## 2024-04-22
- Fix analysis result inaccuracies caused by incorrect usage of a path variable.

## 2024-04-21
- Add color to shell script output for improved readability.
- Remove unnecessary `-E` option from sed command.

## 2024-04-18
- Add display of total time spent on analysis.
- Enhance source file analysis efficiency through optimized grep command usage.
- Reduce time spent on comment filtering by optimizing usage of sed command.

## 2024-04-16
- Fix recursive infinite loop issue caused by symbolic links.
- Add directories for recursive testing.

## 2024-04-11
- Enhance analysis of API usage affecting app's privacy manifest.
- Add CHANGELOG.

## 2024-04-10
- Provide API usage that could affect your app's privacy manifest.
- Fix missing tag issues in some commonly used SDKs.

## 2024-04-07
- Implement comment filtering for scanning.
- Add `-c` command line option.
- Add support for scanning `.mm` source files.

## 2024-04-06
- Add requirements.
- Add flutter example.
- Add ios example.
- Fix an issue caused by space in path ([#2](https://github.com/crasowas/app_store_required_privacy_manifest_analyser/issues/2)).

## 2024-04-05
- Initial version.
- Fix newline output issue.