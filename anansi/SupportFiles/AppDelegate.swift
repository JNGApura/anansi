//
//  AppDelegate.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 07/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    override init() {
        super.init()
        UIFont.overrideInitialize()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Connect to Firebase
        FirebaseApp.configure()

        // Initiate app with OnboardingViewController or, in case the user has completed onboarding, then initializes TabBarController
        let defaults = UserDefaults.standard
        window = UIWindow(frame: UIScreen.main.bounds)
        if !defaults.isOnboarded() {
            window?.rootViewController = OnboardingViewController()
        } else
        if !defaults.isLoggedIn() {
            window?.rootViewController = LoginController()
        } else {
            window?.rootViewController = TabBarController()
        }
        window?.makeKeyAndVisible()
        
        // Add red (TED's) color as main color
        UIApplication.shared.delegate?.window??.tintColor = Color.primary
        
        // Remove shadow below navigation bar
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        // Enable Keyboard accessory view
        let accessoryView = KeyboardAccessoryToolbar()
        UITextField.appearance().inputAccessoryView = accessoryView
        UITextView.appearance().inputAccessoryView = accessoryView
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

