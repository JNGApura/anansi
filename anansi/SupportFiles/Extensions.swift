//
//  Extensions.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 08/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import Foundation
import UIKit

// Bundle extension to extract release & build versions to use in Settings View Controller
extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var releaseVersionBuildPretty: String {
        return "Version \(releaseVersionNumber ?? "1.0.0") (\(buildVersionNumber ?? "1.0.0"))"
    }
}

// UIFont extension to use of custom font programatically
struct AppFontName {
    static let regular = "Avenir-Roman" // Cera-Regular
    static let bold = "Avenir-Heavy" // Cera-Bold
    static let italic = "Avenir-Oblique" // Cera-RegularItalic
}

extension UIFont {
    
    @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.regular, size: size)!
    }
    
    @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.bold, size: size)!
    }
    
    @objc class func myItalicSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.italic, size: size)!
    }
    
    @objc convenience init(myCoder aDecoder: NSCoder) {
        if let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor {
            if let fontAttribute = fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")] as? String {
                var fontName = ""
                switch fontAttribute {
                case "CTFontRegularUsage":
                    fontName = AppFontName.regular
                case "CTFontEmphasizedUsage", "CTFontBoldUsage":
                    fontName = AppFontName.bold
                case "CTFontObliqueUsage":
                    fontName = AppFontName.italic
                default:
                    fontName = AppFontName.regular
                }
                self.init(name: fontName, size: fontDescriptor.pointSize)!
            }
            else {
                self.init(myCoder: aDecoder)
            }
        }
        else {
            self.init(myCoder: aDecoder)
        }
    }
    
    // Override systemFont method by customFont
    class func overrideInitialize() {
        if self == UIFont.self {
            let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:)))
            let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:)))
            method_exchangeImplementations(systemFontMethod!, mySystemFontMethod!)
            
            let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:)))
            let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:)))
            method_exchangeImplementations(boldSystemFontMethod!, myBoldSystemFontMethod!)
            
            let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:)))
            let myItalicSystemFontMethod = class_getClassMethod(self, #selector(myItalicSystemFont(ofSize:)))
            method_exchangeImplementations(italicSystemFontMethod!, myItalicSystemFontMethod!)
            
            let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))) // Trick to get over the lack of UIFont.init(coder:))
            let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:)))
            method_exchangeImplementations(initCoderMethod!, myInitCoderMethod!)
        }
    }
}

// NSObject extension, to get an NSObject from its classname. More information: @ github.com/damienromito/NSObject-FromClassName
// NOTE: does not handle when NSClassFromString returns nil
extension NSObject {
    class func fromClassName(name : String) -> NSObject {
        let className = Bundle.main.infoDictionary!["CFBundleName"] as! String + "." + name
        let aClass = NSClassFromString(className) as! UIViewController.Type
        return aClass.init()
    }
}

// UILabel extension to customize lineSpacing, lineHeightMultiple, hyphenationFactor and alignment to label text
extension UILabel {
    
    func formatTextWithLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0, hyphenation: Float = 1.0, alignment: NSTextAlignment = .left) {
        
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
    
    /*
    func labelSizeWithString(text: String,fontSize: CGFloat, maxWidth : CGFloat,numberOfLines: Int) -> CGRect{
        
        let font = UIFont.systemFont(ofSize: fontSize)//(name: "HelveticaNeue", size: fontSize)!
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = numberOfLines
        label.font = font
        label.text = text
        
        label.sizeToFit()
        
        return label.frame
    }*/
}

// UITextView extension to customize lineSpacing, lineHeightMultiple, hyphenationFactor and alignment to HTML text
extension UITextView {
    
    func formatHTMLText(htmlText: String, lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0, hyphenation: Float = 1.0, alignment: NSTextAlignment = .left) {
        
        // style is a NSMutableParagraphStyle object
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.lineHeightMultiple = lineHeightMultiple
        style.hyphenationFactor = hyphenation
        style.alignment = alignment
        
        // att is a tentative NSMutableAttributeString which converts htmlText (string) to .utf8 (special characters) with DocumentType HTML and Encoding UTF8 (as attributes), adds black color for text
        let att = try! NSMutableAttributedString(data: htmlText.data(using: .utf8)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        att.addAttributes([NSAttributedStringKey.paragraphStyle: style,
                           NSAttributedStringKey.foregroundColor: Color.secondary], range: NSMakeRange(0, att.length))
        
        // NSMutableAttributedString is attributed to text
        self.attributedText = NSMutableAttributedString(attributedString: att)
    }
}
