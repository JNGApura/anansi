//
//  FeedbackModel.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 14/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

struct FeedbackPage {
    
    var title: String
    var description: String
    var buttonLabelFirst: String
    var buttonLabelSecond: String
    
    init(title: String, description: String, buttonLabelFirst: String = "", buttonLabelSecond: String = "") {
        self.title = title
        self.description = description
        self.buttonLabelFirst = buttonLabelFirst
        self.buttonLabelSecond = buttonLabelSecond
    }
}
