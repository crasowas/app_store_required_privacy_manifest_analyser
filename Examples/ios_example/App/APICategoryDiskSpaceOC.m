//
//  APICategoryDiskSpaceOC.m
//  App
//
//  Created by crasowas on 2024/4/6.
//

#import <UIKit/UIKit.h>
#import "APICategoryDiskSpaceOC.h"

@implementation APICategoryDiskSpaceOC

// NSPrivacyAccessedAPICategoryDiskSpace
// See also:
//   * https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278397
+ (void)diskSpaceAPIs {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // NSURLVolumeAvailableCapacityKey
    // See also:
    //   * https://developer.apple.com/documentation/foundation/nsurlvolumeavailablecapacitykey?language=objc
    NSURLResourceKey volumeAvailableCapacityKey = NSURLVolumeAvailableCapacityKey;
    NSLog(@"%@", volumeAvailableCapacityKey);
    
    // NSURLVolumeAvailableCapacityForImportantUsageKey
    // See also:
    //   * https://developer.apple.com/documentation/foundation/nsurlvolumeavailablecapacityforimportantusagekey?language=objc
    NSURLResourceKey volumeAvailableCapacityForImportantUsageKey = NSURLVolumeAvailableCapacityForImportantUsageKey;
    NSLog(@"%@", volumeAvailableCapacityForImportantUsageKey);
    
    // NSURLVolumeAvailableCapacityForOpportunisticUsageKey
    // See also:
    //   * https://developer.apple.com/documentation/foundation/nsurlvolumeavailablecapacityforopportunisticusagekey?language=objc
    NSURLResourceKey volumeAvailableCapacityForOpportunisticUsageKey = NSURLVolumeAvailableCapacityForOpportunisticUsageKey;
    NSLog(@"%@", volumeAvailableCapacityForOpportunisticUsageKey);
    
    // NSURLVolumeTotalCapacityKey
    // See also:
    //   * https://developer.apple.com/documentation/foundation/nsurlvolumetotalcapacitykey?language=objc
    NSURLResourceKey volumeTotalCapacityKey = NSURLVolumeTotalCapacityKey;
    NSLog(@"%@", volumeTotalCapacityKey);
    
    // NSFileSystemFreeSize
    // See also:
    //   * https://developer.apple.com/documentation/foundation/nsfilesystemfreesize?language=objc
    NSError *systemFreeSizeError;
    NSDate *systemFreeSize = [fileManager attributesOfItemAtPath:@"" error:&systemFreeSizeError][NSFileSystemFreeSize];
    NSLog(@"%@", systemFreeSize);
    
    // NSFileSystemSize
    // See also:
    //   * https://developer.apple.com/documentation/foundation/nsfilesystemsize?language=objc
    NSError *systemSizeError;
    NSDate *systemSize = [fileManager attributesOfItemAtPath:@"" error:&systemSizeError][NSFileSystemSize];
    NSLog(@"%@", systemSize);
}

@end
