//
//  UILabel+.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 02/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

// UILabel extension to customize lineSpacing, lineHeightMultiple, hyphenationFactor and alignment to label text
extension UILabel {
    
    func formatTextWithLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0, hyphenation: Float = 1.0, alignment: NSTextAlignment = .natural) {
        
        guard let labelText = self.text else { return }
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.lineHeightMultiple = lineHeightMultiple
        style.hyphenationFactor = hyphenation
        style.alignment = alignment
        
        let text : NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            text = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            text = NSMutableAttributedString(string: labelText)
        }
        
        text.addAttribute(NSAttributedStringKey.paragraphStyle, value:style, range: NSMakeRange(0, text.length))
        self.attributedText = text
    }
}

