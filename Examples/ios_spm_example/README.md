# ios_spm_example

An iOS project example used to test whether the privacy manifest analyzer is working, with dependencies managed by Swift Package Manager.

## Getting Started

1. Execute `cd <ios_spm_example>` command
2. Execute `open ./App.xcodeproj` command and wait for dependencies to be fetched
3. Execute `sh ../../privacy_manifest_analyser.sh .` command

## Notes

Since dependency resolution in Swift Package Manager projects is more complex, it results in less accuracy in analysis compared to CocoaPods projects.

If you need to analyze all packages, even those not actually depended upon by the project but remaining in cache, use the following command to ignore dependencies during analysis:

```shell
sh ../../privacy_manifest_analyser.sh -i .
```