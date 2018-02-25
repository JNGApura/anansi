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
    
    //var user: User?
    
    let defaults = UserDefaults.standard
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background

        // Checks if user already exists in DB
        let myID = NetworkManager.shared.getUID()
        NetworkManager.shared.fetchUser(userID: myID!) { (dictionary) in
            
            let name = dictionary["name"] as? String
            
            // If doesn't exist in DB, then registers data
            if name == nil {
                
                // Writes user's information in database
                NetworkManager.shared.registerUserData([
                    "name": self.defaults.value(forKey: "userName") as! String,
                    "occupation": self.defaults.value(forKey: "userOccupation") as! String,
                    "location": self.defaults.value(forKey: "userLocation") as! String,
                    "gradientColor": 0,
                ])
            }
        }

        // Add view controllers to tab bar
        for value in itemList {
            
            // Get normal & selected images
            let itemNormal = UIImage(named: value)?.withRenderingMode(.alwaysTemplate)
            let itemSelected = UIImage(named: value + "_filled")?.withRenderingMode(.alwaysTemplate)
            
            // Gets view controller from string and adds to the array of viewcontrollers
            var nc : UINavigationController
            
            if value == "Community" {
                
                let vc = CommunityViewController(collectionViewLayout: UICollectionViewFlowLayout())
                nc = UINavigationController(rootViewController: vc)
                vc.tabBarItem = UITabBarItem(title: value, image: itemNormal, selectedImage: itemSelected)
                vc.title = value
            } else {
                
                let vc = NSObject.fromClassName(name: value + "ViewController") as! UIViewController
                nc = UINavigationController(rootViewController: vc)
                vc.tabBarItem = UITabBarItem(title: value, image: itemNormal, selectedImage: itemSelected)
                vc.title = value
            }
                        
            // Inserts the view controller inside a UINavigationController stack object, so each item can have their own navigation stack
            tabBarViewControllers.append(nc)

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
        
        // This should be removed
        /*NetworkManager.shared.registerPartnerData(["name": "Santander Universidades",
                                                   "field": "Finance",
                                                   "location": "Lisboa"])

        NetworkManager.shared.registerPartnerData(["name": "Técnico Lisboa",
                                                   "field": "Education",
                                                   "location": "Lisboa"])
        
        NetworkManager.shared.registerPartnerData(["name": "IEEE-IST Student Branch",
                                                   "field": "Education",
                                                   "location": "Lisboa"])
        
        NetworkManager.shared.registerPartnerData(["name": "Findmore Consulting",
                                                   "field": "IT/Consulting",
                                                   "location": "Lisboa"])*/
        
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
