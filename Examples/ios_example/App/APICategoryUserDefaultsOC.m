//
//  APICategoryUserDefaultsOC.m
//  App
//
//  Created by crasowas on 2024/4/6.
//

#import "APICategoryUserDefaultsOC.h"

@implementation APICategoryUserDefaultsOC

// NSPrivacyAccessedAPICategoryUserDefaults
// See also:
//   * https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278401
+ (void)userDefaultsAPIs {
    
    // UserDefaults
    // See also:
    //   * https://developer.apple.com/documentation/foundation/nsuserdefaults?language=objc
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@", userDefaults);
}

@end
