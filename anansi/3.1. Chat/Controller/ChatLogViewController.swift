//
//  ChatLogViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 15/05/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import ReachabilitySwift

class ChatLogViewController: UIViewController {
    
    var isOnPage = false
    
    var keyboardIsActive = false
    
    var cameFromUserProfile = false
    
    var cameFromSearch = false
    
    var hasBeenBlocked = false {
        didSet {
            noMessageStateView.messageLabel.isHidden = hasBeenBlocked
            noMessageStateView.waveHandEmoji.isHidden = hasBeenBlocked
            noMessageStateView.waveButton.isHidden = hasBeenBlocked
            
            chatAccessoryView.isHidden = hasBeenBlocked
        }
    }
    
    let myID = NetworkManager.shared.getUID()
    
    var dates = [String]()
    
    var listOfMessagesPerDate = [String : [Message]]()
    
    var activeIndexPath: IndexPath! // when user long-presses a message
        
    var firstname : String = "..."
    
    private var localTyping = false
    
    private var partnerIsTyping = false
    
    var user: User
    var allMessages: [Message]
    
    
    // TitleLabelView
    
    lazy var userImageView : UIImageView = {
        let i = UIImageView()
        i.backgroundColor = .background
        i.contentMode = .scaleAspectFill
        i.layer.cornerRadius = 14.0
        i.clipsToBounds = true
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    lazy var userNameLabel : UILabel = {
        let l = UILabel()
        l.textColor = .secondary
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        l.backgroundColor = .clear
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    lazy var titleLabelView : UIStackView = {
        let sv = UIStackView(arrangedSubviews: [userImageView, userNameLabel])
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.alignment = .fill
        sv.backgroundColor = .clear
        sv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showsUserProfilePage)))
        sv.isUserInteractionEnabled = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // Accessory view
    
    override var inputAccessoryView: UIView {
        return chatAccessoryView
    }
    override var canBecomeFirstResponder: Bool { return true }
    
    lazy var chatAccessoryView: ChatAccessoryView = {
        let cv = ChatAccessoryView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44.0))
        cv.delegate = self
        return cv
    }()
    
    // Empty state
    
    lazy var noMessageStateView: ChatEmptyState = {
        let e = ChatEmptyState(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        e.user = self.user
        e.delegate = self
        return e
    }()
    
    // NavBar
    
    lazy var topbar: TopBar = {
        let b = TopBar()
        b.setTitle(name: "")
        b.backgroundColor = .background
        b.alpha(with: 1.0)
        b.titleLabel.alpha = 0.0
        b.bottomLine.alpha = 0.0
        b.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        b.setActionButton(with: UIImage(named: "info")!.withRenderingMode(.alwaysTemplate))
        b.actionButton.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // View
    
    lazy var tableView : UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: .grouped)
        tv.delegate = self
        tv.dataSource = self
        tv.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatCell")
        tv.register(StickerMessageCell.self, forCellReuseIdentifier: "StickerCell")
        tv.register(TypingMessageCell.self, forCellReuseIdentifier: "TypingCell")
        tv.alwaysBounceVertical = true
        tv.isDirectionalLockEnabled = true
        tv.separatorStyle = .none
        tv.keyboardDismissMode = .interactive
        tv.sectionHeaderHeight = 32.0
        tv.rowHeight = UITableView.automaticDimension
        tv.backgroundColor = .background
        
        //tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -44.0, right: 0)
        //tv.scrollIndicatorInsets = tableView.contentInset

        //tv.isPagingEnabled = true
        //tv.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // Disconnection
    
    lazy var disconnectedView : UILabel = {
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
    
    let statusBarHeight : CGFloat = UIApplication.shared.statusBarFrame.height
    
    
    // MARK: - Init
    
    init(user: User, messages: [Message]) {
        self.user = user
        self.allMessages = messages
        super.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.hideKeyboardWhenTappedAround()
        
        view.backgroundColor = .background
        
        // Sets up UI
        [tableView, disconnectedView, topbar, titleLabelView].forEach { view.addSubview($0) }
        titleLabelView.setCustomSpacing(Const.marginEight, after: userImageView)
        
        // Set up observers for messages & typing
        observeMessages()
        observeTyping()
        
        // Config view controller
        setUser()
        setMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Handles network reachablibity
        startMonitoringNetwork()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 0. Set isOnPage as true
        isOnPage = true
        
        // 1. Setup keyboard observers
        if !hasBeenBlocked {
            setupKeyboardObservers()
        }
        
        // 2. Automatically presents keyboard if there's no message
        if dates.isEmpty {
            chatAccessoryView.inputTextView.becomeFirstResponder()
        
        // 3. If there're messages, mark them as Read
        } else {
            
            let allMessages = listOfMessagesPerDate.flatMap { $1 }
            for message in allMessages {
                
                // If I'm the receiver && !isRead
                if let receiver = message.getValue(forField: .receiver) as? String,
                    receiver == self.myID!,
                    let isRead = message.getValue(forField: .isRead) as? Bool,
                    !isRead {
                    
                    NetworkManager.shared.markMessagesAs(messageInfoType.isRead.rawValue, withID: message.getValue(forField: .id) as! String, from: message.getValue(forField: .sender) as! String, to: myID!, onSuccess: nil)
                }
            }
        }
        
        if tableView.contentSize.height > tableView.frame.size.height {
            
            tableView.reloadData()
            tableView.layoutIfNeeded()
            
            let offset = CGPoint(x: 0, y: tableView.contentSize.height + inputAccessoryView.frame.height - (tableView.frame.size.height))
            tableView.setContentOffset(offset, animated: true)
            //tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if keyboardIsActive {
            chatAccessoryView.inputTextView.resignFirstResponder()
        }
        
        // Stop NetworkStatusListener
        reachability.stopNotifier()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)

        chatAccessoryView.inputTextView.endEditing(true)
        
        // Set isOnPage as false
        isOnPage = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topbar.setStatusBarHeight(with: statusBarHeight)
        topbar.setNavigationBarHeight(with: Const.barHeight)
        
        NSLayoutConstraint.activate([
            
            // Navbar
            
            topbar.topAnchor.constraint(equalTo: view.topAnchor),
            topbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topbar.heightAnchor.constraint(equalToConstant: Const.barHeight + statusBarHeight),
            
            userImageView.centerYAnchor.constraint(equalTo: topbar.navigationbar.centerYAnchor),
            userImageView.leadingAnchor.constraint(equalTo: topbar.backButton.trailingAnchor, constant: Const.marginEight * 2.0),
            userImageView.widthAnchor.constraint(equalToConstant: 28.0),
            userImageView.heightAnchor.constraint(equalToConstant: 28.0),
            
            userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            
            disconnectedView.topAnchor.constraint(equalTo: topbar.bottomAnchor, constant: -32.0),
            disconnectedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            disconnectedView.widthAnchor.constraint(equalTo: view.widthAnchor),
            disconnectedView.heightAnchor.constraint(equalToConstant: 32.0),
            
            // View
            
            tableView.topAnchor.constraint(equalTo: topbar.bottomAnchor),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        
        ])
    }
    
    // MARK: - Custom functions
    
    func setUser() {
        
        var fullname = ((user.getValue(forField: .name) as? String)!).components(separatedBy: " ")
        firstname = fullname.removeFirst()
        chatAccessoryView.placeholderText = "Message \(firstname)"
        
        // User information in navigation bar
        userNameLabel.text = (user.getValue(forField: .name) as? String)!
        if let userImage = user.getValue(forField: .profileImageURL) as? String {
            userImageView.setImage(with: userImage)
        } else {
            userImageView.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
        }
        
        // Hides chatAcessoryView if user is blocked
        if let blockedDic = user.getValue(forField: .blockedUsers) as? [String: String] {
            
            if blockedDic.index(forKey: myID!) != nil {
                hasBeenBlocked = true
            }
        }
    }
    
    func setMessages() {
        
        if !allMessages.isEmpty {
            for message in allMessages {
                
                let timestamp = message.getValue(forField: .timestamp) as! NSNumber
                let dateString = createDateIntervalStringForMessage(from: NSDate(timeIntervalSince1970: timestamp.doubleValue))
                
                if !(dates.contains(dateString)) {
                    dates.append(dateString)
                    listOfMessagesPerDate[dateString] = [message]
                } else {
                    listOfMessagesPerDate[dateString]!.append(message)
                }
            }
        }
    }
}


// MARK: - UITableViewDelegate

extension ChatLogViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dates.isEmpty ? 1 : dates.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if !dates.isEmpty {
            
            let v = UIView()
            v.backgroundColor = .background
            
            let firstMessageInSection = listOfMessagesPerDate[dates[section]]?.first
            let timestampSec = (firstMessageInSection!.getValue(forField: .timestamp) as? NSNumber)!.doubleValue
            let currentMsgDate = NSDate(timeIntervalSince1970: timestampSec)
            
            let l : UILabel = {
                let l = UILabel()
                l.text = timestring(from: currentMsgDate)
                l.backgroundColor = .clear
                l.textColor = UIColor.secondary.withAlphaComponent(0.5)
                l.font = UIFont.systemFont(ofSize: Const.captionFontSize)
                l.textAlignment = .center
                l.translatesAutoresizingMaskIntoConstraints = false
                return l
            }()
            
            v.addSubview(l)
            v.addConstraint(NSLayoutConstraint(item: l, attribute: .centerY, relatedBy: .equal, toItem: v, attribute: .centerY, multiplier: 1.0, constant: 6.0))
            v.addConstraint(NSLayoutConstraint(item: l, attribute: .centerX, relatedBy: .equal, toItem: v, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            
            return v
            }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if dates.isEmpty {
            tableView.backgroundView = noMessageStateView
            return 0
            
        } else {
            tableView.backgroundView = nil
        }
        
        let dateString = dates[section]
        return listOfMessagesPerDate[dateString]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let lastsection = dates.count - 1
        let lastrow = listOfMessagesPerDate[dates[lastsection]]!.count - 1
        
        if partnerIsTyping,
            indexPath.section == lastsection && indexPath.row == lastrow {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TypingCell", for: indexPath) as! TypingMessageCell
            cell.indexPath = indexPath
            cell.config()
            
            let date = dates[indexPath.section]
            let message = listOfMessagesPerDate[date]![indexPath.row]
            print(message.getValue(forField: .id) as! String)
            
            return cell
            
        } else {
        
            // Get all the info needed
            let date = dates[indexPath.section]
            let message = listOfMessagesPerDate[date]![indexPath.row]
            let usrimg = user.getValue(forField: .profileImageURL) as? String ?? ""
            
            var isIncoming = false, showStatus = false
            
            if (message.getValue(forField: .sender) as? String) != myID! {
                isIncoming = true
                
            } else {
                
                // If chatPartner is not typing
                if !partnerIsTyping && indexPath.section == lastsection && indexPath.row == lastrow {
                    showStatus = true
                    
                } else if partnerIsTyping && indexPath.section == lastsection && indexPath.row == lastrow - 1 {
                    showStatus = true
                }
            }
            
            // Determines which type is required
            if (message.getValue(forField: .text) as? String) == ":compass:" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "StickerCell", for: indexPath) as! StickerMessageCell
                cell.gestureRecognizerDelegate = self
                cell.indexPath = indexPath
                cell.config(message: message, isIncoming: isIncoming, showStatus: showStatus, with: usrimg)
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatMessageCell
                cell.gestureRecognizerDelegate = self
                cell.indexPath = indexPath
                cell.config(message: message, isIncoming: isIncoming, showStatus: showStatus, with: usrimg)
                return cell
            }
        }
    }
}
    
// MARK: - Keyboard-related functions

extension ChatLogViewController {
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func adjustKeyboard(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo,
            let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let keyboardHeight = keyboardEndFrame.height
        let collapseSpace = keyboardHeight - view.safeAreaInsets.bottom
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            
            keyboardIsActive = false
            
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.contentInset = .zero
            }, completion: nil)
            
        } else {
            
            keyboardIsActive = true
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: collapseSpace, right: 0)
        }
        
        tableView.scrollIndicatorInsets = tableView.contentInset
        
        //tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: collapseSpace, right: 0)
        //tableView.contentInset =  UIEdgeInsets(top: 0, left: 0, bottom: collapseSpace, right: 0)
        
        //tableViewBottomAnchor?.constant = -collapseSpace
        view.layoutIfNeeded()
        
        //reloadChats()
        
    }
    
    @objc override func dismissKeyboard() {
        chatAccessoryView.inputTextView.resignFirstResponder()
    }
    
    func reloadChats() {
        
        tableView.reloadData()
        
        // I need to check this.
        // Bug: when there's no message, the reloadChats should be called after the message is placed, not before. Otherwise, we won't have dates.count or listOfMessagesPerDate
        /*
        if dates.count > 0 {
            
            let lastSection = self.dates.count - 1
            if let lastMessages = self.listOfMessagesPerDate[self.dates[lastSection]] {
                
                tableView.reloadData()
                let indexPath = IndexPath(item: lastMessages.count - 1, section: lastSection)
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            
            DispatchQueue.main.async {
                //self.view.layoutIfNeeded()
            }
        }*/
    }
}
    
// MARK: - Custom functions

extension ChatLogViewController {
    
    @objc func showsUserProfilePage() {
        
        if cameFromUserProfile {
            
            navigationController?.popViewController(animated: true)
                        
        } else {
            
            let controller = UserPageViewController(user: user)
            controller.cameFromChat = true
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func showActionSheet() {
        // TO DO: add other functionalities, like sharing contact, etc
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tintColor = UIColor.init(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1.0) // Apple's blue?
        
        let contactDetails = UIAlertAction(title: "Contact details", style: .default, handler: { (action) -> Void in
            
            self.showsUserProfilePage()
        })
        alertController.addAction(contactDetails)
        
        // Only show report abuse if hasn't been blocked already
        if !hasBeenBlocked {
            let reportUser = UIAlertAction(title: "Report abuse", style: .destructive, handler: { (action) -> Void in
                
                let controller = ReportAbuseViewController()
                controller.delegate = self
                controller.user = self.user
                
                self.navigationController?.navigationBar.isTranslucent = true
                self.navigationController?.pushViewController(controller, animated: true)
            })
            alertController.addAction(reportUser)
        }
        
        let deleteChat = UIAlertAction(title: "Delete conversation", style: .destructive, handler: { (action) -> Void in
            
            if let userID = self.user.getValue(forField: .id) as? String {
                
                NetworkManager.shared.deleteUserMessageNode(from: self.myID!, to: userID, onDelete: {
                    self.back()
                })
            }
        })
        alertController.addAction(deleteChat)
        
        // Dismiss alertController
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            let myID = NetworkManager.shared.getUID()
            
            if newValue {
                let receiverID = (user.getValue(forField: .id) as? String)!
                NetworkManager.shared.createTypingInstance(from: myID!, to: receiverID, onSucess: nil)
                
            } else {
                NetworkManager.shared.removeTypingInstance(from: myID!, onSucess: nil)
            }
        }
    }
    
    func observeTyping() {
        
        let receiverID = (user.getValue(forField: .id) as? String)!
        
        NetworkManager.shared.observeTypingInstances(from: receiverID, onTyping: { (partnerID) in
            
            if partnerID == self.myID {
                
                self.partnerIsTyping = true
                
                let lastsection = self.dates.count - 1
                let typingMessage = Message(dictionary: [:], messageID: "typingMessage")
                self.listOfMessagesPerDate[self.dates[lastsection]]!.append(typingMessage)
                
                self.tableView.reloadData()
            }
            
        }, onNotTyping: {
            
            if self.partnerIsTyping {
            
                self.partnerIsTyping = false
                
                let lastSection = self.dates[self.dates.count - 1]
                let lastMessage = self.listOfMessagesPerDate[lastSection]!.count - 1
                let lastMessageFromLastSection = self.listOfMessagesPerDate[lastSection]![lastMessage]
                
                if (lastMessageFromLastSection.getValue(forField: .id) as! String) == "typingMessage" {
                    self.listOfMessagesPerDate[lastSection]!.removeLast()
                }
                
                self.tableView.reloadData()
            }
        })
    }
}

// MARK: - UserWasReported

extension ChatLogViewController: UserWasReported {
    
    func userWasReported(user: User) {
        
        let controller = ReportConfirmationView()
        controller.user = user
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        
        present(controller, animated: true, completion: nil)
    }
}

// MARK: - ChatAccessoryDelegate

extension ChatLogViewController: ChatAccessoryDelegate {
    
    func sendMessage(message: String) {
        
        sendMessageWith(string: message)
        
        chatAccessoryView.inputTextView.text = nil
        chatAccessoryView.inputTextView.placeholder = "Message \(firstname)"
        isTyping = false
        
        tableView.reloadData()
        
        if !dates.isEmpty {
            
            let lastSection = dates.count - 1
            let lastRow = listOfMessagesPerDate[dates[lastSection]]!.count - 1
            let indexPath = IndexPath(item: lastRow, section: lastSection)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func isTypingMessage(value: Bool) {
        isTyping = value
    }
    
    private func sendMessageWith(string: String) {
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let currentTime = formatter.string(from: Date())
        
        let myID = NetworkManager.shared.getUID()
        let userID = user.getValue(forField: .id) as! String
        
        let message : [String: Any] = [messageInfoType.timestamp.rawValue: currentTime, messageInfoType.text.rawValue: string, messageInfoType.isSent.rawValue: "false", messageInfoType.isDelivered.rawValue: "false", messageInfoType.isRead.rawValue: "false", messageInfoType.sender.rawValue: myID!, messageInfoType.receiver.rawValue: userID]
        
        NetworkManager.shared.postChatMessageInDB(sender: myID!, receiver: userID, message: message, onSuccess: nil)
    }
}

// MARK: - ChatEmptyStateDelegate

extension ChatLogViewController: ChatEmptyStateDelegate {
    
    func wave() {
        sendMessageWith(string: "👋")
    }
}

// MARK: - CellGestureRecognizerDelegate

extension ChatLogViewController: CellGestureRecognizerDelegate {
    
    func singleTapDetected(in indexPath: IndexPath) {
        // Nothing here (not implemented in ChatMessageCell)
    }
    
    func doubleTapDetected(in indexPath: IndexPath, with message: Message, and love: Bool) {
        
        activeIndexPath = indexPath
        
        let msgID = message.getValue(forField: .id) as? String
        let sender = message.getValue(forField: .sender) as? String
        let receiver = message.getValue(forField: .receiver) as? String
        
        if love {
            NetworkManager.shared.registerReaction("heart", for: msgID!, to: sender!, from: receiver!) {
                
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
        } else {
            NetworkManager.shared.removeReaction("heart", for: msgID!, to: sender!, from: receiver!) {

                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
        }
    }
    
    // Long press shows an alert controller with some functionalities, such as copy, unsend, etc
    func longPressDetected(in indexPath: IndexPath, with message: Message, from sender: UILongPressGestureRecognizer) {
        
        becomeFirstResponder()
        
        activeIndexPath = indexPath
        
        let receiver = message.getValue(forField: .receiver) as? String
        let isSent = message.getValue(forField: .isSent) as! Bool
        
        let copy = UIMenuItem(title: "Copy", action: #selector(copytxt(_:)))
        let deleteTxt = UIMenuItem(title: "Unsend", action: #selector(unsendTxt(_:)))
        let deleteSticker = UIMenuItem(title: "Unsend", action: #selector(unsendSticker(_:)))
        let menu = UIMenuController.shared
        
        if let cell = tableView.cellForRow(at: indexPath) as? ChatMessageCell {
            menu.menuItems = (myID == receiver) ? [copy] : (isSent ? [copy, deleteTxt] : [copy] )
            menu.setTargetRect(sender.view!.frame, in: cell)
            
        } else {
            menu.menuItems = (myID == receiver) ? [] : (isSent ? [deleteSticker] : [])
            menu.setTargetRect(sender.view!.frame, in: tableView.cellForRow(at: indexPath) as! StickerMessageCell)
        }
        menu.setMenuVisible(true, animated: true)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copytxt(_:)) {
            return true
        } else if action == #selector(unsendTxt(_:)) {
            return true
        } else if action == #selector(unsendSticker(_:)) {
            return true
        }
        return false
    }
    
    @objc func copytxt(_ sender: Any?) {
        
        let cell = tableView.cellForRow(at: activeIndexPath) as! ChatMessageCell
        if let txt = cell.message!.getValue(forField: .text) as? String {
            UIPasteboard.general.string = txt
        }
    }
    
    @objc func unsendTxt(_ sender: Any?) {
        
        let cell = tableView.cellForRow(at: activeIndexPath) as! ChatMessageCell
        if let msg = cell.message {
            unsend(message: msg)
        }
    }
    
    @objc func unsendSticker(_ sender: Any?) {
        
        let cell = tableView.cellForRow(at: activeIndexPath) as! StickerMessageCell
        if let msg = cell.message {
            unsend(message: msg)
        }
    }
    
    func unsend(message: Message) {
        
        let msgID = message.getValue(forField: .id) as! String
        let sender = message.getValue(forField: .sender) as! String
        let receiver = message.getValue(forField: .receiver) as! String
        
        NetworkManager.shared.deleteMessage(with: msgID, from: sender, to: receiver, onDelete: nil)
    }
}

// MARK: - NetworkManager

extension ChatLogViewController {
    
    private func observeMessages() {
        
        let partnerID = user.getValue(forField: .id) as! String
        let chatID = NetworkManager.shared.childNode(myID!, partnerID)
        
        // If there're conversations in Firebase
        NetworkManager.shared.observeConversation(withID: chatID, onAdd: { (mesg, msgID) in
            
            let message = Message(dictionary: mesg, messageID: msgID)
            
            if let timestamp = message.getValue(forField: .timestamp) as? NSNumber {
                let dateString = createDateIntervalStringForMessage(from: NSDate(timeIntervalSince1970: timestamp.doubleValue))
                
                if !(self.dates.contains(dateString)) {
                    self.dates.append(dateString)
                    self.listOfMessagesPerDate[dateString] = [message]
                    
                } else {
                    
                    // this is necessary, because I'm sending all my messages from ConnectViewController here and I don't want duplicates
                    let messageKeysForDate = self.listOfMessagesPerDate[dateString]!.map { $0.getValue(forField: .id) as! String }
                    if !messageKeysForDate.contains(msgID) {
                        self.listOfMessagesPerDate[dateString]!.append(message)
                    }
                }
                
                // If I'm the receiver && !isRead, marks the message as read
                if self.isOnPage,
                    let receiver = message.getValue(forField: .receiver) as? String, receiver == self.myID!,
                    let isRead = message.getValue(forField: .isRead) as? Bool, !isRead {
                    
                    NetworkManager.shared.markMessagesAs(messageInfoType.isRead.rawValue, withID: msgID, from: message.getValue(forField: .sender) as! String, to: self.myID!, onSuccess: nil)
                }
            }
            
            self.reloadChats()
            
        }, onChange: { (mesg, msgID) in
            
            let message = Message(dictionary: mesg, messageID: msgID)
            
            let timestamp = message.getValue(forField: .timestamp) as! NSNumber
            let dateString = createDateIntervalStringForMessage(from: NSDate(timeIntervalSince1970: timestamp.doubleValue))
            
            if let chatsForDate = self.listOfMessagesPerDate[dateString] {
                for (index, element) in chatsForDate.enumerated() {
                    
                    if (element.getValue(forField: .id) as! String == msgID) {
                        self.listOfMessagesPerDate[dateString]![index] = message
                    }
                }
            }
            
            self.reloadChats()
            
        }, onRemove: { (mesg, msgID) in
            
            let message = Message(dictionary: mesg, messageID: msgID)
            
            let timestamp = message.getValue(forField: .timestamp) as! NSNumber
            let dateString = createDateIntervalStringForMessage(from: NSDate(timeIntervalSince1970: timestamp.doubleValue))
            
            if let chatsForDate = self.listOfMessagesPerDate[dateString] {
                
                for (index, element) in chatsForDate.enumerated() {
                    
                    if (element.getValue(forField: .id) as! String == msgID) {
                        self.listOfMessagesPerDate[dateString]!.remove(at: index)
                    }
                    
                    if self.listOfMessagesPerDate[dateString]!.isEmpty {
                        self.listOfMessagesPerDate[dateString] = nil
                        
                        let i = self.dates.index(of: dateString)
                        self.dates.remove(at: i!)
                    }
                }
            }
            
            self.reloadChats()
        })
        
        // In case there's a chatID, but no messages
        //self.tableView.reloadData()
    }
}

// MARK: - NetworkStatusListener | Handles network reachability

extension ChatLogViewController {
    
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
        
        disconnectedView.isHidden = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.disconnectedView.transform = CGAffineTransform(translationX: 0, y: 32.0)
        })
    }
    
    func hideAlert() {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.disconnectedView.transform = .identity
            
        }, completion: { (bool) in
            self.disconnectedView.isHidden = true
        })
    }
}
