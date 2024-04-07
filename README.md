# App Store Privacy Manifest Analyzer

## Features

* Support analyzing API usage in Cocoa project, Flutter project, application bundle (*.app), etc
* Support for privacy manifest missing analysis
* Support for tagging commonly used SDKs

**Important: The scanning of required reason APIs is implemented based on [ios_17_required_reason_api_scanner](https://github.com/Wooder/ios_17_required_reason_api_scanner).**

## Requirements

* macOS: [#1](https://github.com/crasowas/app_store_required_privacy_manifest_analyser/issues/1)

You can try executing the following command to determine if your Mac device supports the script:

```shell
xcrun swift -version
```

If the output after execution resembles the example below:

```text
swift-driver version: 1.90.11.1 Apple Swift version 5.10 (swiftlang-5.10.0.13 clang-1500.3.9.4)
```

Congratulations! You are now ready to start using the script. Should you encounter any other issues, you can attempt to install `Xcode Command Line Tools` using the following command:

```shell
xcode-select --install
```

## Usage

### 1. Getting Started

```shell
sh privacy_manifest_analyser.sh <directory_path>
```

Example output:

```text
==================== Analyzing Target Directory ====================

💡 Found privacy manifest file(s): 1
[0] ./Runner/PrivacyInfo.xcprivacy
API usage analysis result(s): 0
✅ All required API reasons have been described in the privacy manifest.

==================== Analyzing Pods Directory ====================

Analyzing FBSDKCoreKit 🎯 ...
💡 Found privacy manifest file(s): 3
[0] ./Pods/FBSDKCoreKit/XCFrameworks/FBSDKCoreKit.xcframework/ios-arm64_x86_64-simulator/FBSDKCoreKit.framework/PrivacyInfo.xcprivacy
[1] ./Pods/FBSDKCoreKit/XCFrameworks/FBSDKCoreKit.xcframework/ios-arm64_x86_64-maccatalyst/FBSDKCoreKit.framework/Versions/A/Resources/PrivacyInfo.xcprivacy
[2] ./Pods/FBSDKCoreKit/XCFrameworks/FBSDKCoreKit.xcframework/ios-arm64/FBSDKCoreKit.framework/PrivacyInfo.xcprivacy
API usage analysis result(s): 3
[0] NSPrivacyAccessedAPICategoryUserDefaults:NSUserDefaults:./Pods/FBSDKCoreKit/XCFrameworks/FBSDKCoreKit.xcframework/ios-arm64/FBSDKCoreKit.framework/FBSDKCoreKit
[1] NSPrivacyAccessedAPICategoryUserDefaults:NSUserDefaults:./Pods/FBSDKCoreKit/XCFrameworks/FBSDKCoreKit.xcframework/ios-arm64_x86_64-maccatalyst/FBSDKCoreKit.framework/FBSDKCoreKit
[2] NSPrivacyAccessedAPICategoryUserDefaults:NSUserDefaults:./Pods/FBSDKCoreKit/XCFrameworks/FBSDKCoreKit.xcframework/ios-arm64_x86_64-simulator/FBSDKCoreKit.framework/FBSDKCoreKit
✅ All required API reasons have been described in the privacy manifest.

Analyzing Toast 🎯 ...
⚠️  Missing privacy manifest file!
API usage analysis result(s): 0

Analyzing Mantle ...
⚠️  Missing privacy manifest file!
API usage analysis result(s): 0

==================== Analyzing Flutter Plugins Directory ====================

Analyzing device_info_plus-9.1.0 🎯 ...
⚠️  Missing privacy manifest file!
API usage analysis result(s): 0

Analyzing permission_handler_apple-9.3.0 ...
⚠️  Missing privacy manifest file!
API usage analysis result(s): 1
[0] NSPrivacyAccessedAPICategoryUserDefaults:UserDefaults,NSUserDefaults:./.symlinks/plugins/permission_handler_apple/ios/Classes/strategies/LocationPermissionStrategy.m
🛠️  Descriptions for the following required API reason(s) may be missing: 1
[0] NSPrivacyAccessedAPICategoryUserDefaults

...

Analysis completed! 💡: 6 ⚠️ : 30 🛠️ : 10 ✅: 6 🎯: 10.
```

When the privacy manifest of third-party SDKs is missing, please update the third-party SDKs or provide feedback to the developers.

If your app's code has the same issue, please refer to the following documents or video for resolution:

* [Describing data use in privacy manifests](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests)
* [Describing use of required reason API](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api)
* [WWDC2023 - Get started with privacy manifests](https://developer.apple.com/videos/play/wwdc2023/10060)

When `🎯` appears in your analysis logs, please promptly update the commonly tagged SDKs.
For more information, please refer to: [Upcoming third-party SDK requirements](https://developer.apple.com/support/third-party-SDK-requirements).

### 2. Command Line Options

* `-c`: Specifies not to filter comments when scanning source code

```shell
sh privacy_manifest_analyser.sh -c <directory_path>
```

It is not recommended to enable this option for the accuracy of API scanning.

* `-e`: Specify directory to exclude from analysis

```shell
sh privacy_manifest_analyser.sh -e <excluded_directory_path> <directory_path>
```

### 3. Saving Analysis Logs

```shell
sh privacy_manifest_analyser.sh <directory_path> >log.txt
```

### 4. More Examples

* [ios_example](https://github.com/crasowas/app_store_required_privacy_manifest_analyser/tree/main/Examples/ios_example)
* [flutter_example](https://github.com/crasowas/app_store_required_privacy_manifest_analyser/tree/main/Examples/flutter_example)

## Notes

If static link library use required reason APIs, you need to add a description of these required reason APIs to your app's privacy manifest, even if they have their own privacy manifest. 

The reason is that the code of the static link libraries and the code of the application are merged into a single executable file during compilation. It is recommended to run the script again for analysis after archiving:

```shell
sh privacy_manifest_analyser.sh <*.app>
```