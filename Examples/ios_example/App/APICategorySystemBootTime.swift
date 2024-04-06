//
//  APICategorySystemBootTime.swift
//  App
//
//  Created by crasowas on 2024/4/6.
//

import UIKit

// NSPrivacyAccessedAPICategorySystemBootTime
// See also:
//   * https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278394
func systemBootTimeAPIs() {
    
    // systemUptime
    // See also:
    //   * https://developer.apple.com/documentation/foundation/processinfo/1414553-systemuptime
    let _ = ProcessInfo.processInfo.systemUptime
    
    // mach_absolute_time()
    let _ = mach_absolute_time()
}

