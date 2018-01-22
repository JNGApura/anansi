//
//  SettingsModel.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 10/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import Foundation

// Settings Model
struct Settings {
    var structure = [SettingsRow]()
    
    init?(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                // Gets table data from json
                if let structure = json["structure"] as? [[String: Any]] {
                    self.structure = structure.map { SettingsRow(json: $0) }
                }
            }
        } catch {
            print("Error deserializing JSON: \(error)")
            return
        }
    }
}

// TableRow initialization
struct SettingsRow {
    var ofType: RowType
    var value: String?
    var iconUrl: String?
    var action: String?
    var url: String?
    
    init(json: [String: Any]) {
        self.ofType = (json["ofType"] as? String == "normal") ? .normal : .section
        self.value = json["value"] as? String
        self.iconUrl = json["iconUrl"] as? String
        self.action = json["action"] as? String
        if let url = json["url"] as? String { // to be safe
            self.url = url
        }
    }
}
enum RowType {
    case normal
    case section
}
