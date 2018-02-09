//
//  ConnectViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 22/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

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

class ConnectViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    private let cellIdentifier = "cell"
    
    private var users = [User]()
    private var messages = [Message]()
    private var messagesDictionary = [String: Message]()
    
    private let titleLabelView: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondary
        label.alpha = 0.0
        label.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        label.text = "Connect"
        return label
    }()
    
    lazy var scrollView : UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.alwaysBounceVertical = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView : UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let headerView : Header = {
        let hv = Header()
        hv.setTitleName(name: "Connect")
        hv.translatesAutoresizingMaskIntoConstraints = false
        return hv
    }()
    
    lazy var tableView : UIDynamicTableView = {
        let tv = UIDynamicTableView()
        tv.register(MessageCell.self, forCellReuseIdentifier: cellIdentifier)
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
        
        // Sets up navigation bar
        setupNavigationBarItems()
        
        // Sets up UI
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        contentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            // Activates scrollView constraints
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Activates contentView constraints
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // Activates headerView constraints
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 58.0),
            
            // Activates tableView constraints
            tableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20.0),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.0),
        ])
        
        tableViewHeightAnchor = tableView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: -98.0)
        
        observeUserMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.titleView?.isHidden = false
        navigationItem.titleView?.alpha = 0.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewDidDisappear(animated)
        navigationItem.titleView?.isHidden = true
    }
    
    private func observeUserMessages() {
        
        // Just to be safe, let's remove all messages' and messagesDictionary's content
        messages.removeAll()
        messagesDictionary.removeAll()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userID = snapshot.key
            let userRef = ref.child(userID)
            userRef.observe(.childAdded, with: { (snapshot) in
                
                let messageID = snapshot.key
                let messageReference = Database.database().reference().child("messages").child(messageID)//.queryOrdered(byChild: "timestamp")
                
                messageReference.observe(.value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: Any] {
                        
                        let message = Message(dictionary: dictionary)
                        
                        if let chatPartnerID = message.messagePartnerID() {
                            self.messagesDictionary[chatPartnerID] = message
                        }
                        
                        self.attemptReloadTable()
                    }
                
                }, withCancel: nil)
            
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        // Remove messages externally
        ref.observe(.childRemoved, with: { (snapshot) in
            
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadTable()
            
        }, withCancel: nil)
    }
    
    private func attemptReloadTable() {
        // Huge hack
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    @objc func handleReloadTable() {

        messages = Array(messagesDictionary.values)
        messages.sort(by: { (A, B) -> Bool in
            return A.timestamp?.int32Value > B.timestamp?.int32Value
        })
        
        DispatchQueue.main.async( execute: {
            self.tableView.reloadData()
        })
    }
    
    private func setupNavigationBarItems() {
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = .background
            navigationBar.isTranslucent = false
            
            // Sets title
            navigationItem.titleView = titleLabelView
            //navigationItem.titleView?.alpha = 0.0
            
            // Sets rightButtonItem
            let button: UIButton = {
                let b = UIButton(type: .system)
                b.setImage(#imageLiteral(resourceName: "new_message").withRenderingMode(.alwaysTemplate), for: .normal)
                b.frame = CGRect(x: 0, y: 0, width: Const.navButtonHeight, height: Const.navButtonHeight)
                b.tintColor = .secondary
                //button.addTarget(self, action: #selector(navigateToSettingsViewController), for: .touchUpInside)
                return b
            }()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY : CGFloat = scrollView.contentOffset.y
        let titleOriginY : CGFloat = headerView.headerTitle.frame.origin.y
        let lineMaxY : CGFloat = headerView.headerBottomBorder.frame.maxY
        let label = navigationItem.titleView as? UILabel
        
        if offsetY >= titleOriginY {
            if (offsetY - lineMaxY) < 0 {
                label?.alpha = (offsetY - titleOriginY) / (lineMaxY - titleOriginY)
            } else {
                label?.alpha = 1.0
            }
        } else {
            label?.alpha = 0.0
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (messages.count == 0) {
            scrollView.alwaysBounceVertical = false
            tableViewHeightAnchor?.isActive = true
            self.tableView.backgroundView = ConnectEmptyState(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            
        } else {
            scrollView.alwaysBounceVertical = true
            tableViewHeightAnchor?.isActive = false
            self.tableView.backgroundView = nil
        }
        
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        if NetworkManager.shared.getUID() == message.receiver {
            
            if let isRead = message.isRead {

                cell.badge.isHidden = isRead
                if isRead {
                    cell.lastMessage.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
                } else {
                    cell.lastMessage.font = UIFont.boldSystemFont(ofSize: Const.subheadFontSize)
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatParterID = message.messagePartnerID() else { return }
        
        let ref = Database.database().reference().child("users").child(chatParterID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            let user = User(dictionary: dictionary, id: chatParterID) // snapshot.key
            self.showChatLogController(user: user)
            
        }, withCancel: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func showChatLogController(user: User) {
        
        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        chatController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    /*func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            guard let uid = NetworkManager.shared.getUID() else { return }
            
            let message = self.messages[indexPath.row]
            if let messagePartnerID = message.messagePartnerID() {
                
                let ref = Database.database().reference().child("user-messages").child(uid).child(messagePartnerID)
                ref.removeValue(completionBlock: { (error, ref) in
                    
                    if error != nil {
                        print("Failed to delete message:", error!)
                        return
                    }
                    
                    self.messagesDictionary.removeValue(forKey: messagePartnerID)
                    self.attemptReloadTable()
                })
            }
        }
        
        return [delete]
    }*/
    
}

class UIDynamicTableView: UITableView {
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIViewNoIntrinsicMetric, height: self.contentSize.height)
    }
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
}
