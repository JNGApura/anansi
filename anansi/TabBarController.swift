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
    
    var tabList = ["Community", "Connect", "Event"]
    
    fileprivate var tabBarViewControllers = [UINavigationController]()
    
    private let myID = NetworkManager.shared.getUID()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeExistingConversations()
        fetchImportantInfoFromMyself()
        
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
            nc.navigationBar.isHidden = true
            tabBarViewControllers.append(nc)
        }
        viewControllers = tabBarViewControllers

        tabBar.isTranslucent = false
        tabBar.unselectedItemTintColor = .tertiary
        tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.tertiary], for: .normal)
                
        // Remove label to tab bar items
        removeTabBarItemText()
        
        // Set offline alert shown variable to false (connectivity)
        userDefaults.updateObject(for: userDefaults.wasOfflineAlertShown, with: false)
        
        // Requests notifications, if we haven't asked before
        if !PushNotificationManager.shared.hasSeenPushNotificationRequest() {
            
            PushNotificationManager.shared.registerForPushNotifications {
                PushNotificationManager.shared.updateFirestorePushTokenIfNeeded()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Add remove listener
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    var unreadChats = [String : [String]]() {
        didSet {
            let pos = tabList.index(of: "Connect")
            
            if let tabitem = tabBar.items {
                
                // Tabitem badge
                tabitem[pos!].badgeValue = !unreadChats.isEmpty ? "\(unreadChats.count)" : nil
                
                // Icon badge
                UIApplication.shared.applicationIconBadgeNumber = !unreadChats.isEmpty ? unreadChats.count : 0
            }
        }
    }
    
    private func observeExistingConversations() {
        
        NetworkManager.shared.observeExistingConversations(from: myID!, onAdd: { [weak self] (chatID, _) in
            
            self?.observeMessagesFromChat(withID: chatID)
        
        }, onRemove: { [weak self] (chatID, _) in
            
            if self?.unreadChats[chatID] != nil {
                self?.unreadChats[chatID] = nil
            }
            
        }, noConversations: { [weak self] in
            
            self?.unreadChats = [:]
        })
    }
    
    private func observeMessagesFromChat(withID chatID: String) {
        
        NetworkManager.shared.observeConversation(withID: chatID, onAdd: { [weak self] (mesg, key) in
            
            let chat = Message(dictionary: mesg, messageID: key)
            
            // if I'm the receiver
            if self?.myID == chat.getValue(forField: .receiver) as? String,
                let isRead = chat.getValue(forField: .isRead) as? Bool,
                !isRead {
                
                if let listOfUnread = self?.unreadChats[chatID] {
                    
                    if !listOfUnread.contains(key) {
                        self?.unreadChats[chatID]!.append(key)
                    }
            
                } else {
                    self?.unreadChats[chatID] = [key]
                }
            }
            
        }, onChange: { [weak self] (mesg, key) in
            
            let chat = Message(dictionary: mesg, messageID: key)
            
            // Note: listOfUnreadChats only contains messages that I'm the receiver
            if let listOfUnreadChats = self?.unreadChats[chatID],
                listOfUnreadChats.contains(key),
                let isRead = chat.getValue(forField: .isRead) as? Bool,
                isRead {
                
                let i = listOfUnreadChats.index(of: key)
                self?.unreadChats[chatID]!.remove(at: i!)
                
                if self?.unreadChats[chatID]!.count == 0 {
                    self?.unreadChats[chatID] = nil
                }
            }
            
        }, onRemove: { [weak self] (mesg, key) in
            
            // Note: listOfUnreadChats only contains messages that I'm the receiver
            if let listOfUnreadChats = self?.unreadChats[chatID],
                listOfUnreadChats.contains(key) {
                
                let i = listOfUnreadChats.index(of: key)
                self?.unreadChats[chatID]!.remove(at: i!)
                
                if self?.unreadChats[chatID]!.count == 0 {
                    self?.unreadChats[chatID] = nil
                }
            }
        })
    }
    
    private func fetchImportantInfoFromMyself() {
        
        // Fetch me
        NetworkManager.shared.fetchUserOnce(userID: myID!) { (dictionary) in
            
            // Save necessary information on disk
            if let interests = dictionary[userInfoType.interests.rawValue] as? [String] {
                userDefaults.updateObject(for: userInfoType.interests.rawValue, with: interests)
            }
            
            if let profileImageURL = dictionary[userInfoType.profileImageURL.rawValue] as? String {
                userDefaults.updateObject(for: userInfoType.profileImageURL.rawValue, with: profileImageURL)
            }
        }
    }
}
