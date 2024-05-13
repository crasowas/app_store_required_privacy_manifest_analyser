#!/bin/bash

# Copyright (c) 2024, crasowas.
#
# Use of this source code is governed by a MIT-style license
# that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.

# Keep comment during source code scanning when the `-c` option is enabled
keep_comment=false

# Analysis ignores dependencies when the `-i` option is enabled
ignore_dependencies=false

# Print verbose information when the `-v` option is enabled
verbose=false

# An array of directories for local dependencies
local_dependencies_dirs=()

# An array of directories excluded from analysis
target_excluded_dirs=()

# Parse command-line options
while getopts ":cd:e:iv" opt; do
  case $opt in
    c) keep_comment=true
    ;;
    d) local_dependencies_dirs+=("$OPTARG")
    ;;
    e) target_excluded_dirs+=("$OPTARG")
    ;;
    i) ignore_dependencies=true
    ;;
    v) verbose=true
    ;;
    \?) echo "Invalid option: -$OPTARG" >&2
        exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

# Check if a directory path parameter is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

target_dir=$1

pod_file="$target_dir/Podfile"
# Pods directory will be analyzed separately if it's a CocoaPods project
pods_dir="$target_dir/Pods"
pods_pbxproj_file="$pods_dir/Pods.xcodeproj/project.pbxproj"
# Exclude non-library directories within the Pods directory
pods_excluded_dirs=("$pods_dir/Pods.xcodeproj" "$pods_dir/Target Support Files" "$pods_dir/Local Podspecs" "$pods_dir/Headers")
# Carthage directory will be analyzed separately if it's a Carthage project
carthage_dir="$target_dir/Carthage"
# Flutter plugins directory will be analyzed separately if it's a Flutter project
flutter_plugins_dir="$target_dir/.symlinks/plugins"
# App Frameworks directory will be analyzed separately if the target directory is an application bundle
app_frameworks_dir="$target_dir/Frameworks"

# Exclude directories to be analyzed separately
target_excluded_dirs+=("$pods_dir" "$carthage_dir" "${local_dependencies_dirs[@]}" "$flutter_plugins_dir" "$app_frameworks_dir")

# Temporary file for keeping track of recursively traversed directories
visited_dirs_tempfile=$(mktemp)
trap "rm -f $visited_dirs_tempfile" EXIT

# Analysis indicators
found_count=0
warning_count=0
issue_count=0
completed_count=0
common_sdk_count=0

# Project Information
project_name=""
project_xcodeproj_file=""

# An array of dependencies information, including the name, product name, and Mach-O type
# For dependencies managed by Swift Package Manager, the paths to these dependencies are also included
dependencies=()

# An array variable for storing analysis results that affect the application's privacy manifest
app_privacy_manifest_effect_results=()

# File name of the privacy manifest
readonly PRIVACY_MANIFEST_FILE_NAME="PrivacyInfo.xcprivacy"

# Universal delimiter
readonly DELIMITER=":"

# Space escape symbol for handling space in path
readonly SPACE_ESCAPE="\u0020"

# Mach-O types
readonly MACH_O_TYPE_STATIC_LIB="staticlib"
readonly MACH_O_TYPE_DY_LIB="mh_dylib"
readonly MACH_O_TYPE_UNKNOWN="unknown"

# ANSI color codes
readonly BOLD_BLACK_COLOR="\033[1;30m"
readonly GREEN_COLOR="\033[0;32m"
readonly YELLOW_COLOR="\033[0;33m"
readonly RESET_COLOR="\033[0m"

# Text of the required reason APIs and their categories
# See also:
#   * https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api
#   * https://github.com/Wooder/ios_17_required_reason_api_scanner/blob/main/required_reason_api_text_scanner.sh
readonly API_TEXTS=(
    # NSPrivacyAccessedAPICategoryFileTimestamp
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}creationDate"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}modificationDate"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}fileModificationDate"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}contentModificationDateKey"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}creationDateKey"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}getattrlist"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}getattrlistbulk"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}fgetattrlist"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}stat"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}fstat"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}fstatat"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}lstat"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}getattrlistat"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}NSFileCreationDate"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}NSFileModificationDate"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}NSURLContentModificationDateKey"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}NSURLCreationDateKey"
    # NSPrivacyAccessedAPICategorySystemBootTime
    "NSPrivacyAccessedAPICategorySystemBootTime${DELIMITER}systemUptime"
    "NSPrivacyAccessedAPICategorySystemBootTime${DELIMITER}mach_absolute_time"
    # NSPrivacyAccessedAPICategoryDiskSpace
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}volumeAvailableCapacityKey"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}volumeAvailableCapacityForImportantUsageKey"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}volumeAvailableCapacityForOpportunisticUsageKey"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}volumeTotalCapacityKey"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}systemFreeSize"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}systemSize"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}statfs"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}statvfs"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}fstatfs"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}fstatvfs"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}getattrlist"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}fgetattrlist"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}getattrlistat"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}NSURLVolumeAvailableCapacityKey"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}NSURLVolumeAvailableCapacityForImportantUsageKey"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}NSURLVolumeAvailableCapacityForOpportunisticUsageKey"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}NSURLVolumeTotalCapacityKey"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}NSFileSystemFreeSize"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}NSFileSystemSize"
    # NSPrivacyAccessedAPICategoryActiveKeyboards
    "NSPrivacyAccessedAPICategoryActiveKeyboards${DELIMITER}activeInputModes"
    # NSPrivacyAccessedAPICategoryUserDefaults
    "NSPrivacyAccessedAPICategoryUserDefaults${DELIMITER}UserDefaults"
    "NSPrivacyAccessedAPICategoryUserDefaults${DELIMITER}NSUserDefaults"
    "NSPrivacyAccessedAPICategoryUserDefaults${DELIMITER}AppStorage"
)

# Symbol of the required reason APIs and their categories
# See also:
#   * https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api
#   * https://github.com/Wooder/ios_17_required_reason_api_scanner/blob/main/required_reason_api_binary_scanner.sh
readonly API_SYMBOLS=(
    # NSPrivacyAccessedAPICategoryFileTimestamp
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}getattrlist"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}getattrlistbulk"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}fgetattrlist"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}stat"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}fstat"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}fstatat"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}lstat"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}getattrlistat"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}NSFileCreationDate"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}NSFileModificationDate"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}NSURLContentModificationDateKey"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}NSURLCreationDateKey"
    # NSPrivacyAccessedAPICategorySystemBootTime
    "NSPrivacyAccessedAPICategorySystemBootTime${DELIMITER}systemUptime"
    "NSPrivacyAccessedAPICategorySystemBootTime${DELIMITER}mach_absolute_time"
    # NSPrivacyAccessedAPICategoryDiskSpace
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}statfs"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}statvfs"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}fstatfs"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}fstatvfs"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}NSFileSystemFreeSize"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}NSFileSystemSize"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}NSURLVolumeAvailableCapacityKey"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}NSURLVolumeAvailableCapacityForImportantUsageKey"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}NSURLVolumeAvailableCapacityForOpportunisticUsageKey"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}NSURLVolumeTotalCapacityKey"
    # NSPrivacyAccessedAPICategoryActiveKeyboards
    "NSPrivacyAccessedAPICategoryActiveKeyboards${DELIMITER}activeInputModes"
    # NSPrivacyAccessedAPICategoryUserDefaults
    "NSPrivacyAccessedAPICategoryUserDefaults${DELIMITER}NSUserDefaults"
)

# List of commonly used SDKs
# See also:
#   * https://developer.apple.com/support/third-party-SDK-requirements
readonly COMMON_SDKS=(
    "Abseil"
    "AFNetworking"
    "Alamofire"
    "AppAuth"
    "BoringSSL / openssl_grpc"
    "Capacitor"
    "Charts"
    "connectivity_plus"
    "Cordova"
    "device_info_plus"
    "DKImagePickerController"
    "DKPhotoGallery"
    "FBAEMKit"
    "FBLPromises"
    "FBSDKCoreKit"
    "FBSDKCoreKit_Basics"
    "FBSDKLoginKit"
    "FBSDKShareKit"
    "file_picker"
    "FirebaseABTesting"
    "FirebaseAuth"
    "FirebaseCore"
    "FirebaseCoreDiagnostics"
    "FirebaseCoreExtension"
    "FirebaseCoreInternal"
    "FirebaseCrashlytics"
    "FirebaseDynamicLinks"
    "FirebaseFirestore"
    "FirebaseInstallations"
    "FirebaseMessaging"
    "FirebaseRemoteConfig"
    "Flutter"
    "flutter_inappwebview"
    "flutter_local_notifications"
    "fluttertoast"
    "FMDB"
    "geolocator_apple"
    "GoogleDataTransport"
    "GoogleSignIn"
    "GoogleToolboxForMac"
    "GoogleUtilities"
    "grpcpp"
    "GTMAppAuth"
    "GTMSessionFetcher"
    "hermes"
    "image_picker_ios"
    "IQKeyboardManager"
    "IQKeyboardManagerSwift"
    "Kingfisher"
    "leveldb"
    "Lottie"
    "MBProgressHUD"
    "nanopb"
    "OneSignal"
    "OneSignalCore"
    "OneSignalExtension"
    "OneSignalOutcomes"
    "OpenSSL"
    "OrderedSet"
    "package_info"
    "package_info_plus"
    "path_provider"
    "path_provider_ios"
    "Promises"
    "Protobuf"
    "Reachability"
    "RealmSwift"
    "RxCocoa"
    "RxRelay"
    "RxSwift"
    "SDWebImage"
    "share_plus"
    "shared_preferences_ios"
    "SnapKit"
    "sqflite"
    "Starscream"
    "SVProgressHUD"
    "SwiftyGif"
    "SwiftyJSON"
    "Toast"
    "UnityFramework"
    "url_launcher"
    "url_launcher_ios"
    "video_player_avfoundation"
    "wakelock"
    "webview_flutter_wkwebview"
)

# Print a formatted title
print_title() {
    local title="$1"
    local title_length=${#title}
    local border_width=$(( (80 - title_length) / 2 ))
    local border_left=""
    
    for ((i=0; i<border_width; i++)); do
        border_left+="="
    done
    
    local border_right="$border_left"

    if ((title_length % 2 == 1)); then
        border_right+="="
    fi

    echo ""
    print_text "$border_left $BOLD_BLACK_COLOR$title$RESET_COLOR $border_right"
    echo ""
}

# Print a text with or without color
print_text() {
    local text="$1"

    if [ -t 1 ]; then
        echo "$text"
    else
        echo "$text" | sed "s/\x1B\[[0-9;]*m//g"
    fi
}

# Print the elements of an array along with their indices
print_array() {
    local -a array=("$@")
    
    for ((i=0; i<${#array[@]}; i++)); do
        print_text "[$i] $(decode_path "${array[i]}")"
    done
}

# Split a string into substrings using a specified delimiter
split_string_by_delimiter() {
    local string="$1"
    local -a substrings=()

    IFS="$DELIMITER" read -ra substrings <<< "$string"

    echo "${substrings[@]}"
}

# Encode a path string by replacing space with an escape character
encode_path() {
    echo "$1" | sed "s/ /$SPACE_ESCAPE/g";
}

# Decode a path string by replacing encoded character with space
decode_path() {
    echo "$1" | sed "s/$SPACE_ESCAPE/ /g";
}

# Filter out comments from the specified source file
filter_comment() {
    if [ "$keep_comment" == false ]; then
        sed -e "/\/\*/,/\*\//d" -e "s/\/\/.*//g" "$1"
    else
        cat "$file_path"
    fi
}

# Check if the specified file is statically linked library
is_statically_linked_lib() {
    local file_info=$(file "$1")
    
    if [[ $file_info == *"current ar archive"* ]]; then
        return 0
    else
        return 1
    fi
}

# Check if the specified file is dynamically linked library
is_dynamically_linked_lib() {
    local file_info=$(file "$1")
    
    if [[ $file_info == *"dynamically linked"* ]]; then
        return 0
    else
        return 1
    fi
}

# Check if `use_frameworks!` is specified in the Podfile
check_use_frameworks() {
    local file_path="$1"

    if grep -qE "^[^#]*\buse_frameworks!\b" "$file_path"; then
        return 0
    else
        return 1
    fi
}

# Search for the names of dependencies managed by CocoaPods
search_names_in_cocoapods() {
    local file_path="$1"
    
    awk '
        BEGIN {
            in_targets = 0
        }
        /Begin PBXProject section/,/End PBXProject section/ {
            if (/targets = \(/) {
                in_targets = 1
                next
            }
            if (in_targets && /\*.* \*\// && $3 !~ /^Pods-/) {
                print $3
                next
            }
            if (/;/) {
                in_targets = 0
            }
        }
    ' "$file_path"
}

# Search for the products of dependencies managed by CocoaPods
search_products_in_cocoapods() {
    local file_path="$1"

    awk -v delimiter="$DELIMITER" '
        BEGIN {
            in_native_target = 0
        }
        /Begin PBXNativeTarget section/,/End PBXNativeTarget section/ {
            if (/isa = PBXNativeTarget;/) {
                in_native_target = 1
                name = product_name = product_type = ""
                next
            }
            if (in_native_target && /name|productName|productType/) {
                sub(/^[[:space:]]+/, "")
                gsub(/;/, "")
                gsub(/"/, "", $3)
                if ($3 !~ /^Pods-/) {
                    if (/name/) name = $3
                    else if (/productName/) product_name = $3
                    else if (/productType/) product_type = $3
                }
                next
            }
            if (in_native_target && /};/) {
                in_native_target = 0
                if (name != "") print name delimiter product_name delimiter product_type
            }
        }
    ' "$file_path"
}

# Search for the Mach-O types of dependencies managed by CocoaPods
# Note: If the dependency is a framework, it will not be included in the search results
search_mach_o_types_in_cocoapods() {
    local file_path="$1"
    
    awk -v use_frameworks="$2" -v static_lib="$MACH_O_TYPE_STATIC_LIB" -v dy_lib="$MACH_O_TYPE_DY_LIB" -v delimiter="$DELIMITER" '
        BEGIN {
            in_configuration = 0
        }
        /Begin XCBuildConfiguration section/,/End XCBuildConfiguration section/ {
            if (/isa = XCBuildConfiguration;/) {
                in_configuration = 1
                product_name = mach_o_type = ""
                next
            }
            if (in_configuration && /PRODUCT_NAME|MACH_O_TYPE/) {
                sub(/^[[:space:]]+/, "")
                gsub(/;/, "")
                gsub(/"/, "", $3)
                if (index($3, "$") == 0) {
                    if (/PRODUCT_NAME/) product_name = $3
                    else if (/MACH_O_TYPE/) mach_o_type = $3
                }
                next
            }
            if (in_configuration && /};/) {
                in_configuration = 0
                if (product_name != "" && !processed_products[product_name]) {
                    processed_products[product_name] = 1
                    # When the `MACH_O_TYPE` property is empty, the following scenarios are considered:
                    # 1. If `use_frameworks` is specified in the `Podfile`, the dependency is identified as a dynamic library
                    # 2. If `use_frameworks` is not specified in the `Podfile`, the dependency is identified as a static library
                    if (mach_o_type == "") mach_o_type = (use_frameworks == "true") ? dy_lib : static_lib
                    print product_name delimiter mach_o_type
                }
            }
        }
    ' "$file_path"
}

# Search for dependencies managed by CocoaPods
search_dependencies_in_cocoapods() {
    local file_path="$1"
    
    local names=($(search_names_in_cocoapods "$file_path"))
    local products=($(search_products_in_cocoapods "$file_path"))
    local mach_o_types=($(search_mach_o_types_in_cocoapods "$file_path" "$2"))
    
    for dep_name in "${names[@]}"; do
        # Find the product name of the dependency
        # The default product name is the same as the dependency name
        dep_product_name="$dep_name"
        for product in "${products[@]}"; do
            product_substrings=($(split_string_by_delimiter "$product"))
            product_type=${product_substrings[2]}
            if [ "$dep_name" == "${product_substrings[0]}" ]; then
                if ! [ "$product_type" == "com.apple.product-type.bundle" ]; then
                    dep_product_name=${product_substrings[1]}
                else
                    dep_product_name=""
                fi
                break
            fi
        done
        
        # Ignore if the product type is bundle
        if [ -n "$dep_product_name" ]; then
            # Find the Mach-O type of the dependency
            dep_mach_o_type="$MACH_O_TYPE_UNKNOWN"
            for mach_o_type in "${mach_o_types[@]}"; do
                mach_o_type_substrings=($(split_string_by_delimiter "$mach_o_type"))
                if [ "$dep_product_name" == "${mach_o_type_substrings[0]}" ]; then
                    dep_mach_o_type=${mach_o_type_substrings[1]}
                    break
                fi
            done
            
            dependencies+=("$dep_name$DELIMITER$dep_product_name$DELIMITER$dep_mach_o_type")
        fi
    done
}

# Get the SourcePackages directory, which is used to store Swift Package Manager dependencies
get_source_packages_dir() {
    local derived_data_dir="$HOME/Library/Developer/Xcode/DerivedData"
    
    if ! [ -d "$derived_data_dir" ] || [ -z "$project_name" ]; then
        echo ""
        return
    fi
    
    # Find the DerivedData directory of the project. If there are multiple, by default return the latest one
    # Perhaps it would be more accurate to let the user choose?
    local project_derived_data_dir=$(find "$derived_data_dir" -maxdepth 1 -type d -name "$project_name-*" -exec stat -f "%m %N" {} + | sort -rn | head -n1 | cut -d ' ' -f2-)
    
    echo "$project_derived_data_dir/SourcePackages"
}

# Get the Embed Frameworks from the specified `project.pbxproj` file
get_embed_frameworks() {
    local file_path="$1"
    
    awk '
        BEGIN {
            in_files = 0
        }
        /Begin PBXCopyFilesBuildPhase section/,/End PBXCopyFilesBuildPhase section/ {
            if (/files = \(/) {
                in_files = 1
                next
            }
            if (in_files && /\*.* \*\//) {
                print $3
                next
            }
            if (in_files && /;/) {
                in_files = 0
            }
        }
    ' "$file_path"
}

# Search for the packages of dependencies managed by Swift Package Manager
search_packages_in_swiftpm() {
    local file_path="$1"
    
    awk -v delimiter="$DELIMITER" '
        BEGIN {
            in_dependency = 0
        }
        /Begin XCSwiftPackageProductDependency section/,/End XCSwiftPackageProductDependency section/ {
            if (/isa = XCSwiftPackageProductDependency;/) {
                in_dependency = 1
                package = product_name = ""
                next
            }
            if (in_dependency && /package|productName/) {
                sub(/^[[:space:]]+/, "")
                gsub(/;/, "")
                if (/package/) {
                    gsub(/"/, "", $6)
                    package = $6
                } else if (/productName/) {
                    gsub(/"/, "", $3)
                    product_name = $3
                }
                next
            }
            if (in_dependency && /};/) {
                in_dependency = 0
                print package delimiter product_name
            }
        }
    ' "$file_path"
}

# Search for the artifacts of dependencies managed by Swift Package Manager
search_artifacts_in_swiftpm() {
    local file_path="$1"
    
    awk -v delimiter="$DELIMITER" '
        BEGIN {
            in_artifacts = 0
            identity = targetName = path = ""
        }
        /"artifacts"/ {
            in_artifacts = 1
            next
        }
        in_artifacts && /"identity"/ {
            sub(/^[[:space:]]+/, "")
            gsub(/,/, "")
            gsub(/"/, "", $3)
            identity = $3
            next
        }
        in_artifacts && /"path"/ {
            sub(/^[[:space:]]+/, "")
            gsub(/,/, "")
            gsub(/"/, "", $3)
            path = $3
            next
        }
        in_artifacts && /"targetName"/ {
            sub(/^[[:space:]]+/, "")
            gsub(/,/, "")
            gsub(/"/, "", $3)
            targetName = $3
            print identity delimiter targetName delimiter path
            next
        }
        in_artifacts && /],/ {
            in_artifacts = 0
        }
    ' "$file_path"
}

# Search for dependencies managed by Swift Package Manager
search_dependencies_in_swiftpm() {
    local file_path="$1"
    local source_packages_dir="$2"
    local checkouts_dir="$3"
    local workspace_state_file="$source_packages_dir/workspace-state.json"
    
    if ! [ -f "$workspace_state_file" ]; then
        return
    fi
    
    local packages=($(search_packages_in_swiftpm "$file_path"))
    local embed_frameworks=($(get_embed_frameworks "$file_path"))
    local artifacts=($(search_artifacts_in_swiftpm "$workspace_state_file"))
    
    for package in "${packages[@]}"; do
        package_substrings=($(split_string_by_delimiter "$package"))
        dep_name=${package_substrings[0]}
        dep_product_name=${package_substrings[1]}
        # By default, dependencies managed by Swift Package Manager are built as static libraries
        dep_mach_o_type="$MACH_O_TYPE_STATIC_LIB"
        dep_path=""
    
        # Check if the dependency is a dynamic library
        for embed_framework in "${embed_frameworks[@]}"; do
            if [ "$dep_product_name" == "$embed_framework" ]; then
                dep_mach_o_type="$MACH_O_TYPE_DY_LIB"
                break
            fi
        done
        
        # Check if the dependency is an unknown type of library
        for artifact in "${artifacts[@]}"; do
            artifact_substrings=($(split_string_by_delimiter "$artifact"))
            
            # Prioritize matching the product name for greater accuracy in analysis
            if [ "$dep_product_name" == "${artifact_substrings[1]}" ]; then
                dep_mach_o_type="$MACH_O_TYPE_UNKNOWN"
                dep_path="${artifact_substrings[2]}"
                break
            fi
            
            if [ "$dep_name" == "${artifact_substrings[0]}" ]; then
                dep_mach_o_type="$MACH_O_TYPE_UNKNOWN"
                dep_path=$(echo ${artifact_substrings[2]} | sed "s/\(.*\/$dep_name\).*/\1/")
                break
            fi
        done
        
        if [ -z "$dep_path" ]; then
            dep_path="$checkouts_dir/$dep_name"
        fi
        
        dependencies+=("$dep_name$DELIMITER$dep_product_name$DELIMITER$dep_mach_o_type$DELIMITER$dep_path")
    done
}

get_dependency_name() {
    local dep_path="$1"
    local dir_name=$(basename "$dep_path")
    
    # Remove version name for Flutter dependencies
    local dep_name="${dir_name%-[0-9]*}"
    # Remove .app, .framework, and .xcframework suffixes
    dep_name="${dep_name%.*}"
    
    echo "$dep_name"
}

get_mach_o_type() {
    local dep_name="$1"
    
    for dependency in "${dependencies[@]}"; do
        dependency_substrings=($(split_string_by_delimiter "$dependency"))
        if [ "$dep_name" == "${dependency_substrings[0]}" ]; then
            echo "${dependency_substrings[2]}"
            return
        fi
    done
    
    echo "$MACH_O_TYPE_UNKNOWN"
}

is_excluded_dir() {
    local dir_path="$1"
    local excluded_dirs=("${@:2}")
    
    for excluded_dir in "${excluded_dirs[@]}"; do
        if [ "$dir_path" == "$excluded_dir" ]; then
            return 0
        fi
    done
    
    return 1
}

is_visited_dir() {
    local dir_path="$1"
    
    dir_path=$(readlink -f "$dir_path")
    
    if grep -qFx "$dir_path" "$visited_dirs_tempfile"; then
        return 0
    else
        echo "$dir_path" >> "$visited_dirs_tempfile"
        return 1
    fi
}

is_dependency() {
    local dep_name="$1"
    
    for dependency in "${dependencies[@]}"; do
        dependency_substrings=($(split_string_by_delimiter "$dependency"))
        if [ "$dep_name" == "${dependency_substrings[0]}" ]; then
            return 0
        fi
    done
    
    return 1
}

is_common_sdk() {
    local dep_name="$1"
    
    for common_sdk in "${COMMON_SDKS[@]}"; do
        if [ "$dep_name" == "$common_sdk" ] ; then
            return 0
        fi
    done
    
    return 1
}

# Analyze the specified source file for API texts and their categories
analyze_source_file() {
    local file_path="$1"
    local -a results=()

    for api_text in "${API_TEXTS[@]}"; do
        substrings=($(split_string_by_delimiter "$api_text"))
        category=${substrings[0]}
        api=${substrings[1]}
    
        # Check if the API text exists in the source code
        if filter_comment "$file_path" | grep -qFw "$api"; then
            index=-1
            for ((i=0; i<${#results[@]}; i++)); do
                result="${results[i]}"
                result_substrings=($(split_string_by_delimiter "$result"))
                # If the category matches an existing result, update it
                if [ "$category" == "${result_substrings[0]}" ]; then
                   index=i
                   results[i]="${result_substrings[0]}$DELIMITER${result_substrings[1]},$api$DELIMITER${result_substrings[2]}"
                   break
                fi
            done
            
            # If no matching category found, add a new result
            if [[ $index -eq -1 ]]; then
                results+=("$category$DELIMITER$api$DELIMITER$(encode_path "$file_path")")
            fi
        fi
    done
    
    echo "${results[@]}"
}

# Analyze the specified binary file for API symbols and their categories
analyze_binary_file() {
    local file_path="$1"
    local -a results=()
    
    for api_symbol in "${API_SYMBOLS[@]}"; do
        substrings=($(split_string_by_delimiter "$api_symbol"))
        category=${substrings[0]}
        api=${substrings[1]}
    
        # Check if the API symbol exists in the binary file
        if nm "$file_path" 2>/dev/null | xcrun swift-demangle | grep -E "$api$" >/dev/null; then
            index=-1
            for ((i=0; i<${#results[@]}; i++)); do
                result="${results[i]}"
                result_substrings=($(split_string_by_delimiter "$result"))
                # If the category matches an existing result, update it
                if [ "$category" == "${result_substrings[0]}" ]; then
                   index=i
                   results[i]="${result_substrings[0]}$DELIMITER${result_substrings[1]},$api$DELIMITER${result_substrings[2]}"
                   break
                fi
            done
  
            # If no matching category found, add a new result
            if [[ $index -eq -1 ]]; then
                results+=("$category$DELIMITER$api$DELIMITER$(encode_path "$file_path")")
            fi
        fi
    done
    
    echo "${results[@]}"
}

# Recursively analyzes API usage in a directory and its subdirectories
analyze_api_usage() {
    local dir_path="$1"
    local excluded_dirs=("${@:2}")
    local -a results=()
    
    # Check if the directory is excluded from analysis
    if is_excluded_dir "$dir_path" "${excluded_dirs[@]}"; then
        return
    fi
    
    # Check if the directory has been visited during analysis
    if is_visited_dir "$dir_path"; then
        return
    fi
    
    local dir_name="$(basename "$dir_path")"
    
    # If the directory is an application bundle (.app) or framework (.framework), analyze its binary file
    if [[ "$dir_name" == *.app ]]; then
        binary_name="${dir_name%.*}"
        binary_file="$dir_path/$binary_name"
        if [ -f "$binary_file" ]; then
            results+=($(analyze_binary_file "$binary_file"))
        fi
    elif [[ "$dir_name" == *.framework ]]; then
        binary_name="${dir_name%.*}"
        binary_file="$dir_path/$binary_name"
        if [ -f "$binary_file" ]; then
            results+=($(analyze_binary_file "$binary_file"))
        fi
    else
        for path in "$dir_path"/*; do
            if [ -d "$path" ]; then
                results+=($(analyze_api_usage "$path" "${excluded_dirs[@]}"))
            elif [ -f "$path" ]; then
                # Analyze source files (.swift, .h, .m, .mm, .c, .cc, .hpp, .cpp) and binary files (.a)
                case "$path" in
                    *.swift | *.h | *.m | *.mm | *.c | *.cc | *.hpp | *.cpp)
                        results+=($(analyze_source_file "$path"))
                        ;;
                    *.a)
                        results+=($(analyze_binary_file "$path"))
                        ;;
                esac
            fi
        done
    fi

    echo "${results[@]}"
}

# Search for privacy manifest files in a directory
search_privacy_manifest_files() {
    local dir_path="$1"
    local excluded_dirs=("${@:2}")
    local -a privacy_manifest_files=()

    # Create a temporary file to store search results
    local tempfile=$(mktemp)

    # Ensure the temporary file is deleted on script exit
    trap "rm -f $tempfile" EXIT

    # Find privacy manifest files within the specified directory and store the results in the temporary file
    find "$dir_path" -type f -name "$PRIVACY_MANIFEST_FILE_NAME" -print0 2>/dev/null > "$tempfile"

    # Exclude privacy manifest files within excluded directories
    while IFS= read -r -d '' file_path; do
        local skip_file=0
        for excluded_dir in "${excluded_dirs[@]}"; do
            if [[ "$file_path" == "$excluded_dir"* ]]; then
                skip_file=1
                break
            fi
        done
        if [[ $skip_file -eq 0 ]]; then
            privacy_manifest_files+=($(encode_path "$file_path"))
        fi
    done < "$tempfile"

    echo "${privacy_manifest_files[@]}"
}

get_privacy_manifest_file() {
    # If there are multiple privacy manifest files, return the one with the shortest path
    local privacy_manifest_file=$(printf "%s\n" "$@" | awk '{print length, $0}' | sort -n | head -n1 | cut -d ' ' -f2-)
    
    echo $(decode_path "$privacy_manifest_file")
}

check_privacy_manifest_file() {
    local privacy_manifest_files=("$@")
    
    if [[ ${#privacy_manifest_files[@]} -eq 0 ]]; then
        ((warning_count++))
        echo "⚠️  Missing privacy manifest file!"
    else
        ((found_count++))
        echo "💡 Found privacy manifest file(s): ${#privacy_manifest_files[@]}"
    fi
}

# Get unique categories from analysis results
get_categories() {
    local results=("$@")
    local -a categories=()
    
    for result in "${results[@]}"; do
        substrings=($(split_string_by_delimiter "$result"))
        category=${substrings[0]}
        if ! [[ "$(IFS=" "; echo "${categories[@]}")" =~ "$category" ]]; then
            categories+=("$category")
        fi
    done
    
    echo "${categories[@]}"
}

# Check if descriptions for required API reasons are missing
check_categories() {
    local privacy_manifest_file="$1"
    local categories=("${@:2}")
    local -a miss_categories=()
    
    if [ -f "$privacy_manifest_file" ]; then
        for api_category in "${categories[@]}"; do
            grep -q "$api_category" "$privacy_manifest_file"
            if [ $? -ne 0 ]; then
                miss_categories+=("$api_category")
            fi
        done
    else
        miss_categories=("${@:2}")
    fi
    
    if [[ ${#miss_categories[@]} -eq 0 ]]; then
        if [ -f "$privacy_manifest_file" ]; then
            ((completed_count++))
            echo "✅ All required API reasons have been described in the privacy manifest."
        fi
    else
        ((issue_count++))
        
        for ((i=0; i<${#miss_categories[@]}; i++)); do
            miss_categories[$i]="$YELLOW_COLOR${miss_categories[$i]}$RESET_COLOR"
        done
        
        echo "🛠️  Descriptions for the following required API reason(s) may be missing: ${#miss_categories[@]}"
        print_array "${miss_categories[@]}"
    fi
}

# Analyze the specified directory for privacy manifest file and API usage
analyze() {
    local dir_path="$1"
    local mach_o_type="$2"
    local excluded_dirs=("${@:3}")
    
    privacy_manifest_files=($(search_privacy_manifest_files "$dir_path" "${excluded_dirs[@]}"))
    check_privacy_manifest_file "${privacy_manifest_files[@]}"
    print_array "${privacy_manifest_files[@]}"
    
    results=($(analyze_api_usage "$dir_path" "${excluded_dirs[@]}"))
    echo "API usage analysis result(s): ${#results[@]}"
    print_array "${results[@]}"

    categories=($(get_categories "${results[@]}"))
    check_categories "$(get_privacy_manifest_file "${privacy_manifest_files[@]}")" "${categories[@]}"
    
    # If identified as a dynamic library, disregard the effect of the analysis results on the application's privacy manifest
    if ! [ "$mach_o_type" == "$MACH_O_TYPE_DY_LIB" ]; then
        for result in "${results[@]}"; do
            result_substrings=($(split_string_by_delimiter "$result"))
            file_path="$(decode_path "${result_substrings[2]}")"
            
            # If identified as a static library, any analysis results from non-dynamically linked libraries within it could affect the application's privacy manifest
            # For libraries of unknown type, only the analysis results of statically linked libraries are included in the list that could affect the application's privacy manifest
            if [ "$mach_o_type" == "$MACH_O_TYPE_STATIC_LIB" ] && ! is_dynamically_linked_lib "$file_path"; then
                app_privacy_manifest_effect_results+=("$result")
            elif is_statically_linked_lib "$file_path"; then
                app_privacy_manifest_effect_results+=("$result")
            fi
        done
    fi
}

# Analyze the target directory
analyze_target_dir() {
    # Check if it's a project
    project_xcodeproj_file="$(find "$target_dir" -maxdepth 1 -name "*.xcodeproj")"
    if [ -n "$project_xcodeproj_file" ]; then
        project_name="$(basename "$project_xcodeproj_file" .xcodeproj)"
        print_title "Analyzing $project_name Project"
    else
        # Check if it's an application bundle
        if [[ "$target_dir" == *.app ]]; then
            print_title "Analyzing $(basename "$target_dir" .app) App"
        else
            print_title "Analyzing Target Directory"
        fi
    fi
    
    analyze "$target_dir" "$MACH_O_TYPE_STATIC_LIB" "${target_excluded_dirs[@]}"
}

# Analyze the specified dependency
analyze_dependency() {
    local dep_path="$1"
    local dep_name="$2"
    local mach_o_type="$3"
    
    # Get the Mach-O type based on the dependency name
    if [ -z "$mach_o_type" ]; then
        mach_o_type=$(get_mach_o_type "$dep_name")
    fi
    
    # Check if the dependency is a common SDK
    if is_common_sdk "$dep_name"; then
        ((common_sdk_count++))
        print_text "Analyzing $GREEN_COLOR$dep_name$RESET_COLOR 🎯 ..."
    else
        print_text "Analyzing $GREEN_COLOR$dep_name$RESET_COLOR ..."
    fi
    
    # The dependencies with an unknown Mach-O type are typically binary dependencies
    if ! [ "$mach_o_type" == "$MACH_O_TYPE_UNKNOWN" ]; then
        echo "Mach-O Type: $mach_o_type"
    fi
    
    analyze "$dep_path" "$mach_o_type"
    echo ""
}

# Analyze the dependencies of the CocoaPods
analyze_cocoapods_dependencies() {
    if ! [ -d "$pods_dir" ]; then
        return
    fi
    
    print_title "Analyzing CocoaPods Dependencies"
    
    local use_frameworks=false
    if [ -f "$pod_file" ]; then
        if check_use_frameworks "$pod_file"; then
            use_frameworks=true
        fi
    fi
    
    if [ -f "$pods_pbxproj_file" ]; then
        dependencies=()
        search_dependencies_in_cocoapods "$pods_pbxproj_file" $use_frameworks
    fi
    
    if [ "$verbose" == true ]; then
        echo "The following are all dependencies managed by CocoaPods: ${#dependencies[@]}"
        print_array "${dependencies[@]}"
        echo ""
    fi
    
    for path in "$pods_dir"/*; do
        if [ -d "$path" ] && ! is_excluded_dir "$path" "${pods_excluded_dirs[@]}"; then
            dep_name="$(get_dependency_name "$path")"
            if [ "$ignore_dependencies" == true ] || is_dependency "$dep_name"; then
                analyze_dependency "$path" "$dep_name"
            else
                print_text "Ignore $GREEN_COLOR$dep_name$RESET_COLOR (it's not a dependency)."
                echo ""
            fi
        fi
    done
}

# Analyze the dependencies of the Swift Package Manager
analyze_swiftpm_dependencies() {
    # Check if the project is using Swift Package Manager
    local swiftpm_package_resolved_file="$project_xcodeproj_file/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
    if ! [ -f "$swiftpm_package_resolved_file" ]; then
        return
    fi
    
    print_title "Analyzing Swift Package Manager Dependencies"
    
    local project_pbxproj_file="$project_xcodeproj_file/project.pbxproj"
    local source_packages_dir="$(get_source_packages_dir)"
    local checkouts_dir="$source_packages_dir/checkouts"
    local artifacts_dir="$source_packages_dir/artifacts"
    
    if [ -f "$project_pbxproj_file" ] && [ -d "$source_packages_dir" ] && [ -d "$checkouts_dir" ]; then
        dependencies=()
        search_dependencies_in_swiftpm "$project_pbxproj_file" "$source_packages_dir" "$checkouts_dir"
    fi
    
    if [ "$verbose" == true ]; then
        echo "The location of Swift Package Manager dependencies: $source_packages_dir"
        echo "The following are all dependencies managed by Swift Package Manager: ${#dependencies[@]}"
        print_array "${dependencies[@]}"
        echo ""
    fi
    
    if [ "$ignore_dependencies" == true ]; then
        if [ -d "$checkouts_dir" ]; then
            for path in "$checkouts_dir"/*; do
                if [ -d "$path" ]; then
                    dep_name="$(get_dependency_name "$path")"
                    analyze_dependency "$path" "$dep_name" "$MACH_O_TYPE_UNKNOWN"
                fi
            done
        fi

        if [ -d "$artifacts_dir" ]; then
            for path in "$artifacts_dir"/*; do
                if [ -d "$path" ] && [ $(basename "$path") != "extract" ]; then
                    dep_name="$(get_dependency_name "$path")"
                    analyze_dependency "$path" "$dep_name" "$MACH_O_TYPE_UNKNOWN"
                fi
            done
        fi
    else
        for dependency in "${dependencies[@]}"; do
            dependency_substrings=($(split_string_by_delimiter "$dependency"))
            name="${dependency_substrings[1]}"
            mach_o_type="${dependency_substrings[2]}"
            path="${dependency_substrings[3]}"
            analyze_dependency "$path" "$name" "$mach_o_type"
        done
    fi
}

# Analyze the dependencies of the Carthage
analyze_carthage_dependencies() {
    if ! [ -d "$carthage_dir" ]; then
        return
    fi
    
    print_title "Analyzing Carthage Dependencies"
    
    local carthage_build_dir="$carthage_dir/Build"
    
    if ! [ -d "$carthage_build_dir" ]; then
        return
    fi
    
    for path in "$carthage_build_dir"/*; do
        if [ -d "$path" ]; then
            dep_name="$(get_dependency_name "$path")"
            analyze_dependency "$path" "$dep_name" "$MACH_O_TYPE_UNKNOWN"
        fi
    done
}

# Analyze the local dependencies
analyze_local_dependencies() {
    if [[ ${#local_dependencies_dirs[@]} -eq 0 ]]; then
        return
    fi
    
    for local_dependencies_dir in "${local_dependencies_dirs[@]}"; do
        if ! [ -d "$local_dependencies_dir" ]; then
            return
        fi
        
        local dir_name=$(basename "$local_dependencies_dir")
    
        print_title "Analyzing $dir_name Dependencies"
    
        for path in "$local_dependencies_dir"/*; do
            if [ -d "$path" ]; then
                dep_name="$(get_dependency_name "$path")"
                analyze_dependency "$path" "$dep_name"
            fi
        done
    done
}

# Analyze the dependencies of the Flutter
# Note: The type identification of Flutter dependencies is completed during the analysis of the CocoaPods dependencies, so execute it after the `analyze_cocoapods_dependencies` function
analyze_flutter_dependencies() {
    if ! [ -d "$flutter_plugins_dir" ]; then
        return
    fi
    
    print_title "Analyzing Flutter Dependencies"
    
    for path in "$flutter_plugins_dir"/*; do
        dep_path="$(readlink -f "$path")"
        dep_name="$(get_dependency_name "$path")"
        if [ -d "$dep_path" ]; then
            analyze_dependency "$dep_path" "$dep_name"
        fi
    done
}

# Analyze the dependencies of the Application Bundle
analyze_app_dependencies() {
    if ! [ -d "$app_frameworks_dir" ]; then
        return
    fi
    
    print_title "Analyzing Application Bundle Dependencies"
    
    for path in "$app_frameworks_dir"/*; do
        if [ -d "$path" ]; then
            dep_name="$(get_dependency_name "$path")"
            analyze_dependency "$path" "$dep_name" "$MACH_O_TYPE_DY_LIB"
        fi
    done
}

start_time=$(date +%s)

analyze_target_dir
analyze_cocoapods_dependencies
analyze_swiftpm_dependencies
analyze_carthage_dependencies
analyze_local_dependencies
analyze_flutter_dependencies
analyze_app_dependencies

end_time=$(date +%s)

print_title "Analysis completed! ⏰: $((end_time - start_time))s 💡: $found_count ⚠️ : $warning_count 🛠️ : $issue_count ✅: $completed_count 🎯: $common_sdk_count"

echo "⚠️ 🛠️  https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api"
echo "🎯 https://developer.apple.com/support/third-party-SDK-requirements"

if [[ ${#app_privacy_manifest_effect_results[@]} -gt 0 ]]; then
    echo ""
    echo "🔔 If the directory you are analyzing is the app project directory, your app's privacy manifest may be affected by these analysis results: ${#app_privacy_manifest_effect_results[@]}"
    print_array "${app_privacy_manifest_effect_results[@]}"
fi

echo ""
echo "🌟 If you found this script helpful, please consider giving it a star on GitHub. Your support is appreciated. Thank you!"
echo "🔗 Homepage: https://github.com/crasowas/app_store_required_privacy_manifest_analyser"
echo "🐛 Report issues: https://github.com/crasowas/app_store_required_privacy_manifest_analyser/issues"
echo ""
