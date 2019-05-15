//
//  CustomClasses.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 15/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

// To iterate enums (for partner and user models)
func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}

// Creates time string (week) for Connect tab
func createWeektimeString(date: NSDate) -> String {
    
    var calendar = NSCalendar.current
    calendar.timeZone = NSTimeZone.local
    
    let components = calendar.dateComponents([.weekOfYear, .day, .hour, .minute], from: date as Date, to: Date())

    if components.weekOfYear! >= 1 {
        return "\(components.weekOfYear!)w"
        
    } else if components.weekOfYear! < 1 && components.day! >= 1 {
        return "\(components.day!)d"
        
    } else if components.day! < 1 && components.hour! >= 1 {
        return "\(components.hour!)h"
        
    } else if components.hour! < 1 && components.minute! >= 1 {
        return "\(components.minute!)m"
    }

    return ""
}

// Create time strings for messages
func createTimeString(date: NSDate) -> String {
    
    let formatter = DateFormatter()
    var calendar = NSCalendar.current
    calendar.timeZone = NSTimeZone.local
    
    let components = calendar.dateComponents([.month, .day], from: calendar.startOfDay(for: date as Date), to: Date())
    
    if components.day! == 1 {
        return "yesterday"
        
    } else if components.day! < 1 {
        formatter.dateFormat = "HH:mm"
        
    } else if components.day! > 1 && components.month! < 1 {
        formatter.dateFormat = "EEE, HH:mm"
        
    } else if components.month! >= 1 {
        formatter.dateFormat = "dd/MMM/yy"
    }
    
    return formatter.string(from: date as Date)
}

func createTimeString(dateA: Date, dateB: Date) -> String {
    
    let formatter = DateFormatter()
    var calendar = NSCalendar.current
    calendar.timeZone = NSTimeZone.local
    
    //let dateMessageB = calendar.dateComponents([.month, .day, .hour], from: dateFromMessageB, to: now)
    let AtoB = calendar.dateComponents([.day], from: dateA, to: dateB)
    let AtoNow = calendar.dateComponents([.day], from: calendar.startOfDay(for: dateA), to: Date())
    let BtoNow = calendar.dateComponents([.day], from: calendar.startOfDay(for: dateB), to: Date())
    
    if AtoB.day! >= 1 {
        
        if AtoNow.day! > 7 {
            formatter.dateFormat = "dd/MMM/yy, HH:mm"
            
        } else if BtoNow.day! == 1 {
            formatter.dateFormat = "'yesterday', HH:mm"
            
        } else {
            formatter.dateFormat = "EEE, HH:mm"
        }
        
    } else if AtoB.day! < 1 {
        
        if BtoNow.day! < 1 && AtoNow.day! >= 1{
            formatter.dateFormat = "'today', HH:mm"
            
        } else {
            formatter.dateFormat = ""
        }
    }

    return formatter.string(from: dateB as Date)
    
    /*
    if BtoA.month! < 0 {
        formatter.dateFormat = "dd/MMM/yy, HH:mm"
        
    } else if BtoA.day! <= 0 {
        
        if BtoNow.day! > 1 { //dateMessageB.day! >= 1 &&
            formatter.dateFormat = "E, HH:mm"
            
        } else if BtoNow.day! == 1 { //dateMessageB.day! <= 1 &&
            formatter.dateFormat = "'yesterday', HH:mm"
            
        } else if BtoNow.day! < 1 { //dateMessageB.day! < 1 {
            formatter.dateFormat = "'today', HH:mm"
        }
        
    } else {
        formatter.dateFormat = ""
    }
    
    return formatter.string(from: dateB as Date)*/
}
