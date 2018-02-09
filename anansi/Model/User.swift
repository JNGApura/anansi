//
//  User.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 19/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class User: NSObject {
    
    // Sign-up
    var id: String?
    var email: String?
    var ticketReference: String?
    
    // Profiling/on-boarding questions
    var location: String?
    var occupation: String?
    var name: String?
    
    // From profile page
    var profileImageURL: String?
    
    init(dictionary: [String: Any], id: String) {
        
        self.id = id
        self.email = dictionary["email"] as? String
        self.ticketReference = dictionary["ticket"] as? String
        
        self.location = dictionary["location"] as? String
        self.occupation = dictionary["occupation"] as? String
        self.name = dictionary["name"] as? String
        
        self.profileImageURL = dictionary["profileImageURL"] as? String
    }
}
