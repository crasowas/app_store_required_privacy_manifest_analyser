//
//  APICategoryDiskSpace.swift
//  App
//
//  Created by crasowas on 2024/4/6.
//

import UIKit

// NSPrivacyAccessedAPICategoryDiskSpace
// See also:
//   * https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278397
func diskSpaceAPIs() {
    let fileManager = FileManager.default
    
    // volumeAvailableCapacityKey
    // See also:
    //   * https://developer.apple.com/documentation/foundation/urlresourcekey/1412898-volumeavailablecapacitykey
    let _ = URLResourceKey.volumeAvailableCapacityKey
    
    // volumeAvailableCapacityForImportantUsageKey
    // See also:
    //   * https://developer.apple.com/documentation/foundation/urlresourcekey/2887126-volumeavailablecapacityforimport
    let _ = URLResourceKey.volumeAvailableCapacityForImportantUsageKey
    
    // volumeAvailableCapacityForOpportunisticUsageKey
    // See also:
    //   * https://developer.apple.com/documentation/foundation/urlresourcekey/2887125-volumeavailablecapacityforopport
    let _ = URLResourceKey.volumeAvailableCapacityForOpportunisticUsageKey
    
    // volumeTotalCapacityKey
    // See also:
    //   * https://developer.apple.com/documentation/foundation/urlresourcekey/1415933-volumetotalcapacitykey
    let _ = URLResourceKey.volumeTotalCapacityKey
    
    // systemFreeSize
    // See also:
    //   * https://developer.apple.com/documentation/foundation/fileattributekey/1410126-systemfreesize
    let _ = try? fileManager.attributesOfItem(atPath: "")[.systemFreeSize]
    
    // systemSize
    // See also:
    //   * https://developer.apple.com/documentation/foundation/fileattributekey/1415888-systemsize
    let _ = try? fileManager.attributesOfItem(atPath: "")[.systemSize]
    
    // statfs(_:_:)
    statfs(nil, nil)
    
    // statvfs(_:_:)
    statvfs(nil, nil)
    
    // fstatfs(_:_:)
    fstatfs(0, nil)
    
    // fstatvfs(_:_:)
    fstatvfs(0, nil)
    
    // getattrlist(_: _: _: _: _:)
    getattrlist(nil, nil, nil, 0, 0)
    
    // fgetattrlist(_: _: _: _: _:)
    fgetattrlist(0, nil, nil, 0, 0)
    
    // getattrlistat(_: _: _: _: _: _:)
    getattrlistat(0, nil, nil, nil, 0, 0)
}
