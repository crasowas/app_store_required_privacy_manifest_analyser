#!/bin/bash

# Copyright (c) 2024, crasowas.
#
# Use of this source code is governed by a MIT-style license
# that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.

# Keep comments during source code scanning when the `-c` option is enabled
keep_comments=false

# Array of directories excluded from analysis
target_excluded_dirs=()

# Parse command-line options
while getopts ":ce:" opt; do
  case $opt in
    c) keep_comments=true
    ;;
    e) target_excluded_dirs+=("$OPTARG")
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

# Pods directory will be separately analyzed if it's a Cocoa project
pods_dir="$target_dir/Pods"
# Exclude non-library directories within the Pods directory
pods_excluded_dirs=("$pods_dir/Pods.xcodeproj" "$pods_dir/Target Support Files" "$pods_dir/Local Podspecs" "$pods_dir/Headers")
# Flutter plugins directory will be separately analyzed if it's a Flutter project
flutter_plugins_dir="$target_dir/.symlinks/plugins"
# Frameworks directory will be separately analyzed if the target directory is an application bundle (*.app)
frameworks_dir="$target_dir/Frameworks"

# Exclude directories to be separately analyzed
target_excluded_dirs+=("$pods_dir" "$flutter_plugins_dir" "$frameworks_dir")

# Analysis indicators
found_count=0
warning_count=0
issue_count=0
completed_count=0
common_sdk_count=0

# Define an array variable to store analysis results that affect the application's privacy manifest
app_privacy_manifest_effect_results=()

readonly PRIVACY_MANIFEST_FILE_NAME="PrivacyInfo.xcprivacy"

# Define the delimiter used to splice APIs and their categories
readonly DELIMITER=":"

# Define the space escape symbol to handle the issue of space within path
readonly SPACE_ESCAPE="\u0020"

# Text of the required reason APIs and their categories
# See also:
#   * https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api
#   * https://github.com/Wooder/ios_17_required_reason_api_scanner/blob/main/required_reason_api_text_scanner.sh
readonly API_TEXTS=(
    # NSPrivacyAccessedAPICategoryFileTimestamp
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}.creationDate"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}.modificationDate"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}.fileModificationDate"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}.contentModificationDateKey"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}.creationDateKey"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}getattrlist("
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}getattrlistbulk("
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}fgetattrlist("
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}stat.st_"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}fstat("
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}fstatat("
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}lstat("
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}getattrlistat("
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}NSFileCreationDate"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}NSFileModificationDate"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}NSURLContentModificationDateKey"
    "NSPrivacyAccessedAPICategoryFileTimestamp${DELIMITER}NSURLCreationDateKey"
    # NSPrivacyAccessedAPICategorySystemBootTime
    "NSPrivacyAccessedAPICategorySystemBootTime${DELIMITER}systemUptime"
    "NSPrivacyAccessedAPICategorySystemBootTime${DELIMITER}mach_absolute_time()"
    # NSPrivacyAccessedAPICategoryDiskSpace
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}volumeAvailableCapacityKey"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}volumeAvailableCapacityForImportantUsageKey"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}volumeAvailableCapacityForOpportunisticUsageKey"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}volumeTotalCapacityKey"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}systemFreeSize"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}systemSize"
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}statfs("
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}statvfs("
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}fstatfs("
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}fstatvfs("
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}getattrlist("
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}fgetattrlist("
    "NSPrivacyAccessedAPICategoryDiskSpace${DELIMITER}getattrlistat("
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
    local border="===================="

    echo ""
    echo "${border} $title ${border}"
    echo ""
}

# Print the elements of an array along with their indices
print_array() {
    local -a array=("$@")
    
    for ((i=0; i<${#array[@]}; i++)); do
        echo "[$i] $(path_decode "${array[i]}")"
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
path_encode() {
    echo "$1" | sed "s/ /$SPACE_ESCAPE/g";
}

# Decode a path string by replacing encoded character with space
path_decode() {
    echo "$1" | sed "s/$SPACE_ESCAPE/ /g";
}

# Function to filter comments from a source code file
filter_comments() {
    if [ "$keep_comments" == false ]; then
        sed '/\/\*/,/\*\//d' "$1" | sed 's/\/\/.*//g'
    else
        cat "$file_path"
    fi
}

# Function to check if a file is a dynamically linked library
is_dynamically_linked_lib() {
    local file_info=$(file "$1")
    
    if [[ $file_info == *"dynamically linked"* ]]; then
        return 0
    else
        return 1
    fi
}

is_excluded_dir() {
    local dir_name="$1"
    local excluded_dirs=("${@:2}")
    
    for excluded_dir in "${excluded_dirs[@]}"; do
        if [ "$dir_name" == "$excluded_dir" ]; then
            return 0
        fi
    done
    
    return 1
}

is_common_sdk() {
    local lib_name="$1"
    
    for common_sdk in "${COMMON_SDKS[@]}"; do
        if [[ "$common_sdk" == "$lib_name" ]] ; then
            return 0
        fi
    done
    
    return 1
}

# Analyze a source code file for API texts and their categories
analyze_source_code_file() {
    local file_path="$1"
    local -a results=()

    for api_text in "${API_TEXTS[@]}"; do
        substrings=($(split_string_by_delimiter "$api_text"))
        category=${substrings[0]}
        api=${substrings[1]}
    
        # Search for lines containing the API text in the source code file
        lines=$(filter_comments "$file_path" | grep -n "$api" | cut -d ":" -f 1)
        if [ -n "$lines" ]; then
            index=-1
            for ((i=0; i<${#results[@]}; i++)); do
                result="${results[i]}"
                result_substrings=($(split_string_by_delimiter "$result"))
                # If the category matches an existing result, update it
                if [[ "${result_substrings[0]}" == "$category" ]]; then
                   index=i
                   results[i]="${result_substrings[0]}$DELIMITER${result_substrings[1]},$api$DELIMITER${result_substrings[2]}"
                   break
                fi
            done
            
            # If no matching category found, add a new result
            if [[ $index -eq -1 ]]; then
                results+=("$category$DELIMITER$api$DELIMITER$(path_encode "$file_path")")
            fi
        fi
    done
    
    echo "${results[@]}"
}

# Analyze a binary file for API symbols and their categories
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
                if [[ "${result_substrings[0]}" == "$category" ]]; then
                   index=i
                   results[i]="${result_substrings[0]}$DELIMITER${result_substrings[1]},$api$DELIMITER${result_substrings[2]}"
                   break
                fi
            done
  
            # If no matching category found, add a new result
            if [[ $index -eq -1 ]]; then
                results+=("$category$DELIMITER$api$DELIMITER$(path_encode "$file_path")")
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
    
    local dir_name="$(basename "$dir_path")"
    
    # If the directory is an application bundle (*.app) or framework (*.framework), analyze its binary file
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
                # Analyze source code files (*.swift, *.h, *.m, *.mm) and binary files (*.a)
                if [[ "$path" == *.swift ]] || [[ "$path" == *.h ]] || [[ "$path" == *.m ]] || [[ "$path" == *.mm ]]; then
                    results+=($(analyze_source_code_file "$path"))
                elif [[ "$path" == *.a ]]; then
                    results+=($(analyze_binary_file "$path"))
                fi
            fi
        done
    fi

    echo "${results[@]}"
}

# Function to search for privacy manifest files within a directory
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
        if [ $skip_file -eq 0 ]; then
            privacy_manifest_files+=($(path_encode "$file_path"))
        fi
    done < "$tempfile"

    echo "${privacy_manifest_files[@]}"
}

get_privacy_manifest_file() {
    # If there are multiple privacy manifest files, return the one with the shortest path
    local privacy_manifest_file=$(printf "%s\n" "$@" | awk '{print length, $0}' | sort -n | head -n1 | cut -d ' ' -f2-)
    
    echo $(path_decode "$privacy_manifest_file")
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

# Function to get categories from analysis results
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
        echo "🛠️  Descriptions for the following required API reason(s) may be missing: ${#miss_categories[@]}"
        print_array "${miss_categories[@]}"
    fi
}

# Function to analyze directory for privacy manifest file and API usage
analyze() {
    local dir_path="$1"
    local excluded_dirs=("${@:2}")
    
    privacy_manifest_files=($(search_privacy_manifest_files "$dir_path" "${excluded_dirs[@]}"))
    check_privacy_manifest_file "${privacy_manifest_files[@]}"
    print_array "${privacy_manifest_files[@]}"
    
    results=($(analyze_api_usage "$dir_path" "${excluded_dirs[@]}"))
    echo "API usage analysis result(s): ${#results[@]}"
    print_array "${results[@]}"
    
    # Save affects the analysis results of the application's privacy manifest
    for result in "${results[@]}"; do
        result_substrings=($(split_string_by_delimiter "$result"))
        if ! is_dynamically_linked_lib "$(path_decode "${result_substrings[2]}")"; then
            app_privacy_manifest_effect_results+=("$result")
        fi
    done
    
    categories=($(get_categories "${results[@]}"))
    check_categories "$(get_privacy_manifest_file "${privacy_manifest_files[@]}")" "${categories[@]}"
}

# Function to analyze the target directory
analyze_target_dir() {
    print_title "Analyzing Target Directory"
    
    analyze "$target_dir" "${target_excluded_dirs[@]}"
}

# Function to analyze a library directory
analyze_lib_dir() {
    local lib_path="$1"
    local dir_name=$(basename "$lib_path")
    
    # Remove version name for Flutter plugin libraries
    local lib_name="${dir_name%-[0-9].[0-9].[0-9]*}"
    # Remove .app and .framework suffixes
    lib_name="${lib_name%.*}"
    
    # Check if the library is a common SDK
    if is_common_sdk "$lib_name"; then
        ((common_sdk_count++))
        echo "Analyzing $dir_name 🎯 ..."
    else
        echo "Analyzing $dir_name ..."
    fi
    
    analyze "$path"
    echo ""
}

# Function to analyze the Pods directory
analyze_pods_dir() {
    if ! [ -d "$pods_dir" ]; then
        return
    fi
    
    print_title "Analyzing Pods Directory"
    
    for path in "$pods_dir"/*; do
        if [ -d "$path" ] && ! is_excluded_dir "$path" "${pods_excluded_dirs[@]}"; then
            analyze_lib_dir "$path"
        fi
    done
}

# Function to analyze the Flutter plugins directory
analyze_flutter_plugins_dir() {
    if ! [ -d "$flutter_plugins_dir" ]; then
        return
    fi
    
    print_title "Analyzing Flutter Plugins Directory"
    
    for path in "$flutter_plugins_dir"/*; do
        lib_path="$(readlink -f "$path")"
        if [ -d "$lib_path" ] ; then
            analyze_lib_dir "$lib_path"
        fi
    done
}

# Function to analyze the Frameworks directory
analyze_frameworks_dir() {
    if ! [ -d "$frameworks_dir" ]; then
        return
    fi
    
    print_title "Analyzing Frameworks Directory"
    
    for path in "$frameworks_dir"/*; do
        if [ -d "$path" ] ; then
            analyze_lib_dir "$path"
        fi
    done
}

analyze_target_dir
analyze_pods_dir
analyze_flutter_plugins_dir
analyze_frameworks_dir

print_title "Analysis completed! 💡: $found_count ⚠️ : $warning_count 🛠️ : $issue_count ✅: $completed_count 🎯: $common_sdk_count"

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
echo ""
