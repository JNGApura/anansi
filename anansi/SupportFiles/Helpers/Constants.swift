//
//  Constants.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 10/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

struct AppFontName {
    
    static let regular = "Avenir-Roman"
    static let bold = "Avenir-Heavy"
    static let italic = "Avenir-Oblique"
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
    static let marginSafeArea: CGFloat = 24
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
    /// Topbar height
    static let barHeight : CGFloat = 44.0
    
    ///
    static let timeDateHeightChatCells : CGFloat = 22.0
    
    // List of tabs in Community
    static let communityTabs = ["Trending", "Attendees", "Partners"]
    
    // List of tabs in Event
    static let eventTabs = ["Schedule", "Location"] //"xChallenge",
    
    // Formal address
    static let addressULisboa = "Aula Magna, Edifício da Reitoria, Alameda da Universidade, Lisboa"
    
    // GPS coordinates of the location of the event (informal address)
    static let addressLatitude = 38.7527769
    static let addressLongitude = -9.1579087
    
    // Kapter Promocode
    static let kaptenPromoCode = "TEDX19"
    
    // Placeholders for connect empty state (and new chat)
    static let emptystateTitle = ["Start a new conversation",
                                  "Ignite a discussion",
                                  "Spread your ideas"]//, "Be the change", "Be the change", "Share your passion"]
    
    static let emptystateSubtitle = ["Share your ideas by connecting with other attendees",
                                     "Be the change you want to see in the world",
                                     "Start meaningful discussions with other attendees"]

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
    static let interests = ["3D Printing", "Art", "Adventure", "Animal Rights", "Artificial Intelligence", "Astrology", "Astronomy", "Backpacking", "Big Data", "Biology", "Board Games", "Business", "Community Service", "Comics", "Cooking", "Creativity", "Cryptocurrency", "Culture", "Cybersecurity", "DIY", "Data Science", "Design", "Digital Design", "Economics", "Education", "Engineering", "Electronics", "Entrepreneurship", "Equality", "Evolution", "Fashion", "Film", "Food", "Freelancing", "Gaming", "Gym", "History", "Human Rights", "Humanism", "Humor", "Industrial Design", "Innovation", "Investing", "LGBTQIA", "Leadership", "Literature", "Machine Learning", "Marketing", "Math", "Meditation", "Mobile Development", "Music", "Neuroscience", "Painting", "Peace", "Philanthropy", "Philosophy", "Photography", "Physics", "Politics", "Product Design", "Programming", "Psychology", "Public Speaking", "Reading", "Renewable Energy", "Robotics", "Running", "Sci-Fi/Fantasy", "Science", "Social Media", "Social Movements", "Space Exploration", "Spirituality", "Sports", "Startup", "Sustainability", "Technology", "Theater", "Travel", "UX/UI", "Urbanism", "Veganism", "Vegetarianism", "Volunteering", "Web Design", "Web Development", "Wellness", "Writing", "Yoga"].shuffled()
    
    // Type of partners
    static let typePartners = ["Polaris", "Altair", "Vega", "Sirius", "Media", "Scientific", "Mobility", "Startup", "Food & Beverage", "Coffee-break", "Institutional"]
    static let mapPartner : [String : String] = [typePartners[0] : " / Main",
                                                 typePartners[1] : " / Gold",
                                                 typePartners[2] : " / Silver",
                                                 typePartners[3] : " / Bronze",
                                                 typePartners[4] : "",
                                                 typePartners[5] : "",
                                                 typePartners[6] : "",
                                                 typePartners[7] : "",
                                                 typePartners[8] : "",
                                                 typePartners[9] : "",
                                                 typePartners[10] : ""]
    
    // Partners type colors
    static let typeColor : [String : UIColor] = ["Polaris" : .primary, // red
                                                 "Altair"  : UIColor.init(red: 237/255.0, green: 176/255.0, blue: 70/255.0, alpha: 1.0), // gold
                                                 "Vega"    : UIColor.init(red: 189/255.0, green: 189/255.0, blue: 183/255.0, alpha: 1.0), // silver
                                                 "Sirius"  : UIColor.init(red: 173/255.0, green: 98/255.0, blue: 59/255.0, alpha: 1.0), // bronze
                                                 "Media"   : UIColor.init(red: 156/255.0, green: 113/255.0, blue: 194/255.0, alpha: 1.0), // purple
                                                 "Scientific" : UIColor.init(red: 0/255.0, green: 161/255.0, blue: 224/255.0, alpha: 1.0), // light blue
                                                 "Mobility" : .secondary, //UIColor.init(red: 156/255.0, green: 113/255.0, blue: 194/255.0, alpha: 1.0)
                                                 "Startup" : UIColor.init(red: 191/255.0, green: 219/255.0, blue: 203/255.0, alpha: 1.0), // cyan
                                                 "Food & Beverage" : UIColor.init(red: 113/255.0, green: 176/255.0, blue: 65/255.0, alpha: 1.0), // green
                                                 "Coffee-break" : UIColor.init(red: 248/255.0, green: 235/255.0, blue: 94/255.0, alpha: 1.0), // yellow
                                                 "Institutional" : UIColor.init(red: 189/255.0, green: 189/255.0, blue: 183/255.0, alpha: 1.0)] // silver
    
}
