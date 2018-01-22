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

/// WARNING: Change these constants according to your project's design
struct Const {
    /// Image height/width for Large NavBar state
    static let ImageSizeForLargeState: CGFloat = 40
    /// Margin from right anchor of safe area to right anchor of Image
    static let ImageRightMargin: CGFloat = 16
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
    static let ImageBottomMarginForLargeState: CGFloat = 12
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
    static let ImageBottomMarginForSmallState: CGFloat = 6
    /// Image height/width for Small NavBar state
    static let ImageSizeForSmallState: CGFloat = 32
    /// Height of NavBar for Small state. Usually it's just 44
    static let NavBarHeightSmallState: CGFloat = 44
    /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
    static let NavBarHeightLargeState: CGFloat = 96.5
}
