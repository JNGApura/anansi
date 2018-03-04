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
    var id: String?
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
    var employees: [String]?

    // App color
    var gradientColor: Int?
    
    // Store dictionary - for future reference, if needed
    var dictionary: [String: Any]?
    
    init(dictionary: [String: Any], id: String) {
        
        self.id = id
        self.name = dictionary["name"] as? String
        self.field = dictionary["field"] as? String
        self.location = dictionary["location"] as? String
        self.type = dictionary["type"] as? String
        
        self.profileImageURL = dictionary["profileImageURL"] as? String
        self.about = dictionary["bio"] as? String

        self.website = dictionary["website"] as? String
        self.linkedin = dictionary["linkedin"] as? String
        
        self.employees = dictionary["employees"] as? [String]
        
        self.gradientColor = dictionary["gradientColor"] as? Int
        
        self.dictionary = dictionary
    }
}
