//
//  Constants.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 10/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

enum Color {

    static let primary = UIColor.red //UIColor(red: 230/255.0, green: 43/255.0, blue: 30/255.0, alpha: 1.0)
    static let secondary = UIColor.black
    static let tertiary = UIColor(red: 235/255.0, green: 235/255.0, blue: 241/255.0, alpha: 1.0)
    static let background = UIColor.white
    
}

struct AppFontName {
    
    static let regular = "Avenir-Roman" // Cera-Regular
    static let bold = "Avenir-Heavy" // Cera-Bold
    static let italic = "Avenir-Oblique" // Cera-RegularItalic
    
}

struct Const {
    /// Large title text fontsize
    static let largeTitleFontSize: CGFloat = 26
    /// Title text fontsize
    static let titleFontSize: CGFloat = 24
    /// Headline text fontsize
    static let headlineFontSize: CGFloat = 22
    /// Body text fontsize
    static let bodyFontSize: CGFloat = 17
    /// Sublabel text fontsize
    static let calloutFontSize: CGFloat = 16
    /// Sublabel text fontsize
    static let subheadFontSize: CGFloat = 15
    /// Sublabel text fontsize
    static let footnoteFontSize: CGFloat = 13
    /// Caption text fontsize
    static let captionFontSize: CGFloat = 11
    
    /// Settings row height
    static let settingsRowHeight: CGFloat = 44
    /// Margin from leading/trailing anchors to content ("safe area")
    static let marginAnchorsToContent: CGFloat = 20
    /// Margin 8 pts
    static let marginEight: CGFloat = 8 // Change name, some day
    /// Explore profile picture height / width
    static let exploreImageHeight: CGFloat = 48
    /// Profile picture height / width
    static let profileImageHeight: CGFloat = 100
    /// Button height
    static let buttonHeight: CGFloat = 48
    /// UINavigation button height
    static let navButtonHeight: CGFloat = 38
}
