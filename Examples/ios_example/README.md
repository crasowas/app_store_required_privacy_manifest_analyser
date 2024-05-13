# ios_example

An iOS project example used to test whether the privacy manifest analyzer is working, with dependencies managed by CocoaPods.

## Getting Started

1. Execute `cd <ios_example_path>` command
2. Execute `pod install` command
3. Execute `sh ../../privacy_manifest_analyser.sh .` command

To disable comment filtering, please use the following command:

```shell
sh ../../privacy_manifest_analyser.sh -c .
```

If your project has local dependencies, please use the `-d` option to specify the directory where the local dependencies are located. Dependencies in this directory will be analyzed separately.

## Notes

`NSPrivacyAccessedAPICategoryFileTimestamp` and `NSPrivacyAccessedAPICategoryDiskSpace` have some overlapping APIs:

* `getattrlist(_:_:_:_:_:)`
* `fgetattrlist(_:_:_:_:_:)`
* `getattrlistat(_:_:_:_:_:_:)`