//
//  ViewController.swift
//  App
//
//  Created by crasowas on 2024/4/6.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NSPrivacyAccessedAPICategoryFileTimestamp
        fileTimestampAPIs()
        APICategoryFileTimestampOC.fileTimestampAPIs()
        
        // NSPrivacyAccessedAPICategorySystemBootTime
        systemBootTimeAPIs()
        
        // NSPrivacyAccessedAPICategoryDiskSpace
        diskSpaceAPIs()
        APICategoryDiskSpaceOC.diskSpaceAPIs()
        
        // NSPrivacyAccessedAPICategoryActiveKeyboards
        activeKeyboardsAPIs()
        
        // NSPrivacyAccessedAPICategoryUserDefaults
        userDefaultsAPIs()
        APICategoryUserDefaultsOC.userDefaultsAPIs()
    }
}
