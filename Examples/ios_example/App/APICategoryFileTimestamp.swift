//
//  APICategoryFileTimestamp.swift
//  App
//
//  Created by crasowas on 2024/4/6.
//

import UIKit

// NSPrivacyAccessedAPICategoryFileTimestamp
// See also:
//   * https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278393
func fileTimestampAPIs() {
    let fileManager = FileManager.default
    
    // creationDate
    // See also:
    //   * https://developer.apple.com/documentation/foundation/fileattributekey/1418187-creationdate
    let _ = try? fileManager.attributesOfItem(atPath: "")[.creationDate]
    
    // modificationDate
    // See also:
    //   * https://developer.apple.com/documentation/foundation/fileattributekey/1410058-modificationdate
    let _ = try? fileManager.attributesOfItem(atPath: "")[.modificationDate]
    
    // fileModificationDate
    // See also:
    //   * https://developer.apple.com/documentation/foundation/fileattributekey/1410058-modificationdate
    let _ = UIDocument().fileModificationDate
    
    // contentModificationDateKey
    // See also:
    //   * https://developer.apple.com/documentation/foundation/urlresourcekey/1408803-contentmodificationdatekey
    let _ = URLResourceKey.contentModificationDateKey
    
    // creationDateKey
    // See also:
    //   * https://developer.apple.com/documentation/foundation/urlresourcekey/1410073-creationdatekey
    let _ = URLResourceKey.creationDateKey
    
    // getattrlist(_: _: _: _: _:)
    getattrlist(nil, nil, nil, 0, 0)
    
    // getattrlistbulk(_: _: _: _: _:)
    getattrlistbulk(0, nil, nil, 0, 0)
    
    // fgetattrlist(_: _: _: _: _:)
    fgetattrlist(0, nil, nil, 0, 0)
    
    // stat
    // See also:
    //   * https://developer.apple.com/documentation/kernel/stat
    let _ = stat()
    
    // fstat(_: _:)
    fstat(0, nil)
    
    // fstatat(_: _: _: _:)
    fstatat(0, nil, nil, 0)
    
    // lstat(_: _:)
    lstat(nil, nil)
    
    // getattrlistat(_: _: _: _: _: _:)
    getattrlistat(0, nil, nil, nil, 0, 0)
}
