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
        hv.setProfileImage()
        hv.profileButton.addTarget(self, action: #selector(navigateToProfile), for: .touchUpInside)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up UI
        view.addSubview(headerView)
        view.addSubview(tableView)
        view.addSubview(CTAbutton)
        
        NSLayoutConstraint.activate([
            
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80.0),
            
            tableView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: headerView.widthAnchor),
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12.0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            CTAbutton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Const.marginSafeArea + 4.0),
            CTAbutton.heightAnchor.constraint(equalToConstant: 56.0),
            CTAbutton.widthAnchor.constraint(equalToConstant: 56.0),
            CTAbutton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Const.marginSafeArea + 4.0),
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
    
    override func viewWillLayoutSubviews() {
        
        // Add dropshadow to button
        CTAbutton.layer.shadowColor = UIColor.secondary.withAlphaComponent(0.4).cgColor
        CTAbutton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        CTAbutton.layer.shadowRadius = 4.0
        CTAbutton.layer.shadowOpacity = 1.0
    }
    
    // MARK: - Custom functions
    
    private func observeUserMessages() {
        
        // Just to be safe, let's remove all messages' and messagesDictionary's content
        //chats.removeAll()
        //messagesDictionary.removeAll()
        
        NetworkManager.shared.observeChats(from: myID!) { (mesg, msgID) in
            
            let chat = Message(dictionary: mesg, messageID: msgID)
            
            // Replaces message to messagesDictionary (last one = last sent)
            if let chatPartnerID = chat.partnerID() {
                self.userChats[chatPartnerID] = chat
                
                if self.myID == chat.getValue(forField: .receiver) as? String,
                    let isRead = chat.getValue(forField: .isRead) as? Bool, !isRead,
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
            return (A.getValue(forField: .timestamp) as! NSNumber).int32Value > (B.getValue(forField: .timestamp) as! NSNumber).int32Value
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
    
    @objc func navigateToProfile() {
        
        let newChatController = ProfileViewController()
        newChatController.hidesBottomBarWhenPushed = true
        
        let navController = UINavigationController(rootViewController: newChatController)
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true, completion: nil)
    }
}

// MARK: UITableViewDelegate

extension ConnectViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (latestChats.count == 0) {
            self.tableView.backgroundView = ConnectEmptyState(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        } else {
            self.tableView.backgroundView = nil
        }
        
        return latestChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatTableCell
        cell.profileImageView.kf.cancelDownloadTask() // cancel download task, if there's any
        
        let chat = latestChats[indexPath.row]
        cell.message = chat
        
        if myID == chat.getValue(forField: .receiver) as? String,
            let isRead = chat.getValue(forField: .isRead) as? Bool {
            
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
