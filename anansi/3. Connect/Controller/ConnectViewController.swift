//
//  ConnectViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 22/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class ConnectViewController: UIViewController {
    
    private var users = [User]()
    
    private var latestChats = [Message]()
    
    private var userChats = [String : Message]()
            
    var unreadChats = [String]() {
        didSet {
            
            if unreadChats.count != 0 {
                tabBarItem.badgeValue = "\(unreadChats.count)"
            } else {
                tabBarItem.badgeValue = nil
            }
        }
    }
    
    let myID = NetworkManager.shared.getUID()
    
    lazy var headerView : Header = {
        let hv = Header()
        hv.setTitleName(name: "Connect")
        hv.actionButton.setImage(UIImage(named: "new_message")?.withRenderingMode(.alwaysTemplate), for: .normal)
        hv.actionButton.addTarget(self, action: #selector(navigateToNewChatController), for: .touchUpInside)
        hv.actionButton.isHidden = false
        hv.backgroundColor = .background
        hv.translatesAutoresizingMaskIntoConstraints = false
        return hv
    }()
    
    lazy var tableView : UIDynamicTableView = {
        let tv = UIDynamicTableView()
        tv.register(ChatCell.self, forCellReuseIdentifier: "cell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = false
        tv.delegate = self
        tv.dataSource = self
        tv.rowHeight = 96
        tv.estimatedRowHeight = 96
        tv.separatorStyle = .none
        tv.allowsMultipleSelection = true
        return tv
    }()
    var tableViewHeightAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up UI
        view.addSubview(headerView)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            // Activates headerView constraints
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80.0),
            
            // Activates tableView constraints
            tableView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: headerView.widthAnchor),
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12.0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        observeUserMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Custom functions
    
    private func observeUserMessages() {
        
        // Just to be safe, let's remove all messages' and messagesDictionary's content
        //chats.removeAll()
        //messagesDictionary.removeAll()
        //tableView.reloadData()
        
        NetworkManager.shared.observeChats(from: myID!) { (mesg, msgID) in
            
            let chat = Message(dictionary: mesg, messageID: msgID)
            
            // Replaces message to messagesDictionary (last one = last sent)
            if let chatPartnerID = chat.partnerID() {
                self.userChats[chatPartnerID] = chat
                
                if self.myID == chat.receiver,
                    let isRead = chat.isRead, !isRead,
                    !self.unreadChats.contains(chatPartnerID) {
                 
                    self.unreadChats.append(chatPartnerID)
                }
            }
            
            self.reloadChats()
        }
    }
    
    func reloadChats() {
       
        latestChats = Array(userChats.values)
        latestChats.sort(by: { (A, B) -> Bool in
            return A.timestamp?.int32Value > B.timestamp?.int32Value
        })
        
        tableView.reloadData()
    }
    
    // MARK: - Layout
    
    //*** This is required to fix navigation bar forever disappear on fast backswipe bug.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupNavigationBarItems() {
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = .background
            navigationBar.isTranslucent = false
            
            navigationItem.titleView = nil
        }
    }
    
    @objc func navigateToNewChatController() {
        
        let newChatController = NewChatController(style: .grouped)
        newChatController.delegate = self
        newChatController.hidesBottomBarWhenPushed = true
        
        let navController = UINavigationController(rootViewController: newChatController)
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true, completion: nil)
    }
}

// MARK: UITableViewDelegate

extension ConnectViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (latestChats.count == 0) {
            self.tableView.backgroundView = ConnectEmptyState(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        } else {
            self.tableView.backgroundView = nil
        }
        
        return latestChats.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatCell
        cell.profileImageView.kf.cancelDownloadTask() // cancel download task, if there's any
        
        let chat = latestChats[indexPath.row]
        cell.message = chat
        
        if myID == chat.receiver, let isRead = chat.isRead {
            
            cell.badge.isHidden = isRead
            
            if isRead {
                cell.lastMessage.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
            } else {
                cell.lastMessage.font = UIFont.boldSystemFont(ofSize: Const.subheadFontSize)
            }
        }
        
        cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.tertiary.withAlphaComponent(0.5))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chat = latestChats[indexPath.row]
        guard let receiverID = chat.partnerID() else { return }
        
        NetworkManager.shared.fetchUserOnce(userID: receiverID) { (dictionary) in
            
            let user = User()
            user.set(dictionary: dictionary, id: receiverID)
            self.showChatLogController(user: user)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ChatCell
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
                
                NetworkManager.shared.deleteChatMessages(from: self.myID!, to: receiverID, onSuccess: {
                    
                    self.userChats.removeValue(forKey: receiverID)
                    self.reloadChats()
                })
            }
        }
        
        return [delete]
    }
}

// MARK: - StartNewChatDelegate

extension ConnectViewController: StartNewChatDelegate {
    
    @objc func showChatLogController(user: User) {
        
        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        chatController.delegate = self
        chatController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    func showChatController(user: User) {
        showChatLogController(user: user)
    }
}

// MARK: - UpdatesBadgeCountDelegate

extension ConnectViewController: UpdatesBadgeCountDelegate {
    
    func updatesBadgeCount(for userID: String) {
        
        if let i = unreadChats.index(of: userID) {
            unreadChats.remove(at: i)
        }
    }
}


class UIDynamicTableView: UITableView {
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: self.contentSize.height)
    }
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
}
