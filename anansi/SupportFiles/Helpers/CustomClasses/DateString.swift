//
//  DateString.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 15/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

// Creates time string (week, day, hour, minute) for Connect tab
func createDateIntervalString(from date: NSDate) -> String {
    
    var calendar = NSCalendar.current
    calendar.timeZone = NSTimeZone.local
    
    let components = calendar.dateComponents([.year, .weekOfYear, .day, .hour, .minute], from: date as Date, to: Date())

    if components.year! >= 1 {
        return "\(components.year!)y"
        
    } else if components.weekOfYear! >= 1 {
        return "\(components.weekOfYear!)w"
        
    } else if components.day! >= 1 {
        return components.hour! < 12 ? "\(components.day!)d" : "\(components.day! + 1)d"
        
    } else if components.hour! >= 1 {
        return "\(components.hour!)h"
        
    } else if components.minute! >= 1 {
        return "\(components.minute!)m"
        
    } else if components.minute! < 1 {
        return "Now"
    }

    return ""
}

// Create time strings for messages
func createDateIntervalStringForMessage(from date: NSDate) -> String {
    
    var calendar = NSCalendar.current
    calendar.timeZone = NSTimeZone.local
    
    let components = calendar.dateComponents([.year, .weekOfYear, .day, .hour, .minute], from: date as Date, to: Date())
    var dateIntervalString = ""
    
    if components.weekOfYear! > 1 {
        dateIntervalString += "\(components.weekOfYear!)w"
    }
    
    if components.day! > 1 {
        dateIntervalString += "\(components.day!)d"
    }
    
    if components.hour! > 1 {
        dateIntervalString += "\(components.hour!)h"
    }
    
    return dateIntervalString
}


func timestring(from date: NSDate) -> String {
    
    let formatter = DateFormatter()
    var calendar = NSCalendar.current
    calendar.timeZone = NSTimeZone.local
    
    let components = calendar.dateComponents([.year, .weekOfYear, .day, .hour], from: calendar.startOfDay(for: date as Date), to: Date())

    if components.weekOfYear! >= 1 {
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter.string(from: date as Date)
    }
    
    if components.year! >= 1 {
        formatter.dateFormat = "MMM d yyyy, HH:mm"
        return formatter.string(from: date as Date)
    }
    
    if components.day! > 1 || (components.day! == 1 && components.hour! >= 12) {
        formatter.dateFormat = "eeee HH:mm"
        
    } else if components.day! == 1 {
        return "yesterday"
        
    } else {
        formatter.dateFormat = "HH:mm"
    }
    
    return formatter.string(from: date as Date)
}

func getTimeString(from date: NSDate) -> String {
    
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.current
    formatter.dateStyle = .medium
    formatter.dateFormat = "hh:mm a"
    formatter.amSymbol = "AM"
    formatter.pmSymbol = "PM"
    
    return formatter.string(from: date as Date)
}
