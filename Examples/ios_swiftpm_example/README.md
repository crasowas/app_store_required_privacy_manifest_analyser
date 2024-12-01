# ios_swiftpm_example

An iOS project example used to test whether the privacy manifest analyzer is working, with dependencies managed by Swift Package Manager.

## Getting Started

1. Execute `cd <ios_swiftpm_example_path>` command.
2. Execute `open ./App.xcodeproj` command and wait for dependencies to be fetched.
3. Execute `sh ../../privacy_manifest_analyser.sh .` command.

## Notes

Since dependency resolution in Swift Package Manager projects is more complex, it results in less accuracy in analysis compared to CocoaPods projects.

If there are missing dependencies or other issues in the analysis results, it is recommended to use the following command to ignore dependencies during analysis, thus analyzing all packages:

```shell
sh ../../privacy_manifest_analyser.sh -i .
```

**Some packages may not be project dependencies when analyzing all packages, but uncleared caches. Please judge based on your project's actual situation.**
