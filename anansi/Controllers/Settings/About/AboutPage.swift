//
//  AboutPage.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 21/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

// About Page Model
struct About {
    var data = [AboutPage]()
    
    init?(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                // Gets about data from json
                if let about = json["about"] as? [[String: Any]] {
                    self.data = about.map { AboutPage(json: $0) }
                }
            }
        } catch {
            print("Error deserializing JSON: \(error)")
            return
        }
    }
}

// AboutSection initialization
struct AboutPage {
    var id: String?
    var section: [AboutPageSection]?
    
    init(json: [String : Any]) {
        self.id = json["id"] as? String
        if let section = json["section"] as? [[String: Any]] {
            self.section = section.map {AboutPageSection (json: $0)}
        }
    }
}

struct AboutPageSection {
    var title: String?
    var text: String?
    
    init(json: [String: Any]){
        self.title = json["title"] as? String
        self.text = json["text"] as? String
    }
}
