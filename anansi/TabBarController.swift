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
        
        observeMessages()
        
        view.backgroundColor = .background

        // Add view controllers to tab bar
        for item in tabList {
            
            // Get normal & selected images
            let itemNormal = UIImage(named: item)?.withRenderingMode(.alwaysTemplate)
            let itemSelected = UIImage(named: item)?.withRenderingMode(.alwaysTemplate)
            
            // Gets view controller from string and adds to the array of viewcontrollers
            let vc = NSObject.fromClassName(name: item + "ViewController")
            vc.tabBarItem = UITabBarItem(title: item, image: itemNormal, selectedImage: itemSelected)
            vc.title = item
            
            let nc = UINavigationController(rootViewController: vc)
            tabBarViewControllers.append(nc)
        }
        viewControllers = tabBarViewControllers

        tabBar.isTranslucent = false
        tabBar.unselectedItemTintColor = .tertiary
        tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.tertiary], for: .normal)
                
        // Remove label to tab bar items
        removeTabBarItemText()
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
    
    // MARK: - Unread bagde for the connect (item = 1)
    
    var unreadChats = [String]() {
        didSet {
            
            if unreadChats.count != 0 {
                tabBar.items![1].badgeValue = "\(unreadChats.count)"
            } else {
                tabBar.items![1].badgeValue = nil
            }
        }
    }
    
    private func observeMessages() {
        
        let myID = NetworkManager.shared.getUID()
        
        NetworkManager.shared.observeChats(from: myID!) { (mesg, key) in
            
            let chat = Message(dictionary: mesg, messageID: key)
            
            if myID == chat.getValue(forField: .receiver) as? String,
                let isRead = chat.getValue(forField: .isRead) as? Bool, !isRead,
                let chatPartnerID = chat.partnerID(),
                !self.unreadChats.contains(chatPartnerID) {
                
                self.unreadChats.append(chatPartnerID)
            }
        }
    }
}
