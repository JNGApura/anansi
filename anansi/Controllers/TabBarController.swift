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
    var itemList = ["Profile", "Event", "Explore"]
    fileprivate lazy var tabBarViewControllers: [UIViewController] = {
        return [
            ProfileViewController(),
            EventViewController(),
            ExploreViewController(),
        ]
    }()
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add view controllers to tab bar
        var pos = 0
        for vc in tabBarViewControllers {
            
            // Get normal & selected images
            let itemNormal = UIImage(named: itemList[pos])?.withRenderingMode(.alwaysTemplate)
            let itemSelected = UIImage(named: itemList[pos] + "_filled")?.withRenderingMode(.alwaysTemplate)
            
            // Creates tabBarItem with title and previous images
            vc.tabBarItem = UITabBarItem(title: itemList[pos], image: itemNormal, selectedImage: itemSelected)
            
            // Updates vc's title
            vc.title = itemList[pos]
            
            // Updates vc's background color
            vc.view.backgroundColor = Color.background
            
            pos += 1
        }
        viewControllers = tabBarViewControllers
        
        // Set the color of active tabs
        //tabBar.tintColor = .red
        //tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: .red], for: .selected)
        
        // Set the color of inactive tabs
        tabBar.unselectedItemTintColor = Color.secondary
        tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Color.secondary], for: .normal)
        
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
