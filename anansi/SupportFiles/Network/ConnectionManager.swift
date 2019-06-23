//
//  ConnectionManager.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 18/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import SystemConfiguration

class ConnectionManager: NSObject {
    
    enum ConnectivityStatus {
        case connected
        case disconnected
        case requiresConnection
    }
    
    static let shared = ConnectionManager()

    var currentConnectivityStatus: ConnectivityStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .disconnected
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .disconnected
        }
        
        if !flags.contains(.reachable) {
            // The target host is not reachable ( = disconnected).
            return .disconnected
        }
        else if flags.contains(.isWWAN) {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs ( = connected)
            return .connected
        }
        else if !flags.contains(.connectionRequired) {
            // If the target host is reachable and no connection is required then we'll assume that we're on Wi-Fi... ( = connected)
            return .connected
        }
        else if (flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)) && !flags.contains(.interventionRequired) {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed ( = connected)
            return .connected
        }
        else {
            return .disconnected
        }
    }
}
