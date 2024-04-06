//
//  APICategoryFileTimestampOC.m
//  App
//
//  Created by crasowas on 2024/4/6.
//

#import <UIKit/UIKit.h>
#import "APICategoryFileTimestampOC.h"

@implementation APICategoryFileTimestampOC

// NSPrivacyAccessedAPICategoryFileTimestamp
// See also:
//   * https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278393
+ (void)fileTimestampAPIs {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // NSFileCreationDate
    // See also:
    //   * https://developer.apple.com/documentation/foundation/nsfilecreationdate?language=objc
    NSError *creationDateError;
    NSDate *creationDate = [fileManager attributesOfItemAtPath:@"" error:&creationDateError][NSFileCreationDate];
    NSLog(@"%@", creationDate);
    
    // NSFileModificationDate
    // See also:
    //   * https://developer.apple.com/documentation/foundation/nsfilemodificationdate?language=objc
    NSError *modificationDateError;
    NSDate *modificationDate = [fileManager attributesOfItemAtPath:@"" error:&modificationDateError][NSFileModificationDate];
    NSLog(@"%@", modificationDate);
    
    // NSURLContentModificationDateKey
    // See also:
    //   * https://developer.apple.com/documentation/foundation/nsurlcontentmodificationdatekey?language=objc
    NSString *contentModificationDateKey = NSURLContentModificationDateKey;
    NSLog(@"%@", contentModificationDateKey);
    
    // NSURLCreationDateKey
    // See also:
    //   * https://developer.apple.com/documentation/foundation/nsurlcreationdatekey?language=objc
    NSString *creationDateKey = NSURLCreationDateKey;
    NSLog(@"%@", creationDateKey);
}

@end
