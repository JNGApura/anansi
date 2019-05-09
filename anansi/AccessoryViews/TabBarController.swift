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
    
    var tabList = ["Community", "Connect", "Event", "Profile"]
    
    fileprivate var tabBarViewControllers = [UINavigationController]()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background

        // Add view controllers to tab bar
        for item in tabList {
            
            // Get normal & selected images
            let itemNormal = UIImage(named: item)?.withRenderingMode(.alwaysTemplate)
            let itemSelected = UIImage(named: item)?.withRenderingMode(.alwaysTemplate)
            
            // Gets view controller from string and adds to the array of viewcontrollers
            let vc = NSObject.fromClassName(name: item + "ViewController") as! UIViewController
            vc.tabBarItem = UITabBarItem(title: item, image: itemNormal, selectedImage: itemSelected)
            vc.title = item
            
            let nc = UINavigationController(rootViewController: vc)
            //nc.title = ""
            
            // Inserts the view controller inside a UINavigationController stack object, so each item can have their own navigation stack
            tabBarViewControllers.append(nc)
        }
        
        viewControllers = tabBarViewControllers
        
        // Set the color of active tabs
        //tabBar.tintColor = .red
        //tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: .red], for: .selected)
        
        // Set the color of inactive tabs
        tabBar.unselectedItemTintColor = .tertiary
        tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.tertiary], for: .normal)
        
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
                item.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0);
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.clear], for: .selected)
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.clear], for: .normal)
            }
        }
    }
}
