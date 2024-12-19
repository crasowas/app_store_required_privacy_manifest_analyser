# App Store Privacy Manifest Analyzer

[![Analysis Support](https://img.shields.io/badge/Analysis%20Support-CocoaPods%20%7C%20SwiftPM%20%7C%20Carthage%20%7C%20Flutter%20%7C%20App-brightgreen)](#supported-dependency-sources-for-separate-analysis)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

A shell script used to analyze privacy manifests in the specified directory to ensure that your app complies with the App Store requirements.

**If upgrading the SDK does not resolve privacy manifest issues or you wish to keep the project as is without migration, it is recommended to use the [app_privacy_manifest_fixer](https://github.com/crasowas/app_privacy_manifest_fixer) based on the current analysis script to fix privacy manifest issues.**

## Features

- Support analysis of API usage within any directory.
- Scan all source files (including `.h`, `.m`, `.mm`, `.c`, `.cc`, `.hpp`, `.cpp`, and `.swift` files) as well as binary files.
- Automatically detect missing privacy manifest files and API declarations.
- Support for tagging commonly used SDKs.
- Provide API usage that could affect your app's privacy manifest.

## Requirements

- macOS: `Xcode Command Line Tools` installed.

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
sh analyser.sh <directory_path>
```

Example output:

```text
============================ Analyzing Runner Project ============================

💡 Found privacy manifest file(s): 1
[0] ./Runner/PrivacyInfo.xcprivacy
API usage analysis result(s): 0
✅ All required API reasons have been described in the privacy manifest.

======================== Analyzing CocoaPods Dependencies ========================

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

========================= Analyzing Flutter Dependencies =========================

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

========== Analysis completed! ⏰: 229s 💡: 6 ⚠️ : 30 🛠️ : 10 ✅: 6 🎯: 10 ===========

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

- [Describing data use in privacy manifests](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests)
- [Describing use of required reason API](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api)
- [WWDC2023 - Get started with privacy manifests](https://developer.apple.com/videos/play/wwdc2023/10060)

`🎯`: **Please promptly update these commonly used SDKs highlighted by the App Store.** The complete list is from [Upcoming third-party SDK requirements](https://developer.apple.com/support/third-party-SDK-requirements).

`🔔`: For non-dynamically linked libraries, they are fully copied into the executable file of the application bundle during compilation, which may result in unknown API usage when scanning the executable file of the application.

**To pass the App Store review, you need to declare the APIs used by these non-dynamically linked libraries in your app's privacy manifest.** You might feel confused as you are not sure where exactly these APIs are being used.

To address this confusion, the analyzer will list API usage that may affect your app's privacy manifest. **Pay attention to it, as it will help you fill out the app's privacy manifest more accurately.**

### 2. Command Line Options

- `-c`: Not to filter comments when scanning source code.

```shell
sh analyser.sh -c <directory_path>
```

It is not recommended to enable this option for the accuracy of API scanning.

- `-d`: Specify the directory where local dependencies are located (e.g., Vendor, ThirdParty, etc.).

```shell
sh analyser.sh -d <dependencies_directory_path> <directory_path>
```

Local dependencies will be analyzed separately, just like dependencies from CocoaPods, SwiftPM, Carthage, and so on.

- `-e`: Specify directory to exclude from analysis.

```shell
sh analyser.sh -e <excluded_directory_path> <directory_path>
```

- `-i`: Ignore dependencies during analysis.

```shell
sh analyser.sh -i <directory_path>
```

This option is typically used for the analysis of Swift Package Manager projects. Please refer to: [ios_swiftpm_example](https://github.com/crasowas/app_store_required_privacy_manifest_analyser/tree/main/Examples/ios_swiftpm_example#notes).

- `-v`: Display verbose information.

```shell
sh analyser.sh -v <directory_path>
```

### 3. Saving Analysis Log

```shell
sh analyser.sh <directory_path> > log.txt
```

## Supported Dependency Sources for Separate Analysis

| Dependency Source     | Example                                                                                                                                  |
|-----------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| CocoaPods             | [ios_example](https://github.com/crasowas/app_store_required_privacy_manifest_analyser/tree/main/Examples/ios_example)                   |
| Swift Package Manager | [ios_swiftpm_example](https://github.com/crasowas/app_store_required_privacy_manifest_analyser/tree/main/Examples/ios_swiftpm_example)   |
| Carthage              | [ios_carthage_example](https://github.com/crasowas/app_store_required_privacy_manifest_analyser/tree/main/Examples/ios_carthage_example) |
| Flutter               | [flutter_example](https://github.com/crasowas/app_store_required_privacy_manifest_analyser/tree/main/Examples/flutter_example)           |
| Application Bundle    | Planned                                                                                                                                  |

## Privacy Access Report

**Use [the tool](https://github.com/crasowas/app_privacy_manifest_fixer) to quickly generate a privacy access report for your app.**

### Report Example

![Report Example](https://img.crasowas.dev/app_privacy_manifest_fixer/20241218230746.png)

## Commonly Used SDKs

| SDK Name                                                                                                                      | Minimum Supported Version of Privacy Manifest                                                                        |
|-------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| [Abseil](https://github.com/abseil/abseil-cpp)                                                                                | [1.20240116.1](https://github.com/abseil/abseil-cpp/releases/tag/20240116.1)                                         |
| [AFNetworking](https://github.com/AFNetworking/AFNetworking)                                                                  | `Deprecated`                                                                                                         |
| [Alamofire](https://github.com/Alamofire/Alamofire)                                                                           | [5.9.0](https://github.com/Alamofire/Alamofire/releases/tag/5.9.0)                                                   |
| [AppAuth](https://github.com/openid/AppAuth-iOS)                                                                              | [1.7.0](https://github.com/openid/AppAuth-iOS/releases/tag/1.7.0)                                                    |
| [BoringSSL / openssl_grpc](https://github.com/grpc/grpc)                                                                      | [0.0.32](https://github.com/grpc/grpc/commit/913223d0d976ff547aa7b528c29548af97044298)                               |
| [Capacitor](https://github.com/ionic-team/capacitor)                                                                          | [5.7.3](https://github.com/ionic-team/capacitor/releases/tag/5.7.3)                                                  |
| [Charts](https://github.com/danielgindi/Charts)                                                                               | [5.1.0](https://github.com/ChartsOrg/Charts/releases/tag/5.1.0)                                                      |
| [connectivity_plus](https://github.com/fluttercommunity/plus_plugins/tree/main/packages/connectivity_plus)                    | [6.0.1](https://github.com/fluttercommunity/plus_plugins/releases/tag/connectivity_plus-v6.0.1)                      |
| [Cordova](https://github.com/apache/cordova-ios)                                                                              | [7.1.0](https://cordova.apache.org/announcements/2024/04/03/cordova-ios-7.1.0.html)                                  |
| [device_info_plus](https://github.com/fluttercommunity/plus_plugins/tree/main/packages/device_info_plus)                      | [10.0.1](https://github.com/fluttercommunity/plus_plugins/releases/tag/device_info_plus-v10.0.1)                     |
| [DKImagePickerController](https://github.com/zhangao0086/DKImagePickerController)                                             | [4.3.6](https://github.com/zhangao0086/DKImagePickerController/releases/tag/4.3.6)                                   |
| [DKPhotoGallery](https://github.com/zhangao0086/DKPhotoGallery)                                                               | [0.0.18](https://github.com/zhangao0086/DKPhotoGallery/releases/tag/0.0.18)                                          |
| [FBAEMKit](https://github.com/facebook/facebook-ios-sdk/tree/main/FBAEMKit)                                                   | [17.0.0](https://github.com/facebook/facebook-ios-sdk/releases/tag/v17.0.0)                                          |
| [FBLPromises](https://github.com/google/promises)                                                                             | [2.4.0](https://github.com/google/promises/releases/tag/2.4.0)                                                       |
| [FBSDKCoreKit](https://github.com/facebook/facebook-ios-sdk/tree/main/FBSDKCoreKit)                                           | [17.0.0](https://github.com/facebook/facebook-ios-sdk/releases/tag/v17.0.0)                                          |
| [FBSDKCoreKit_Basics](https://github.com/facebook/facebook-ios-sdk/tree/main/FBSDKCoreKit_Basics)                             | [17.0.0](https://github.com/facebook/facebook-ios-sdk/releases/tag/v17.0.0)                                          |
| [FBSDKLoginKit](https://github.com/facebook/facebook-ios-sdk/tree/main/FBSDKLoginKit)                                         | [17.0.1](https://github.com/facebook/facebook-ios-sdk/releases/tag/v17.0.1)                                          |
| [FBSDKShareKit](https://github.com/facebook/facebook-ios-sdk/tree/main/FBSDKShareKit)                                         | [17.0.1](https://github.com/facebook/facebook-ios-sdk/releases/tag/v17.0.1)                                          |
| [file_picker](https://github.com/miguelpruivo/flutter_file_picker)                                                            | [8.0.0](https://github.com/miguelpruivo/flutter_file_picker/releases/tag/8.0.0)                                      |
| [FirebaseABTesting](https://github.com/firebase/firebase-ios-sdk/tree/main/FirebaseABTesting)                                 | [10.22.0](https://github.com/firebase/firebase-ios-sdk/releases/tag/10.22.0)                                         |
| [FirebaseAuth](https://github.com/firebase/firebase-ios-sdk/tree/main/FirebaseAuth)                                           | [10.22.0](https://github.com/firebase/firebase-ios-sdk/releases/tag/10.22.0)                                         |
| [FirebaseCore](https://github.com/firebase/firebase-ios-sdk/tree/main/FirebaseCore)                                           | [10.22.0](https://github.com/firebase/firebase-ios-sdk/releases/tag/10.22.0)                                         |
| [FirebaseCoreDiagnostics](https://github.com/firebase/firebase-ios-sdk/commit/43c62f0526860bd8ed4a468637448217fec99c20)       | `Deprecated`                                                                                                         |
| [FirebaseCoreExtension](https://github.com/firebase/firebase-ios-sdk/tree/main/FirebaseCore/Extension)                        | [10.22.0](https://github.com/firebase/firebase-ios-sdk/releases/tag/10.22.0)                                         |
| [FirebaseCoreInternal](https://github.com/firebase/firebase-ios-sdk/tree/main/FirebaseCore/Internal)                          | [10.22.0](https://github.com/firebase/firebase-ios-sdk/releases/tag/10.22.0)                                         |
| [FirebaseCrashlytics](https://github.com/firebase/firebase-ios-sdk/tree/main/Crashlytics)                                     | [10.22.0](https://github.com/firebase/firebase-ios-sdk/releases/tag/10.22.0)                                         |
| [FirebaseDynamicLinks](https://github.com/firebase/firebase-ios-sdk/tree/main/FirebaseDynamicLinks)                           | [10.22.0](https://github.com/firebase/firebase-ios-sdk/releases/tag/10.22.0)                                         |
| [FirebaseFirestore](https://github.com/firebase/firebase-ios-sdk/tree/main/FirebaseFirestoreInternal)                         | [10.22.0](https://github.com/firebase/firebase-ios-sdk/releases/tag/10.22.0)                                         |
| [FirebaseInstallations](https://github.com/firebase/firebase-ios-sdk/tree/main/FirebaseInstallations)                         | [10.22.0](https://github.com/firebase/firebase-ios-sdk/releases/tag/10.22.0)                                         |
| [FirebaseMessaging](https://github.com/firebase/firebase-ios-sdk/tree/main/FirebaseMessaging)                                 | [10.22.0](https://github.com/firebase/firebase-ios-sdk/releases/tag/10.22.0)                                         |
| [FirebaseRemoteConfig](https://github.com/firebase/firebase-ios-sdk/tree/main/FirebaseRemoteConfig)                           | [10.22.0](https://github.com/firebase/firebase-ios-sdk/releases/tag/10.22.0)                                         |
| [Flutter](https://github.com/flutter/flutter)                                                                                 | [3.19.0](https://github.com/flutter/engine/releases/tag/3.19.0)                                                      |
| [flutter_inappwebview](https://github.com/pichillilorenzo/flutter_inappwebview)                                               | [6.1.0](https://github.com/pichillilorenzo/flutter_inappwebview/releases/tag/v6.1.0)                                 |
| [flutter_local_notifications](https://github.com/MaikuB/flutter_local_notifications)                                          | [16.3.1+1](https://github.com/MaikuB/flutter_local_notifications/releases/tag/flutter_local_notifications-v16.3.1+1) |
| [fluttertoast](https://github.com/PonnamKarthik/FlutterToast)                                                                 | [8.2.5](https://github.com/ponnamkarthik/FlutterToast/pull/489)                                                      |
| [FMDB](https://github.com/ccgus/fmdb)                                                                                         | [2.7.9](https://github.com/ccgus/fmdb/releases/tag/2.7.9)                                                            |
| [geolocator_apple](https://github.com/baseflow/flutter-geolocator/tree/main/geolocator_apple)                                 | [2.3.7](https://github.com/Baseflow/flutter-geolocator/releases/tag/geolocator_apple_v2.3.7)                         |
| [GoogleDataTransport](https://github.com/google/GoogleDataTransport)                                                          | [9.4.0](https://github.com/google/GoogleDataTransport/releases/tag/9.4.0)                                            |
| [GoogleSignIn](https://github.com/google/GoogleSignIn-iOS)                                                                    | [7.1.0](https://github.com/google/GoogleSignIn-iOS/releases/tag/7.1.0)                                               |
| [GoogleToolboxForMac](https://github.com/google/google-toolbox-for-mac)                                                       | [4.2.0](https://github.com/google/google-toolbox-for-mac/releases/tag/v4.2.0)                                        |
| [GoogleUtilities](https://github.com/google/GoogleUtilities)                                                                  | [7.13.0](https://github.com/google/GoogleUtilities/releases/tag/7.13.0)                                              |
| [grpcpp](https://github.com/grpc/grpc-ios)                                                                                    | [1.64.0](https://github.com/grpc/grpc-ios/releases/tag/v1.64.0)                                                      |
| [GTMAppAuth](https://github.com/google/GTMAppAuth)                                                                            | [4.1.0](https://github.com/google/GTMAppAuth/releases/tag/4.1.0)                                                     |
| [GTMSessionFetcher](https://github.com/google/gtm-session-fetcher)                                                            | [3.3.0](https://github.com/google/gtm-session-fetcher/releases/tag/v3.3.0)                                           |
| [hermes](https://github.com/Imgur/Hermes)                                                                                     | `Deprecated`                                                                                                         |
| [image_picker_ios](https://github.com/flutter/packages/tree/main/packages/image_picker/image_picker_ios)                      | [0.8.9+1](https://github.com/flutter/packages/releases/tag/image_picker_ios-v0.8.9%2B1)                              |
| [IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager/tree/master/IQKeyboardManager)                          | [6.5.13](https://github.com/hackiftekhar/IQKeyboardManager/releases/tag/6.5.13)                                      |
| [IQKeyboardManagerSwift](https://github.com/hackiftekhar/IQKeyboardManager/tree/master/IQKeyboardManagerSwift)                | [6.5.13](https://github.com/hackiftekhar/IQKeyboardManager/releases/tag/6.5.13)                                      |
| [Kingfisher](https://github.com/onevcat/Kingfisher)                                                                           | [7.9.0](https://github.com/onevcat/Kingfisher/releases/tag/7.9.0)                                                    |
| [leveldb](https://github.com/google/leveldb)                                                                                  | [1.22.4](https://github.com/firebase/leveldb/releases/tag/1.22.4)                                                    |
| [Lottie](https://github.com/airbnb/lottie-ios)                                                                                | [4.4.0](https://github.com/airbnb/lottie-ios/releases/tag/4.4.0)                                                     |
| [MBProgressHUD](https://github.com/jdg/MBProgressHUD)                                                                         | [Unreleased](https://github.com/jdg/MBProgressHUD/commit/684e5b7160cce175542aee09d40c7b120cb54f07)                   |
| [nanopb](https://github.com/nanopb/nanopb)                                                                                    | [0.4.9](https://github.com/nanopb/nanopb/releases/tag/0.4.9)                                                         |
| [OneSignal](https://github.com/OneSignal/OneSignal-iOS-SDK)                                                                   | [3.12.9](https://github.com/OneSignal/OneSignal-iOS-SDK/releases/tag/3.12.9)                                         |
| [OneSignalCore](https://github.com/OneSignal/OneSignal-iOS-SDK/tree/main/iOS_SDK/OneSignalSDK/OneSignalCore)                  | [3.12.9](https://github.com/OneSignal/OneSignal-iOS-SDK/releases/tag/3.12.9)                                         |
| [OneSignalExtension](https://github.com/OneSignal/OneSignal-iOS-SDK/tree/main/iOS_SDK/OneSignalSDK/OneSignalExtension)        | [3.12.9](https://github.com/OneSignal/OneSignal-iOS-SDK/releases/tag/3.12.9)                                         |
| [OneSignalOutcomes](https://github.com/OneSignal/OneSignal-iOS-SDK/tree/main/iOS_SDK/OneSignalSDK/OneSignalOutcomes)          | [3.12.9](https://github.com/OneSignal/OneSignal-iOS-SDK/releases/tag/3.12.9)                                         |
| [OpenSSL](https://github.com/openssl/openssl)                                                                                 | [3.4.0](https://github.com/openssl/openssl/releases/tag/openssl-3.4.0)                                               |
| [OrderedSet](https://github.com/Weebly/OrderedSet)                                                                            | [6.0.2](https://github.com/Weebly/OrderedSet/releases/tag/v6.0.2)                                                    |
| [package_info](https://pub.dev/packages/package_info)                                                                         | `Deprecated`                                                                                                         |
| [package_info_plus](https://github.com/fluttercommunity/plus_plugins/tree/main/packages/package_info_plus/package_info_plus)  | [6.0.0](https://github.com/fluttercommunity/plus_plugins/releases/tag/package_info_plus-v6.0.0)                      |
| [path_provider](https://github.com/flutter/packages/tree/main/packages/path_provider/path_provider)                           | [2.1.3](https://github.com/flutter/packages/releases/tag/path_provider-v2.1.3)                                       |
| [path_provider_ios](https://pub.dev/packages/path_provider_ios)                                                               | `Deprecated`                                                                                                         |
| [Promises](https://github.com/google/promises)                                                                                | [2.4.0](https://github.com/google/promises/releases/tag/2.4.0)                                                       |
| [Protobuf](https://github.com/protocolbuffers/protobuf)                                                                       | [3.27.0](https://github.com/protocolbuffers/protobuf/releases/tag/v3.27.0)                                           |
| [Reachability](https://github.com/ashleymills/Reachability.swift)                                                             | [5.2.0](https://github.com/ashleymills/Reachability.swift/releases/tag/v5.2.0)                                       |
| [RealmSwift](https://github.com/realm/realm-swift)                                                                            | [10.48.1](https://github.com/realm/realm-swift/releases/tag/v10.48.1)                                                |
| [RxCocoa](https://github.com/ReactiveX/RxSwift/tree/main/RxCocoa)                                                             | [6.8.0](https://github.com/ReactiveX/RxSwift/releases/tag/6.8.0)                                                     |
| [RxRelay](https://github.com/ReactiveX/RxSwift/tree/main/RxRelay)                                                             | [6.8.0](https://github.com/ReactiveX/RxSwift/releases/tag/6.8.0)                                                     |
| [RxSwift](https://github.com/ReactiveX/RxSwift)                                                                               | [6.8.0](https://github.com/ReactiveX/RxSwift/releases/tag/6.8.0)                                                     |
| [SDWebImage](https://github.com/SDWebImage/SDWebImage)                                                                        | [5.18.7](https://github.com/SDWebImage/SDWebImage/releases/tag/5.18.7)                                               |
| [share_plus](https://github.com/fluttercommunity/plus_plugins/tree/main/packages/share_plus/share_plus)                       | [8.0.2](https://github.com/fluttercommunity/plus_plugins/releases/tag/share_plus-v8.0.2)                             |
| [shared_preferences_ios](https://pub.dev/packages/shared_preferences_ios)                                                     | `Deprecated`                                                                                                         |
| [SnapKit](https://github.com/SnapKit/SnapKit)                                                                                 | [5.7.0](https://github.com/SnapKit/SnapKit/releases/tag/5.7.0)                                                       |
| [sqflite](https://github.com/tekartik/sqflite)                                                                                | [2.3.1](https://github.com/tekartik/sqflite/releases/tag/v2.3.1)                                                     |
| [Starscream](https://github.com/daltoniam/Starscream)                                                                         | [4.0.7](https://github.com/daltoniam/Starscream/releases/tag/4.0.7)                                                  |
| [SVProgressHUD](https://github.com/SVProgressHUD/SVProgressHUD)                                                               | [2.3.0](https://github.com/SVProgressHUD/SVProgressHUD/releases/tag/2.3.0)                                           |
| [SwiftyGif](https://github.com/alexiscreuzot/SwiftyGif)                                                                       | [5.4.5](https://github.com/alexiscreuzot/SwiftyGif/releases/tag/5.4.5)                                               |
| [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)                                                                        | [5.0.2](https://github.com/SwiftyJSON/SwiftyJSON/releases/tag/5.0.2)                                                 |
| [Toast](https://github.com/scalessec/Toast)                                                                                   | [4.1.0](https://github.com/scalessec/Toast/releases/tag/4.1.0)                                                       |
| [UnityFramework](https://docs.unity3d.com/Manual/StructureOfXcodeProject.html)                                                | [Unity 6](https://docs.unity3d.com/6000.0/Documentation/Manual/StructureOfXcodeProject.html)                         |
| [url_launcher](https://github.com/flutter/packages/tree/main/packages/url_launcher/url_launcher)                              | [6.2.6](https://github.com/flutter/packages/releases/tag/url_launcher-v6.2.6)                                        |
| [url_launcher_ios](https://github.com/flutter/packages/tree/main/packages/url_launcher/url_launcher_ios)                      | [6.2.4](https://github.com/flutter/packages/releases/tag/url_launcher_ios-v6.2.4)                                    |
| [video_player_avfoundation](https://github.com/flutter/packages/tree/main/packages/video_player/video_player_avfoundation)    | [2.5.6](https://github.com/flutter/packages/releases/tag/video_player_avfoundation-v2.5.6)                           |
| [wakelock](https://pub.dev/packages/wakelock)                                                                                 | `Deprecated`                                                                                                         |
| [webview_flutter_wkwebview](https://github.com/flutter/packages/tree/main/packages/webview_flutter/webview_flutter_wkwebview) | [3.10.2](https://github.com/flutter/packages/releases/tag/webview_flutter_wkwebview-v3.10.2)                         |

Most deprecated SDKs have been replaced by better alternatives. **If you prefer not to migrate, consider using the [app_privacy_manifest_fixer](https://github.com/crasowas/app_privacy_manifest_fixer) to resolve privacy manifest issues.**

For the `AFNetworking` SDK, which is no longer actively maintained, you can resolve privacy manifest issues also by updating the source reference in your Podfile as shown below:

```ruby
pod 'AFNetworking', :git => 'https://github.com/crasowas/AFNetworking.git'
```

## Acknowledgements

- The scanning of required reason APIs is implemented based on [ios_17_required_reason_api_scanner](https://github.com/Wooder/ios_17_required_reason_api_scanner).
