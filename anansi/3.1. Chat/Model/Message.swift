//
//  Message.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 24/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class Message: NSObject {
    
    // Custom message
    var id: String
    var timestamp: NSNumber?
    var sender: String?
    var receiver: String?
    var text: String?
    
    // Tracking message
    var isSent: Bool?
    var isDelivered: Bool?
    var isRead: Bool?
    
    init(dictionary: [String: Any], messageID: String) {
        
        self.id = messageID
        
        super.init()
        
        if let timestamp = dictionary["createdAt"] as? String {
            self.timestamp = convertToTimestamp(string: timestamp) as NSNumber
        }
        
        if let sender = dictionary["sender"] as? String {
            self.sender = sender
        }
        
        if let receiver = dictionary["receiver"] as? String {
            self.receiver = receiver
        }
        
        if let text = dictionary["message"] as? String {
            self.text = text
        }
        
        self.isSent = NSString(string: dictionary["sent"] as! String).boolValue
        self.isDelivered = NSString(string: dictionary["received"] as! String).boolValue
        self.isRead = NSString(string: dictionary["read"] as! String).boolValue
    }
    
    func partnerID() -> String? {
        return sender == NetworkManager.shared.getUID() ? receiver : sender
    }
    
    func convertToTimestamp(string: String) -> TimeInterval {
        
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyyMMdd_HHmmss"
        let date = dfmatter.date(from: string)
        
        return date!.timeIntervalSince1970
    }
}
