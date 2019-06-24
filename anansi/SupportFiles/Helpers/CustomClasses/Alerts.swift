//
//  Alerts.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 17/06/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

func emailVerificationAlertFor(controller: UIViewController, handler: (() -> Void)?) {
    
    let alert = UIAlertController(title: "Are you, you?", message: "Yap, we need to confirm you're you, so we've send you an email to \(String(describing: userDefaults.string(for: userInfoType.email.rawValue))) 📩 Please make sure you verify your account whenever possible.", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: { (action) in
        handler?()
    }))
    
    controller.present(alert, animated: true, completion: nil)
}

func emailVerificationErrorAlertFor(controller: UIViewController, handler: (() -> Void)?) {
    
    let alert = UIAlertController(title: "We still don't know if you're you!", message: "We sent you another verification email to \(String(describing: userDefaults.string(for: userInfoType.email.rawValue))). Please verify your account within 1 bussiness day, otherwise your account will be put on hold 🚫", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Upss, doing it now! 😅", style: .default, handler: { (action) in
        handler?()
    }))
    
    controller.present(alert, animated: true, completion: nil)
}

func showConnectionAlertFor(controller: UIViewController) {
    
    // Haptic feedback
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
    
    let alert = UIAlertController(title: "No internet connection 😳", message: "We'll keep trying to reconnect. Meanwhile, could you check your data or wifi connection?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "On it!", style: .default , handler: nil))
    
    controller.present(alert, animated: true, completion: nil)
}


func showKaptenAlertFor(controller: UIViewController) {
    
    let alert = UIAlertController(title: "Let's get you movin' 🚗", message: "You've successfuly copied \(Const.kaptenPromoCode). Open Kapten's app and apply the promocode to enjoy 5€ off your first ride.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Got it!", style: .default , handler: nil))
    
    controller.present(alert, animated: true, completion: nil)
}


func showDirectionsAlertFor(controller: UIViewController) {
    
    let alert = UIAlertController(title: "Address", message: "Please choose an option below:", preferredStyle: .actionSheet)
    
    // Open Apple Maps
    alert.addAction(UIAlertAction(title: "Open in Apple Maps", style: .default , handler:{ (UIAlertAction)in
        
        if let url = URL(string: "http://maps.apple.com/maps?saddr=&daddr=\(Const.addressLatitude),\(Const.addressLongitude)") {
            UIApplication.shared.open(url, options: [:])
        } else {
            NSLog("Can't use maps://");
        }
    }))
    
    // Open Google Maps
    alert.addAction(UIAlertAction(title: "Open in Google Maps", style: .default , handler:{ (UIAlertAction)in
        
        if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(Const.addressLatitude),\(Const.addressLongitude)") {
            UIApplication.shared.open(url, options: [:])
            
        } else {
            if let url = URL(string: "https://maps.google.com/?q=@\(Const.addressLatitude),\(Const.addressLongitude)"){
                UIApplication.shared.open(url, options: [:])
            } else {
                NSLog("Can't use Google Maps");
            }
        }
    }))
    
    // Copy address
    alert.addAction(UIAlertAction(title: "Copy address", style: .default , handler:{ (UIAlertAction) in
        let pasteboard = UIPasteboard.general
        pasteboard.string = Const.addressULisboa
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    controller.present(alert, animated: true, completion: nil)
}
