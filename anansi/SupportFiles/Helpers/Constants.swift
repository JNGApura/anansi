//
//  Constants.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 10/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

struct AppFontName {
    
    static let regular = "Avenir-Roman" // Cera-Regular
    static let bold = "Avenir-Heavy" // Cera-Bold
    static let italic = "Avenir-Oblique" // Cera-RegularItalic
}

struct Const {
    
    /// Large title text fontsize: 26
    static let largeTitleFontSize: CGFloat = 26
    /// Title text fontsize: 24
    static let titleFontSize: CGFloat = 24
    /// Headline text fontsize: 22
    static let headlineFontSize: CGFloat = 22
    /// Body text fontsize: 17
    static let bodyFontSize: CGFloat = 17
    /// Callout text fontsize: 16
    static let calloutFontSize: CGFloat = 16
    /// Sublabel text fontsize: 15
    static let subheadFontSize: CGFloat = 15
    /// Sublabel text fontsize: 13
    static let footnoteFontSize: CGFloat = 13
    /// Caption text fontsize: 11
    static let captionFontSize: CGFloat = 11
    
    /// Settings row height
    static let settingsRowHeight: CGFloat = 44
    /// Margin from leading/trailing anchors to content ("safe area")
    static let marginAnchorsToContent: CGFloat = 20
    /// Margin 8 pts
    static let marginEight: CGFloat = 8 // Change name, some day
    /// Explore profile picture height / width
    static let exploreImageHeight: CGFloat = 72
    /// Profile picture height / width
    static let profileImageHeight: CGFloat = 100
    /// Button height
    static let buttonHeight: CGFloat = 48
    /// UINavigation button height
    static let navButtonHeight: CGFloat = 38
    
    /// This will change
    static let timeDateHeightChatCells : CGFloat = 28.0
    
    // List of tabs in Community
    static let listTabs = ["Attendees", "Partners"]
    
    /// Color gradient mapping structure
    static let colorGradient : [Int:[UIColor]] = [0 : [.orange, .magenta],
                                                  1 : [.magenta, .cyan],
                                                  2 : [UIColor.init(red: 74/255.0, green: 144/255.0, blue: 226/255.0, alpha: 1.0), UIColor.init(red: 80/255.0, green: 227/255.0, blue: 194/255.0, alpha: 1.0)],
                                                  3 : [.orange, .yellow]]
    
    // Bagdes and progress messages for the Profile's progress
    static let badges = ["Beginner", "Intermediate", "Advanced", "Expert", "All-star", "Complete"]
    static let progressMap : [Int : String] = [0 : "👋 Welcome! Add more to your profile so other attendees can find you!",
                                               1 : "Nice! Continue adding more so other attendees can recognize you.",
                                               2 : "Good job! Continue the streak so other attendees can know you better.",
                                               3 : "Congratulations! 👏 A bit is missing to unlock your profile's full potential!",
                                               4 : "You've made it easier for others to find and recognize you. Awesome job! 👍",
                                               5 : "You're in a league of your own! 🙌 Take a moment to enjoy your accomplishment!"]
    static let progressColor : [Int : UIColor] = [0 : UIColor.init(red: 255/255.0, green: 150/255.0, blue: 20/255.0, alpha: 1.0), // orange
                                                  1 : UIColor.init(red: 239/255.0, green: 201/255.0, blue: 32/255.0, alpha: 1.0), // dark yellow
                                                  2 : UIColor.init(red: 113/255.0, green: 176/255.0, blue: 65/255.0, alpha: 1.0), // dark green
                                                  3 : UIColor.init(red: 156/255.0, green: 113/255.0, blue: 194/255.0, alpha: 1.0), // purple
                                                  4 : UIColor.init(red: 34/255.0, green: 122/255.0, blue: 186/255.0, alpha: 1.0), // dark blue
                                                  5 : .primary]
    
    // Interests database
        static let interests = ["3D Printing", "Art", "Adventure", "Animal Rights", "Artificial Intelligence", "Astrology", "Astronomy", "Backpacking", "Big Data", "Biology", "Board Games", "Business", "Community Service", "Comics", "Cooking", "Creativity", "Cryptocurrency", "Culture", "Cybersecurity", "DIY", "Data Science", "Design", "Digital Design", "Economics", "Education", "Engineering", "Electronics", "Entrepreneurship", "Equality", "Evolution", "Fashion", "Film", "Food", "Freelancing", "Gaming", "Gym", "History", "Human Rights", "Humanism", "Humor", "Industrial Design", "Innovation", "Investing", "LGBTQIA", "Leadership", "Literature", "Machine Learning", "Marketing", "Math", "Meditation", "Mobile Development", "Music", "Neuroscience", "Painting", "Peace", "Philanthropy", "Philosophy", "Photography", "Physics", "Politics", "Product Design", "Programming", "Psychology", "Public Speaking", "Reading", "Renewable Energy", "Robotics", "Running", "Sci-Fi/Fantasy", "Science", "Social Media", "Social Movements", "Space Exploration", "Spirituality", "Sports", "Startup", "Sustainability", "Technology", "Theater", "Travel", "UX/UI", "Urbanism", "Veganism", "Vegetarianism", "Volunteering", "Web Design", "Web Development", "Wellness", "Writing", "Yoga"].sorted()
    
    // Partners type colors
    static let typeColor : [String : UIColor] = ["Main" : .primary, // red
                                                 "Institutional" : UIColor.init(red: 0/255.0, green: 161/255.0, blue: 224/255.0, alpha: 1.0), // light blue
                                                 "Logistics & Operations" : .secondary, //UIColor.init(red: 156/255.0, green: 113/255.0, blue: 194/255.0, alpha: 1.0)
                                                 "Gold" : UIColor.init(red: 245/255.0, green: 220/255.0, blue: 55/255.0, alpha: 1.0), // gold
                                                 "Silver" : UIColor.init(red: 211/255.0, green: 215/255.0, blue: 222/255.0, alpha: 1.0), // silver
                                                 "Bronze" : UIColor.init(red: 137/255.0, green: 56/255.0, blue: 19/255.0, alpha: 1.0), // bronze
                                                 "Social Media & Marketing" : UIColor.init(red: 156/255.0, green: 113/255.0, blue: 194/255.0, alpha: 1.0), // purple
                                                 "Food & Beverage" : UIColor.init(red: 113/255.0, green: 176/255.0, blue: 65/255.0, alpha: 1.0)] // green
    
}
