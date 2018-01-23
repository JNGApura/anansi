//
//  Reachability.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 18/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import Foundation
import ReachabilitySwift

/// Protocol for listenig network status change
public protocol NetworkStatusListener : class {
    func networkStatusDidChange(status: Reachability.NetworkStatus)
}

class ReachabilityManager: NSObject {
    
    // Shared instance
    static  let shared = ReachabilityManager()
    
    // Boolean to track network reachability
    var isNetworkAvailable : Bool {
        return reachabilityStatus != .notReachable
    }
    // Tracks current NetworkStatus (notReachable, reachableViaWiFi, reachableViaWWAN)
    var reachabilityStatus: Reachability.NetworkStatus = .notReachable
    
    // Reachability instance for Network status monitoring
    let reachability = Reachability()!
    
    // 6. Array of delegates which are interested to listen to network status change
    var listeners = [NetworkStatusListener]()
    
    
    // Called whenever there is a change in NetworkReachibility Status
    // — parameter notification: Notification with the Reachability instance
    @objc func reachabilityChanged(notification: Notification) {
        
        let reachability = notification.object as! Reachability
        
        switch reachability.currentReachabilityStatus {
        case .notReachable:
            debugPrint("Network became unreachable")
        case .reachableViaWiFi:
            debugPrint("Network reachable through WiFi")
        case .reachableViaWWAN:
            debugPrint("Network reachable through Cellular Data")
        }
        
        // Sending message to each of the delegates
        for listener in listeners {
            listener.networkStatusDidChange(status: reachability.currentReachabilityStatus)
        }
    }
    
    /// Starts monitoring the network availability status
    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: ReachabilityChangedNotification,
                                               object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            debugPrint("Could not start reachability notifier")
        }
    }
    
    /// Stops monitoring the network availability status
    func stopMonitoring(){
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification,
                                                  object: reachability)
    }
    
    // Adds a new listener to the listeners array
    /// - parameter delegate: a new listener
    func addListener(listener: NetworkStatusListener){
        listeners.append(listener)
    }
    
    /// Removes a listener from listeners array
    /// - parameter delegate: the listener which is to be removed
    func removeListener(listener: NetworkStatusListener){
        listeners = listeners.filter{ $0 !== listener}
    }
    
}

/*import SystemConfiguration

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
}*/
