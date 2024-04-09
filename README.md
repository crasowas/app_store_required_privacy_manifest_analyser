# App Store Privacy Manifest Analyzer

## Features

* Support the analysis of API usage within directories, including Cocoa projects, Flutter projects, and application bundles (*.app)
* Enable scanning of source code files (including `.h`, `.m`, `.mm`, and `.swift` files) as well as binary files
* Support the detection of missing privacy manifest files and API declarations
* Support for tagging commonly used SDKs
* Provide API usage that could affect your app's privacy manifest

## Requirements

* macOS: `Xcode Command Line Tools` installed

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

Analyzing DKImagePickerController 🎯 ...
⚠️  Missing privacy manifest file!
API usage analysis result(s): 1
[0] NSPrivacyAccessedAPICategoryFileTimestamp:.modificationDate:./Pods/DKImagePickerController/Sources/DKImagePickerController/DKImageAssetExporter.swift
🛠️  Descriptions for the following required API reason(s) may be missing: 1
[0] NSPrivacyAccessedAPICategoryFileTimestamp

Analyzing SDWebImage 🎯 ...
💡 Found privacy manifest file(s): 1
[0] ./Pods/SDWebImage/WebImage/PrivacyInfo.xcprivacy
API usage analysis result(s): 1
[0] NSPrivacyAccessedAPICategoryFileTimestamp:NSURLContentModificationDateKey,NSURLCreationDateKey:./Pods/SDWebImage/SDWebImage/Core/SDDiskCache.m
✅ All required API reasons have been described in the privacy manifest.

Analyzing Mantle ...
⚠️  Missing privacy manifest file!
API usage analysis result(s): 0

...

==================== Analyzing Flutter Plugins Directory ====================

Analyzing device_info_plus-9.1.0 🎯 ...
⚠️  Missing privacy manifest file!
API usage analysis result(s): 0

Analyzing shared_preferences_ios-2.1.1 🎯 ...
⚠️  Missing privacy manifest file!
API usage analysis result(s): 3
[0] NSPrivacyAccessedAPICategoryUserDefaults:UserDefaults,NSUserDefaults:./.symlinks/plugins/shared_preferences_ios/ios/Classes/FLTSharedPreferencesPlugin.m
[1] NSPrivacyAccessedAPICategoryUserDefaults:UserDefaults:./.symlinks/plugins/shared_preferences_ios/ios/Classes/messages.g.h
[2] NSPrivacyAccessedAPICategoryUserDefaults:UserDefaults:./.symlinks/plugins/shared_preferences_ios/ios/Classes/messages.g.m
🛠️  Descriptions for the following required API reason(s) may be missing: 1
[0] NSPrivacyAccessedAPICategoryUserDefaults

...

==================== Analysis completed! 💡: 6 ⚠️ : 30 🛠️ : 10 ✅: 6 🎯: 10 ====================

⚠️ 🛠️  https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api
🎯 https://developer.apple.com/support/third-party-SDK-requirements

🔔 If the directory you are analyzing is the app project directory, your app's privacy manifest may be affected by these analysis results: 20
[0] NSPrivacyAccessedAPICategoryFileTimestamp:.modificationDate:./Pods/DKImagePickerController/Sources/DKImagePickerController/DKImageAssetExporter.swift
[1] NSPrivacyAccessedAPICategoryFileTimestamp:NSURLContentModificationDateKey,NSURLCreationDateKey:./Pods/SDWebImage/SDWebImage/Core/SDDiskCache.m
[2] NSPrivacyAccessedAPICategoryUserDefaults:UserDefaults,NSUserDefaults:./.symlinks/plugins/shared_preferences_ios/ios/Classes/FLTSharedPreferencesPlugin.m
[3] NSPrivacyAccessedAPICategoryUserDefaults:UserDefaults:./.symlinks/plugins/shared_preferences_ios/ios/Classes/messages.g.h
[4] NSPrivacyAccessedAPICategoryUserDefaults:UserDefaults:./.symlinks/plugins/shared_preferences_ios/ios/Classes/messages.g.m
...

```

`⚠️ 🛠`️: When the privacy manifest of third-party SDKs is missing, please update the third-party SDKs or provide feedback to the developers.

If your app's code has the same issue, please refer to the following documents or video for resolution:

* [Describing data use in privacy manifests](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests)
* [Describing use of required reason API](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api)
* [WWDC2023 - Get started with privacy manifests](https://developer.apple.com/videos/play/wwdc2023/10060)

`🎯`: **Please promptly update these commonly used SDKs highlighted by the App Store.** The complete list is from [Upcoming third-party SDK requirements](https://developer.apple.com/support/third-party-SDK-requirements).

`🔔`: For non-dynamically linked libraries, they are fully copied into the executable file of the application bundle during compilation, which may result in unknown API usage when scanning the executable file of the application.

**To pass the App Store review, you need to declare the APIs used by these non-dynamically linked libraries in your app's privacy manifest.** You might feel confused as you are not sure where exactly these APIs are being used.

To address this confusion, the analyzer will list API usage that may affect your app's privacy manifest. **Pay attention to it, as it will help you fill out the app's privacy manifest more accurately.**

### 2. Command Line Options

* `-c`: Specify not to filter comments when scanning source code

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

# Thanks

* The scanning of required reason APIs is implemented based on [ios_17_required_reason_api_scanner](https://github.com/Wooder/ios_17_required_reason_api_scanner)