# ios_carthage_example

An iOS project example used to test whether the privacy manifest analyzer is working, with dependencies managed by Carthage.

## Getting Started

1. Execute `cd <ios_carthage_example_path>` command.
2. Execute `carthage bootstrap --platform iOS --use-xcframeworks` command.
3. Execute `sh ../../analyser.sh .` command.

### Notes

Execute the following command:

```shell
carthage bootstrap --platform iOS --use-xcframeworks
```  
 
If you encounter an error such as:

```text
xcodebuild: error: Could not configure request to show build settings: Found no destinations for the scheme 'Alamofire visionOS' and action archive.
```  

Verify your Carthage version and ensure it is [0.40.0](https://github.com/Carthage/Carthage/releases/tag/0.40.0) or later. Updating to this version or newer should resolve the issue.
