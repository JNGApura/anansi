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
    var timestamp: NSNumber?
    var sender: String?
    var receiver: String?
    var text: String?
    
    // Multimedia message
    var imageURL: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    var videoURL: String?
    
    // Tracking message
    var isRead: Bool?
    
    init(dictionary: [String: Any]) {
        super.init()
        
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.sender = dictionary["sender"] as? String
        self.receiver = dictionary["receiver"] as? String
        self.text = dictionary["text"] as? String
        
        self.imageURL = dictionary["imageURL"] as? String
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
        self.videoURL = dictionary["videoURL"] as? String
        
        self.isRead = dictionary["isRead"] as? Bool
    }
    
    func messagePartnerID() -> String? {
        return sender == NetworkManager.shared.getUID() ? receiver : sender
    }
}
