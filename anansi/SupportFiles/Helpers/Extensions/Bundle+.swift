//
//  Bundle+.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 02/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

// Bundle extension to extract release & build versions to use in Settings View Controller
extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var releaseVersionBuildPretty: String {
        return "Version \(releaseVersionNumber ?? "1.0.0") (\(buildVersionNumber ?? "1.0.0"))"
    }
}

// NSObject extension, to get an NSObject from its classname. More information: @ github.com/damienromito/NSObject-FromClassName
// NOTE: does not handle when NSClassFromString returns nil
extension NSObject {
    class func fromClassName(name : String) -> NSObject {
        
        let className = Bundle.main.infoDictionary!["CFBundleName"] as! String + "." + name
        
        let aClass = NSClassFromString(className) as! UIViewController.Type 
        
        return aClass.init()
    }
}
