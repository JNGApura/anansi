//
//  TabBarController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 08/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    // Custom initializers
    
    var itemList = ["Community", "Connect", "Event", "Profile"]
    
    fileprivate var tabBarViewControllers = [UINavigationController]()
    
    var user: User?
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        // Writes user's information in database
        if !UserDefaults.standard.isProfiled() {
            
            let myID = NetworkManager.shared.getUID()
            
            // Checks if user already exists in DB (use case: changed phone)
            NetworkManager.shared.fetchUser(userID: myID!) { (dictionary) in
                
                let email = dictionary["email"] as? String
                
                // If doesn't exist in DB, then registers data
                if email == nil {
                    
                    NetworkManager.shared.registerData([
                        "name": UserDefaults.standard.value(forKey: "userName") as! String,
                        "occupation": UserDefaults.standard.value(forKey: "userOccupation") as! String,
                        "location": UserDefaults.standard.value(forKey: "userLocation") as! String,
                        "gradientColor": 0,
                    ])
                }
            }

            UserDefaults.standard.setIsLoggedIn(value: true)
            UserDefaults.standard.setIsProfiled(value: true)
        }

        // Now, let's confirm we were able to register user in DB
        NetworkManager.shared.isUserLoggedIn { (dictionary, myID) in
            
            // Fetch myself from database
            self.user = User(dictionary: dictionary, id: myID)
        }

        // Add view controllers to tab bar
        for value in itemList {
            
            // Get normal & selected images
            let itemNormal = UIImage(named: value)?.withRenderingMode(.alwaysTemplate)
            let itemSelected = UIImage(named: value + "_filled")?.withRenderingMode(.alwaysTemplate)
            
            // Gets view controller from string and adds to the array of viewcontrollers
            let vc = NSObject.fromClassName(name: value + "ViewController") as! UIViewController
            
            // Inserts the view controller inside a UINavigationController stack object, so each item can have their own navigation stack
            let nc = UINavigationController()
            nc.viewControllers = [vc]
            tabBarViewControllers.append(nc)
            
            // Creates tabBarItem with title and previous images
            vc.tabBarItem = UITabBarItem(title: value, image: itemNormal, selectedImage: itemSelected)
            
            // Updates vc's title
            vc.title = value
            
            // Updates vc's background color
            vc.view.backgroundColor = .background
        }
        viewControllers = tabBarViewControllers
        
        // Set the color of active tabs
        //tabBar.tintColor = .red
        //tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: .red], for: .selected)
        
        // Set the color of inactive tabs
        tabBar.unselectedItemTintColor = .secondary
        tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.secondary], for: .normal)
        
        // Remove label to tab bar items
        removeTabBarItemText()
        
        // Remove translucence in tab bar
        tabBar.isTranslucent = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TabBar layout (UI)
    
    func removeTabBarItemText() {
        if let items = tabBar.items {
            for item in items {
                item.imageInsets = UIEdgeInsetsMake(7, 0, -7, 0);
                item.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.clear], for: .selected)
                item.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.clear], for: .normal)
            }
        }
    }
}
