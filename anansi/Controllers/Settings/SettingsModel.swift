//
//  SettingsModel.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 10/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import Foundation

// Settings Model
class Settings {
    var table = [TableRow]()
    
    init?(data: [String: AnyObject]?) {
        guard let body = data else {
            return
        }
        
        // Gets row data and maps into the table object
        if let table = body["table"] as? [[String: Any]] {
            self.table = table.map { TableRow(json: $0)}
        }
    }
}

// Row type initialization
class TableRow {
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
        if let url = json["url"] as? String {
            self.url = url
        }
    }
}
enum RowType {
    case normal
    case section
}
