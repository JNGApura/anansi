//
//  ConnectViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 22/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import ReachabilitySwift

class ConnectViewController: UIViewController {
    
    var presentTransition: UIViewControllerAnimatedTransitioning?
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    
    private var users = [String : User]()
    
    private var latestChats = [Message]()
    
    private var userChats = [String : [Message]]()
    
    private var conversationIDs = [String]()
        
    private var areConversationsLoading = true
    
    private var CTA : String!
    
    private var typingPartner = String()
    
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
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 96.0
        tv.separatorStyle = .none
        tv.allowsMultipleSelection = true
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Const.marginSafeArea, right: 0)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    var tableViewHeightAnchor: NSLayoutConstraint?
    
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
    
    let reachability = Reachability()!
    
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
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12.0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            CTAbutton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Const.marginSafeArea + 4.0),
            CTAbutton.heightAnchor.constraint(equalToConstant: 56.0),
            CTAbutton.widthAnchor.constraint(equalToConstant: 56.0),
            CTAbutton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Const.marginSafeArea + 4.0),
        ])
        
        // Observe conversations from DB
        observeUserConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // This is important, because I'm using a fake navigation bar
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Handles network reachablibity
        startMonitoringNetwork()
        
        // Placeholder message for empty state (or new chat page)
        CTA = Const.emptystateTitle[Int.random(in: 0 ..< Const.emptystateTitle.count)]
        
        // Enables swipe to pop
        swipeToPop()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if !UserDefaults.standard.isConnectOnboarded() {
            
            // Presents bottom sheet
            let controller = BottomSheetView()
            controller.setContent(title: "Connect",
                                  description: "Get into authentic discussions and contribute to the dissemination of bold ideas here.")
            controller.setIcon(image: UIImage(named: "Connect")!.withRenderingMode(.alwaysTemplate))
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            present(controller, animated: true, completion: nil)
            
            // Sets CommunityOnboarded to true
            UserDefaults.standard.setConnectOnboarded(value: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Stop NetworkStatusListener
        reachability.stopNotifier()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        // Navigation Bar was hidden in viewDidAppear
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerView.setProfileImage()
    }
    
    // MARK: - Custom functions
    
    @objc func navigateToNewChatController() {
        
        let newchat = NewChatController(style: .grouped)
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
        let isTyping = (myID! == typingPartner)
        let chatID = NetworkManager.shared.childNode(myID!, partnerID!)
        
        if let user = users[chatID] {
            cell.configure(with: chat, from: user, and: isTyping)
            
        } else {
            
            // Fetches user once for the specific chatID and stores in users dictionary
            NetworkManager.shared.fetchUserOnce(userID: partnerID!, onSuccess: { (dic) in
                
                let user = User()
                user.set(dictionary: dic, id: partnerID!)
                
                self.users[chatID] = user
                cell.configure(with: chat, from: user, and: isTyping)
            })
        }
        
        cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.tertiary.withAlphaComponent(0.5))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chat = latestChats[indexPath.row]
        let partnerID = chat.partnerID()
        let chatID = NetworkManager.shared.childNode(myID!, partnerID!)
        
        if let user = users[chatID] {
            showChatLogController(user: user, and: userChats[chatID]!)
        }
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
    
    @objc func showChatLogController(user: User, and messages: [Message] = []) {
        
        let chatController = ChatLogViewController()
        chatController.user = user
        chatController.allMessages = messages
        chatController.hidesBottomBarWhenPushed = true
                
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    func showChatController(user: User) {
        
        showChatLogController(user: user)
    }
}

// MARK: - NetworkStatusListener | Handles network reachability

extension ConnectViewController {
    
    func startMonitoringNetwork() {
        
        reachability.whenUnreachable = { reachability in
            DispatchQueue.main.async { self.showAlert() }
        }
        
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async { self.hideAlert() }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        if reachability.isReachable {
            DispatchQueue.main.async { self.hideAlert() }
        } else {
            DispatchQueue.main.async { self.showAlert() }
        }
    }
    
    func showAlert() {
        
        headerView.showAlertButton()
        
        if !UserDefaults.standard.offlineAlertWasShown() {
            UserDefaults.standard.setOfflineAlertShown(value: true)
            showOfflineAlert()
        }
    }
    
    func hideAlert() {
        
        headerView.hideAlertButton()
        
        UserDefaults.standard.setOfflineAlertShown(value: false)
    }
    
    @objc func showOfflineAlert() {
        
        let alert = UIAlertController(title: "No internet connection 😳", message: "We'll keep trying to reconnect. Meanwhile, could you check your data or wifi connection?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "On it!", style: .default , handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - NetworkManager

extension ConnectViewController {
    
    private func observeConversations(withID chatID: String) {
        
        // If there're conversations in Firebase
        NetworkManager.shared.observeConversation(withID: chatID, onAdd: { (mesg, msgID) in
            
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
            
        }, onChange: { (mesg, msgID) in
            
            let chat = Message(dictionary: mesg, messageID: msgID)
            
            let chats = self.userChats[chatID]
            for (index, element) in chats!.enumerated() {
                
                if (element.getValue(forField: .id) as? String == msgID) {
                    self.userChats[chatID]![index] = chat
                    self.sortConversations() // this is important for table reload
                }
            }
            
            self.tableView.reloadData()
            
        }, onRemove: { (mesg, msgID) in
            
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
        
        NetworkManager.shared.observeExistingConversations(from: myID!, onAdd: { (chatID, partnerID) in
            
            // Adds messages to userChats dictionary
            if !self.userChats.keys.contains(chatID) {
                self.observeConversations(withID: chatID)
                self.observeTyping(from: partnerID)
            }
            
            // Fetches user once per chatID and stores in users dictionary
            NetworkManager.shared.fetchUser(userID: partnerID, onSuccess: { (dic) in
                
                let user = User()
                user.set(dictionary: dic, id: partnerID)
                
                self.users[chatID] = user
            })
            
        }, onRemove: { (chatID, partnerID) in
            
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
            
        }, noConversations: {
            
            // Triggers empty state
            self.areConversationsLoading = false
            self.tableView.reloadData()
        })
    }
    
    func observeTyping(from userID: String) {
        
        NetworkManager.shared.observeTypingInstances(from: userID, onTyping: { (partnerID) in
            
            self.typingPartner = partnerID
            self.tableView.reloadData()
            
        }, onNotTyping: {
            
            self.typingPartner = String()
            self.tableView.reloadData()
        })
    }
}

extension ConnectViewController: UIGestureRecognizerDelegate {
    
    func swipeToPop() {
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
        navigationController?.interactivePopGestureRecognizer?.delegate = self;
    }
}
