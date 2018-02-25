//
//  Partner.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 24/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class Partner: NSObject {
    
    // Basic
    var type: String?
    var name: String?
    var location: String?
    var field: String?
    
    // Partner page
    var profileImageURL: String?
    var about: String?
    
    // Contact information
    var website: String?
    var linkedin: String?
    
    // Contacts
    var personOfInterest: [User]?

    // App color
    var gradientColor: Int?
    
    // Store dictionary - for future reference, if needed
    var dictionary: [String: Any]?
    
    init(dictionary: [String: Any]) {
        
        self.name = dictionary["name"] as? String
        self.field = dictionary["field"] as? String
        self.location = dictionary["location"] as? String
        self.type = dictionary["type"] as? String
        
        self.profileImageURL = dictionary["profileImageURL"] as? String
        self.about = dictionary["bio"] as? String

        self.website = dictionary["website"] as? String
        self.linkedin = dictionary["linkedin"] as? String
        
        self.personOfInterest = dictionary["personOfInterest"] as? [User]
        
        self.gradientColor = dictionary["gradientColor"] as? Int
        
        self.dictionary = dictionary
    }
}
