## 1.7.0
- Enhance recognition for commonly used SDKs.
- Rename `privacy_manifest_analyser.sh` to `analyser.sh`.

## 1.6.1
- Add `-d` command line option.

## 1.6.0
- Add support for analyzing dependencies managed by Carthage.
- Rename `ios_spm_example` to `ios_swiftpm_example`.
- Add ios carthage example.

## 1.5.0
- Add support for analyzing dependencies managed by Swift Package Manager.
- Add ios spm example.
- Add `-i` command line option.
- Update example output.

## 1.4.0
- Add support for scanning `.c`, `.cc`, `.hpp`, and `.cpp` source files.
- Improve the accuracy of CocoaPods project analysis.
- Add `-v` command line option.

## 1.3.3
- Fix analysis result inaccuracies caused by incorrect usage of a path variable.

## 1.3.2
- Add color to shell script output for improved readability.
- Remove unnecessary `-E` option from sed command.

## 1.3.0
- Add display of total time spent on analysis.
- Enhance source file analysis efficiency through optimized grep command usage.
- Reduce time spent on comment filtering by optimizing usage of sed command.

## 1.2.5
- Fix recursive infinite loop issue caused by symbolic links.
- Add directories for recursive testing.

## 1.2.3
- Enhance analysis of API usage affecting app's privacy manifest.

## 1.2.2
- Provide API usage that could affect your app's privacy manifest.
- Fix missing tag issues in some commonly used SDKs.

## 1.2.0
- Implement comment filtering for scanning.
- Add `-c` command line option.
- Add support for scanning `.mm` source files.

## 1.1.0
- Add requirements.
- Add flutter example.
- Add ios example.
- Fix an issue caused by space in path ([#2](https://github.com/crasowas/app_store_required_privacy_manifest_analyser/issues/2)).

## 1.0.0
- Initial version.
- Fix newline output issue.