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
    
    var tabList = ["Connect", "Community", "Event"]
    
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
            tabBarViewControllers.append(nc)
        }
        viewControllers = tabBarViewControllers

        tabBar.isTranslucent = false
        tabBar.unselectedItemTintColor = .tertiary
        tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.tertiary], for: .normal)
                
        // Remove label to tab bar items
        removeTabBarItemText()
        
        // Set offline alert shown variable to false (reachability)
        UserDefaults.standard.setOfflineAlertShown(value: false)
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
                tabitem[pos!].badgeValue = !unreadChats.isEmpty ? "\(unreadChats.count)" : nil
            }
        }
    }
    
    private func observeExistingConversations() {
        
        NetworkManager.shared.observeExistingConversations(from: myID!, onAdd: { (chatID, _) in
            
            self.observeMessagesFromChat(withID: chatID)
        
        }, onRemove: { (chatID, _) in
            
            if self.unreadChats[chatID] != nil {
                self.unreadChats[chatID] = nil
            }
            
        }, noConversations: {
            
            self.unreadChats = [:]
        })
    }
    
    private func observeMessagesFromChat(withID chatID: String) {
        
        NetworkManager.shared.observeConversation(withID: chatID, onAdd: { (mesg, key) in
            
            let chat = Message(dictionary: mesg, messageID: key)
            
            // if I'm the receiver
            if self.myID == chat.getValue(forField: .receiver) as? String,
                let isRead = chat.getValue(forField: .isRead) as? Bool,
                !isRead {
                
                if let listOfUnread = self.unreadChats[chatID] {
                    if !listOfUnread.contains(key) {
                        self.unreadChats[chatID]!.append(key)
                    }
            
                } else {
                    self.unreadChats[chatID] = [key]
                }
            }
            
        }, onChange: { (mesg, key) in
            
            let chat = Message(dictionary: mesg, messageID: key)
            
            // listOfUnreadChats only contains messages that I'm the receiver
            if let listOfUnreadChats = self.unreadChats[chatID],
                listOfUnreadChats.contains(key) {

                // isRead = true, I remove the unreadchat key from the dictionary
                if let isRead = chat.getValue(forField: .isRead) as? Bool, isRead {
                    
                    let i = listOfUnreadChats.index(of: key)
                    self.unreadChats[chatID]!.remove(at: i!)
                    
                    if self.unreadChats[chatID]!.count == 0 {
                        self.unreadChats[chatID] = nil
                    }
                
                // isRead = false, I add the unreadchat key to the dictionary
                } else {
                    self.unreadChats[chatID]!.append(key)
                }
            
            // If message became unread (for some reason), I need to add it back to unreadChats
            } else {
                
                // If I'm the receiver, of course
                if self.myID == chat.getValue(forField: .receiver) as? String {
                    
                    if self.unreadChats[chatID] != nil {
                        self.unreadChats[chatID]!.append(key)
                        
                    } else {
                        self.unreadChats[chatID] = [key]
                    }
                }
            }
            
        }, onRemove: { (mesg, key) in
            
            print("I'm here")
            
            // listOfUnreadChats only contains messages that I'm the receiver
            if let listOfUnreadChats = self.unreadChats[chatID],
                listOfUnreadChats.contains(key) {
                
                print("Yes, I've most past the conditions")
                
                let i = listOfUnreadChats.index(of: key)
                self.unreadChats[chatID]!.remove(at: i!)
                
                print("I've removed an unread chat at position \(i!)")
                
                if self.unreadChats[chatID]!.count == 0 {
                    self.unreadChats[chatID] = nil
                    
                    print("Upss, it seems unread chats for \(chatID) are decimated! (Marvel fan joke)")
                }
            }
        })
    }
    
    private func fetchImportantInfoFromMyself() {
        
        // Fetch me
        NetworkManager.shared.fetchUser(userID: myID!) { (dictionary) in
            
            // Save necessary information on disk
            if let interests = dictionary[userInfoType.interests.rawValue] as? [String] {
                UserDefaults.standard.set(interests, forKey: userInfoType.interests.rawValue)
                UserDefaults.standard.synchronize()
            }
            
            if let profileImageURL = dictionary[userInfoType.profileImageURL.rawValue] as? String {
                UserDefaults.standard.set(profileImageURL, forKey: userInfoType.profileImageURL.rawValue)
                UserDefaults.standard.synchronize()
            }
        }
    }
}
