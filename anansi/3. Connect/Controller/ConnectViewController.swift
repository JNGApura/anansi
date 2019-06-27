//
//  ConnectViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 22/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ConnectViewController: UIViewController {
    
    private var users = [String : User]()
    private var latestChats = [Message]()
    private var userChats = [String : [Message]]()
    private var usersTyping = [String]()
    private var conversationIDs = [String]()
    
    private var areConversationsLoading = true
    
    private var CTA : String!
    
    let myID = NetworkManager.shared.getUID()
    
    lazy var headerView : Header = {
        let hv = Header()
        hv.setTitleName(name: "Connect")
        hv.setProfileImage()
        hv.profileButton.addTarget(self, action: #selector(navigateToProfile), for: .touchUpInside)
        hv.alertButton.addTarget(self, action: #selector(showOfflineAlert), for: .touchUpInside)
        hv.backgroundColor = .background
        hv.translatesAutoresizingMaskIntoConstraints = false
        return hv
    }()
    
    lazy var tableView : UIDynamicTableView = {
        let tv = UIDynamicTableView()
        tv.register(ChatTableCell.self, forCellReuseIdentifier: "ChatCell")
        tv.delegate = self
        tv.dataSource = self
        tv.rowHeight = 84.0
        tv.estimatedRowHeight = 84.0
        tv.separatorStyle = .none
        tv.allowsMultipleSelection = true
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Const.marginSafeArea, right: 0)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    lazy var CTAbutton : UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named: "NewChat")?.withRenderingMode(.alwaysTemplate), for: .normal)
        b.setImage(UIImage(named: "NewChat")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        b.backgroundColor = .primary
        b.imageView?.tintColor = .background
        b.imageView?.contentMode = .scaleToFill
        b.layer.cornerRadius = 56.0 / 2
        b.layer.masksToBounds = false
        b.addTarget(self, action: #selector(navigateToNewChatController), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // Spinner shown during load
    let spinner : UIActivityIndicatorView = {
        let s = UIActivityIndicatorView()
        s.color = .primary
        s.startAnimating()
        s.hidesWhenStopped = true
        return s
    }()
    
    // When user is disconnected
    let disconnectedView : UILabel = {
        let v = UILabel()
        v.text = "No internet connection"
        v.textColor = .background
        v.font = UIFont.boldSystemFont(ofSize: 14.0)
        v.textAlignment = .center
        v.backgroundColor = .primary
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .background
        
        // Sets up UI
        [tableView, disconnectedView, headerView, CTAbutton].forEach { view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80.0),
            
            disconnectedView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -32.0),
            disconnectedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            disconnectedView.widthAnchor.constraint(equalTo: view.widthAnchor),
            disconnectedView.heightAnchor.constraint(equalToConstant: 32.0),
            
            tableView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: headerView.widthAnchor),
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            CTAbutton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Const.marginSafeArea + 4.0),
            CTAbutton.heightAnchor.constraint(equalToConstant: 56.0),
            CTAbutton.widthAnchor.constraint(equalToConstant: 56.0),
            CTAbutton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Const.marginSafeArea + 4.0),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Observe conversations from DB
        observeUserConversations()
        
        // If someone is typing, then reload tableView to animate dots
        if usersTyping.count != 0 {
            tableView.reloadData()
        }
        
        // Placeholder message for empty state (or new chat page)
        tableView.beginUpdates()
        CTA = Const.emptystateTitle[Int.random(in: 0 ..< Const.emptystateTitle.count)]
        tableView.endUpdates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !userDefaults.bool(for: userDefaults.isConnectOnboarded) {
            
            // Presents bottom sheet
            let controller = BottomSheetView(title: "Connect", description: "Get into authentic discussions and contribute to the dissemination of bold ideas here.", image: UIImage(named: "Connect")!.withRenderingMode(.alwaysTemplate))
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            present(controller, animated: true, completion: nil)
            
            // Sets CommunityOnboarded to true
            userDefaults.updateObject(for: userDefaults.isConnectOnboarded, with: true)
        }
        
        // Handles network connectivity
        startMonitorConnectivity()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove conversation observers
        if latestChats.count > 0 {
            for chat in userChats {
                NetworkManager.shared.removeObserversForConversation(withID: chat.key)
            }
        }
        
        // Remove isTyping observer for each user
        if latestChats.count > 0 {
            for chat in latestChats {
                NetworkManager.shared.removeObserverTypingInstance(from: chat.partnerID()!)
            }
        }
        
        // Handles network reachablibity
        stopMonitorConnectivity()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("ConnectViewController: Memory is freeee")
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set profile image
        headerView.setProfileImage()
    }
    
    // MARK: - Custom functions
    
    @objc func navigateToNewChatController() {
        
        let newchat = NewChatController()
        newchat.placeholder = CTA ?? Const.emptystateTitle[0]
        newchat.delegate = self
        newchat.hidesBottomBarWhenPushed = true
        
        let navController = UINavigationController(rootViewController: newchat)
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true, completion: nil)
    }
    
    @objc func navigateToProfile() {
        
        let profile = ProfileViewController()
        profile.hidesBottomBarWhenPushed = true
        
        let navController = UINavigationController(rootViewController: profile)
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true, completion: nil)
    }
    
    
    // MARK: - Custom functions
    
    func sortConversations() {
        
        latestChats = userChats.map { $1.last! }
        latestChats.sort(by: { (A, B) -> Bool in
            
            if let a = A.getValue(forField: .timestamp) as? NSNumber,
                let b = B.getValue(forField: .timestamp) as? NSNumber {
                
                return a.int32Value > b.int32Value
            }
            return false
        })
    }
}

// MARK: UITableViewDelegate

extension ConnectViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if areConversationsLoading {
            tableView.backgroundView = spinner
            
        } else {
            
            if latestChats.count > 0 {
                tableView.backgroundView = nil
                spinner.stopAnimating()
                
            } else {
                let emptystate = ConnectEmptyState(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
                emptystate.placeholder = CTA ?? Const.emptystateTitle[0]
                tableView.backgroundView = emptystate
            }
        }
        
        return latestChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatTableCell
        cell.profileImageView.kf.cancelDownloadTask() // cancel download task, if there's any
        
        let chat = latestChats[indexPath.row]
        let partnerID = chat.partnerID()
        let isTyping = usersTyping.contains(partnerID!)
        let chatID = NetworkManager.shared.childNode(myID!, partnerID!)
        
        cell.configure(with: chat, from: users[chatID] ?? User(), and: isTyping)
        
        /*
        // Fetches user once for the specific chatID and stores in users dictionary
        NetworkManager.shared.fetchUserOnce(userID: partnerID!, onSuccess: { [weak self] (dic) in
            guard let self = self else { return }
            
            let user = User()
            user.set(dictionary: dic, id: partnerID!)
            self.users[chatID] = user
            
            cell.configure(with: chat, from: user, and: isTyping!)
        })*/
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chat = latestChats[indexPath.row]
        let chatID = NetworkManager.shared.childNode(myID ?? "", chat.partnerID() ?? "")
        let user = users[chatID] ?? User()
        
        showChatLogController(from: user, and: chatID)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatTableCell
        cell.profileImageView.kf.cancelDownloadTask()
    }
    
    // ENABLE DELETION
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            // Handle disconnect while deleting
            if ConnectionManager.shared.currentConnectivityStatus == .disconnected {
                showConnectionAlertFor(controller: self)
                return
            }
            
            let chat = self.latestChats[indexPath.row]
            if let receiverID = chat.partnerID() {
                NetworkManager.shared.deleteUserMessageNode(from: self.myID!, to: receiverID, onDelete: nil)
            }
        }
        return [delete]
    }
}

// MARK: - StartNewChatDelegate

extension ConnectViewController: StartNewChatDelegate {
    
    @objc func showChatLogController(from user: User, and chatID: String = "") {
        
        // Fetch messages
        let messages : [Message] = (chatID == "") ? [] : userChats[chatID]!
        print(messages)
        
        let chatController = ChatViewController(user: user, messages: messages)
        chatController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    func showChatController(from user: User) {
        
        showChatLogController(from: user)
    }
    
}

// MARK: - NetworkManager

extension ConnectViewController {
    
    private func observeConversations(withID chatID: String) {
        
        // If there're conversations in Firebase
        NetworkManager.shared.observeConversation(withID: chatID, onAdd: { [weak self] (mesg, msgID) in
            guard let self = self else { return }
            
            let chat = Message(dictionary: mesg, messageID: msgID)
            
            // THIS IS WHERE I NEED TO CHANGE TO UNLOCK PAGINATION BABY
            
            if let listOfMessages = self.userChats[chatID] {
                
                if !listOfMessages.contains(chat) {
                    self.userChats[chatID]!.append(chat)
                }
                
            } else {
                self.userChats[chatID] = [chat]
            }
            
            // Mark message as delivered, if I'm the receiver & !isDelivered
            if let receiver = chat.getValue(forField: .receiver) as? String,
                receiver == self.myID!,
                let isDelivered = chat.getValue(forField: .isDelivered) as? Bool,
                !isDelivered {
                
                // This will change the current message for the isDelivered key and
                // trigger the onChange method of the observeConversation function,
                // so there is no need to add sortConversations() or reloadData()
                
                NetworkManager.shared.markMessagesAs(messageInfoType.isDelivered.rawValue, withID: msgID, from: chat.getValue(forField: .sender) as! String, to: self.myID!, onSuccess: nil)
                
            } else {
                
                self.sortConversations() // this is important for table reload
                self.tableView.reloadData()
            }
            
            self.areConversationsLoading = false
            
        }, onChange: { [weak self] (mesg, msgID) in
            guard let self = self else { return }
            
            let chat = Message(dictionary: mesg, messageID: msgID)
            
            let chats = self.userChats[chatID]
            for (index, element) in chats!.enumerated() {
                
                if (element.getValue(forField: .id) as? String == msgID) {
                    self.userChats[chatID]![index] = chat
                    self.sortConversations() // this is important for table reload
                }
            }
            
            self.tableView.reloadData()
            
        }, onRemove: { [weak self] (mesg, msgID) in
            guard let self = self else { return }
            
            if let listOfMessages = self.userChats[chatID] {

                for (index, element) in listOfMessages.enumerated() {
                    
                    if (element.getValue(forField: .id) as? String == msgID) {
                        self.userChats[chatID]!.remove(at: index)

                        if self.userChats[chatID]!.count == 0 {
                            
                            // When UserMessage node is removed, it triggers observeExistingConversations onRemove
                            let chatPartnerID = element.partnerID()
                            NetworkManager.shared.deleteUserMessageNode(from: self.myID!, to: chatPartnerID!, onDelete: nil)
                            
                        } else {
                            self.sortConversations() // this is important for table reload
                        }
                    }
                }
            }
            
            self.tableView.reloadData()
        })
        
        // In case there's a chatID, but no messages
        //self.tableView.reloadData()
    }
    
    private func observeUserConversations() {
        
        NetworkManager.shared.observeExistingConversations(from: myID!, onAdd: { [weak self] (chatID, partnerID) in
            guard let self = self else { return }
            
            // Adds messages to userChats dictionary
            if !self.userChats.keys.contains(chatID) {
                
                DispatchQueue.global(qos: .default).async { [weak self] in
                    self?.observeTyping(from: partnerID)
                    self?.observeConversations(withID: chatID)
                }
            }
            
            DispatchQueue.global(qos: .default).async { [weak self] in
                
                // Fetches user once per chatID and stores in users dictionary
                NetworkManager.shared.fetchUser(userID: partnerID, onSuccess: { (dic) in
                    
                    let user = User()
                    user.set(dictionary: dic, id: partnerID)
                    self?.users[chatID] = user
                })
            }
            
        }, onRemove: { [weak self] (chatID, partnerID) in
            guard let self = self else { return }
            
            // Removes conversation from userChats dictionary
            if self.userChats.keys.contains(chatID) {
                self.userChats[chatID] = nil
                
                if self.userChats.count == 0 {
                    self.latestChats = []
                } else {
                    self.sortConversations()
                }
            }
            
            // Removes user from users dictionary
            if self.users.keys.contains(chatID) {
                self.users[chatID] = nil
            }
            
            self.tableView.reloadData()
            
        }, noConversations: { [weak self] in
            guard let self = self else { return }
            
            // Triggers empty state
            self.areConversationsLoading = false
            self.tableView.reloadData()
        })
    }
    
    func observeTyping(from userID: String) {
        
        NetworkManager.shared.observeTypingInstances(from: userID,
            onTyping: { [weak self] (typingPartnerID) in
                guard let self = self else { return }
                
                if typingPartnerID == self.myID! {
                    
                    self.usersTyping.append(userID)
                    self.tableView.reloadData()
                }
                
            }, onNotTyping: { [weak self] in
                guard let self = self else { return }
                
                if self.usersTyping.contains(userID) {
                    
                    let i = self.usersTyping.index(of: userID)
                    self.usersTyping.remove(at: i!)
                    self.tableView.reloadData()
                }
        })
    }
}

// MARK: - ConnectionManager

extension ConnectViewController {
    
    func startMonitorConnectivity() {
        
        NetworkManager.shared.setOnlineObserver(onConnected: { [weak self] in
            DispatchQueue.main.async { self?.hideAlert() }
        }, onDisconnected: { [weak self] in
            DispatchQueue.main.async { self?.showAlert() }
        })
    }
    
    func stopMonitorConnectivity() {
        NetworkManager.shared.removeOnlineObserver()
    }
    
    func showAlert() {
        
        headerView.showAlertButton()
        
        if !userDefaults.bool(for: userDefaults.wasOfflineAlertShown) {
            userDefaults.updateObject(for: userDefaults.wasOfflineAlertShown, with: true)
            showOfflineAlert()
        }
    }
    
    func hideAlert() {
        
        headerView.hideAlertButton()
        userDefaults.updateObject(for: userDefaults.wasOfflineAlertShown, with: false)
    }
    
    @objc func showOfflineAlert() {
        showConnectionAlertFor(controller: self)
    }
}
