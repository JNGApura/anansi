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

protocol UpdatesBadgeCountDelegate {
    func updatesBadgeCount(for userID: String)
}

class ChatLogViewController: UIViewController {
    
    var delegate: UpdatesBadgeCountDelegate?
    
    var keyboardDidShow = false
    
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
    
    var user: User? {
        didSet {
            observeMessages()
            
            var fullname = ((user?.getValue(forField: .name) as? String)!).components(separatedBy: " ")
            firstname = fullname.removeFirst()
            chatAccessoryView.placeholderText = "Message \(firstname)"
            
            // User information in navigation bar
            userNameLabel.text = (user?.getValue(forField: .name) as? String)!
            
            if let userImage = user?.getValue(forField: .profileImageURL) as? String {
                userImageView.setImage(with: userImage)
            } else {
                userImageView.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
            }
            
            // Hides chatAcessoryView if user is blocked
            if let blockedDic = user?.getValue(forField: .blockedUsers) as? [String: String] {
                
                if blockedDic.index(forKey: myID!) != nil {
                    hasBeenBlocked = true
                }
            }
        }
    }
    
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
    
    lazy var noMessageStateView: ChatEmptyState = {
        let e = ChatEmptyState(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        e.chatLogViewController = self
        return e
    }()
    
    // Disconnection
    let disconnectedView : UILabel = {
        let v = UILabel()
        v.text = "No internet connection"
        v.textColor = .primary
        v.font = UIFont.boldSystemFont(ofSize: 14.0)
        v.textAlignment = .center
        v.backgroundColor = .background
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var transition : CATransition = {
        let t = CATransition()
        t.type = CATransitionType.push
        t.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        t.fillMode = CAMediaTimingFillMode.forwards
        t.duration = 0.25
        t.subtype = CATransitionSubtype.fromBottom
        return t
    }()
    
    lazy var tableView : UITableView = {
        let tv = UITableView.init(frame: CGRect.zero, style: .grouped)
        tv.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatCell")
        tv.register(StickerMessageCell.self, forCellReuseIdentifier: "StickerCell")
        tv.delegate = self
        tv.dataSource = self
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 64.0, right: 0) // 88
        tv.backgroundColor = .background
        tv.sectionHeaderHeight = 32.0
        tv.alwaysBounceVertical = true
        tv.keyboardDismissMode = .interactive
        tv.isDirectionalLockEnabled = true
        //tv.isPagingEnabled = true
        tv.isScrollEnabled = true
        tv.separatorStyle = .none
        tv.tableFooterView = UIView(frame: CGRect.zero)
        tv.sectionFooterHeight = 0.0
        tv.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let reachability = Reachability()!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        view.backgroundColor = .background

        // Custom views / constraints
        titleLabelView.setCustomSpacing(Const.marginEight, after: userImageView)
        
        view.addSubview(tableView)
        view.addSubview(disconnectedView)
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            disconnectedView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -32.0),
            disconnectedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            disconnectedView.widthAnchor.constraint(equalTo: view.widthAnchor),
            disconnectedView.heightAnchor.constraint(equalToConstant: 32.0),
            
            userImageView.topAnchor.constraint(equalTo: titleLabelView.topAnchor),
            userImageView.bottomAnchor.constraint(equalTo: titleLabelView.bottomAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 28.0),
            userImageView.heightAnchor.constraint(equalToConstant: 28.0),
            
            userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
        ])
        
        // Handles network connection
        startMonitoringNetwork()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBarItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hasBeenBlocked {
            setupKeyboardObservers()
        }
        
        // Automatically presents keyboard and scrolls to last message
        if dates.count > 0 {
            
            //reloadChats()
            
            // Get list of unread messages
            var hasUnreadMessages = 0
            
            for date in dates {
                for message in listOfMessagesPerDate[date]! {
                    
                    if (message.getValue(forField: .receiver) as? String) == self.myID!,
                        let isRead = message.getValue(forField: .isRead) as? Bool, !isRead {
                        
                        let userID = user?.getValue(forField: .id) as! String
                        let messageID = message.getValue(forField: .id) as? String
                        NetworkManager.shared.markMessagesAs("read", with: messageID!, from: self.myID!, to: userID) {}
                        hasUnreadMessages += 1
                    }
                }
            }
            
            if hasUnreadMessages != 0 {
                
                let userID = user?.getValue(forField: .id) as! String
                self.delegate?.updatesBadgeCount(for: userID)
            }
        }
        
        observeTyping()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if keyboardDidShow {
            chatAccessoryView.inputTextView.resignFirstResponder()
        }
        
        // Stop NetworkStatusListener
        reachability.stopNotifier()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        // Adds custom leftBarButton
        let leftButton: UIButton = {
            let b = UIButton(type: .system)
            b.setImage(UIImage(named: "back")!.withRenderingMode(.alwaysTemplate), for: .normal)
            b.frame = CGRect(x: 0, y: 0, width: Const.navButtonHeight, height: Const.navButtonHeight)
            b.tintColor = .primary
            b.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
            return b
        }()
        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: leftButton), UIBarButtonItem(customView: titleLabelView)]
        
        // Adds custom rightBarButton
        let rightButton: UIButton = {
            let b = UIButton(type: .system)
            b.setImage(UIImage(named: "info")!.withRenderingMode(.alwaysTemplate), for: .normal)
            b.frame = CGRect(x: 0, y: 0, width: Const.navButtonHeight, height: Const.navButtonHeight)
            b.tintColor = .secondary
            b.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
            return b
        }()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        
        navigationController?.view.backgroundColor = .background
        navigationController?.navigationBar.isTranslucent = false
        //navigationController?.navigationBar.installBlurEffect()
        navigationItem.titleView = nil
    }
    
    // MARK: - Network
    
    private func observeMessages() {
        
        let userID = user?.getValue(forField: .id) as! String
        
        NetworkManager.shared.observeChatMessages(from: myID!, to: userID) { (mesgDictionary, mesgKey) in
            
            let message = Message(dictionary: mesgDictionary, messageID: mesgKey)
            
            if let timestamp = message.getValue(forField: .timestamp) as? NSNumber {
            
                let timestampSec = timestamp.doubleValue
                let currentMsgDate = NSDate(timeIntervalSince1970: timestampSec)
                let dateString = createDateIntervalStringForMessage(from: currentMsgDate)
                
                if !(self.dates.contains(dateString)) {
                    self.dates.append(dateString)
                    self.listOfMessagesPerDate[dateString] = [message]
                    
                } else {
                    self.listOfMessagesPerDate[dateString]!.append(message)
                }
                
                if self.dates.count > 0 { self.reloadChats() }
            }
        }
    }
    
    // MARK: - Keyboard-related functions
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func handleKeyboardDidShow(notification: NSNotification) {
        keyboardDidShow = true
        reloadChats()
        
        /*
        guard let userInfo = notification.userInfo,
            let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let keyboardHeight = keyboardEndFrame.height
        let screenHeight = view.frame.height
        
        //let distanceToBottom = screenHeight - (cellMaxY + tableView.frame.origin.y - scrollView.contentOffset.y)
        let collapseSpace = keyboardHeight //- distanceToBottom
        
        if collapseSpace < 0 { return }
        //tableView.frame.origin.y -= collapseSpace
        view.layoutIfNeeded()*/
    }
    
    @objc func handleKeyboardDidHide() {
        keyboardDidShow = false
    }
    
    @objc override func dismissKeyboard() {
        chatAccessoryView.inputTextView.resignFirstResponder()
    }
    
    // MARK: - Custom functions
    
    @objc func showsUserProfilePage() {
        
        if cameFromUserProfile {
            
            navigationController?.popViewController(animated: true)
            navigationController?.navigationBar.isTranslucent = true
            navigationController?.view.backgroundColor = .background
            
            dismiss(animated: true, completion: nil)
            
        } else {
            
            let controller = UserPageViewController()
            controller.user = user
            controller.cameFromChat = true
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self.navigationController, action: nil)
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
                self.navigationController?.pushViewController(controller, animated: true)
            })
            alertController.addAction(reportUser)
        }
        
        let deleteChat = UIAlertAction(title: "Delete conversation", style: .destructive, handler: { (action) -> Void in
            
            if let userID = self.user?.getValue(forField: .id) as? String {
                
                NetworkManager.shared.deleteChatMessages(from: self.myID!, to: userID, onSuccess: {
                    
                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.navigationBar.isHidden = !(self.cameFromUserProfile || self.cameFromSearch) // this is very important!
                    self.navigationController?.navigationBar.isTranslucent = true
                    self.navigationController?.view.backgroundColor = .background
                    
                    self.dismiss(animated: true, completion: nil)
                })
            }
        })
        alertController.addAction(deleteChat)
        
        // Dismiss alertController
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func backAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        
        self.navigationController?.navigationBar.isHidden = !(cameFromUserProfile || cameFromSearch) // this is very important!
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .background
        
        self.dismiss(animated: true, completion: nil)
    }
    
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            
            if newValue {
                let receiverID = (user?.getValue(forField: .id) as? String)!
                let myID = NetworkManager.shared.getUID()
                NetworkManager.shared.register(value: receiverID, for: "isTypingTo", in: myID!)
                
            } else {
                NetworkManager.shared.removeData("isTypingTo")
            }
        }
    }
    
    func observeTyping() {
        
        let receiverID = (user?.getValue(forField: .id) as? String)!
        
        NetworkManager.shared.observeTypingInstances(from: receiverID, onSuccess: {
            
            self.chatAccessoryView.isTypingBox.isHidden = false
            self.chatAccessoryView.isTypingLabel.text = (self.user!.getValue(forField: .name) as? String)! + " is typing..."
            
        }) {
            self.chatAccessoryView.isTypingBox.isHidden = true
            self.chatAccessoryView.isTypingLabel.text = ""
        }
    }
    
    func reloadChats() {
        
        let lastSection = self.dates.count - 1
        if let lastMessages = self.listOfMessagesPerDate[self.dates[lastSection]] {
        
            self.tableView.reloadData()
            let indexPath = IndexPath(item: lastMessages.count - 1, section: lastSection)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension ChatLogViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let firstMessageInSection = listOfMessagesPerDate[dates[section]]?.first
        let timestampSec = (firstMessageInSection!.getValue(forField: .timestamp) as? NSNumber)!.doubleValue
        let currentMsgDate = NSDate(timeIntervalSince1970: timestampSec)
        
        let v = UIView()
        v.backgroundColor = .background
        
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
    
    /*
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (dates.count == 0) {
            tableView.backgroundView = noMessageStateView
            
        } else {
            tableView.backgroundView = nil
        }
        
        let dateString = dates[section]
        return listOfMessagesPerDate[dateString]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get all the info needed
        let date = dates[indexPath.section]
        let message = listOfMessagesPerDate[date]![indexPath.row]
        let usrimg = user?.getValue(forField: .profileImageURL) as? String ?? ""
        
        var isIncoming = false, isLast = false
        
        if (message.getValue(forField: .sender) as? String) != myID! {
            isIncoming = true
            
        } else {
            let lastsection = dates.count - 1
            let lastrow = listOfMessagesPerDate[dates[lastsection]]!.count - 1
            if indexPath.section == lastsection && indexPath.row == lastrow { isLast = true }
        }
        
        // Determines which type is required
        if (message.getValue(forField: .text) as? String) == ":compass:" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "StickerCell", for: indexPath) as! StickerMessageCell
            cell.gestureRecognizerDelegate = self
            cell.indexPath = indexPath
            cell.config(message: message, isIncoming: isIncoming, isLast: isLast, with: usrimg)
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatMessageCell
            cell.gestureRecognizerDelegate = self
            cell.indexPath = indexPath
            cell.config(message: message, isIncoming: isIncoming, isLast: isLast, with: usrimg)
            return cell
        }
     }
    
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.beginUpdates()
                
        let cell = tableView.cellForRow(at: indexPath) as! ChatMessageCell
        //cell.handleTimeShowRequest()
        
        tableView.endUpdates()
    }*/
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
        
        reloadChats()
    }
    
    func isTypingMessage(value: Bool) {
        isTyping = value
    }
    
    @objc func sendWave() {
        sendMessageWith(string: "👋")
    }
    
    private func sendMessageWith(string: String) {
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let currentTime = formatter.string(from: Date())
        
        let myID = NetworkManager.shared.getUID()
        let userID = user?.getValue(forField: .id) as! String
        
        let message : [String: Any] = ["createdAt": currentTime,
                                       "message": string,
                                       "sent": "false",
                                       "received": "false",
                                       "read": "false",
                                       "sender": myID!,
                                       "receiver": userID]
        
        NetworkManager.shared.postChatMessageInDB(sender: myID!, receiver: userID, message: message) {
            
            if self.dates.count == 0 {
                self.observeMessages()
                
            } else {
                DispatchQueue.main.async {
                    self.reloadChats()
                }
            }
        }
    }
}

extension ChatLogViewController: CellGestureRecognizerDelegate {
    
    func singleTapDetected(in indexPath: IndexPath) {
        // Nothing here (not implemented in ChatMessageCell
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
        
        let copy = UIMenuItem(title: "Copy", action: #selector(copytxt(_:)))
        let deleteTxt = UIMenuItem(title: "Unsend", action: #selector(unsendTxt(_:)))
        let deleteSticker = UIMenuItem(title: "Unsend", action: #selector(unsendSticker(_:)))
        let menu = UIMenuController.shared
        
        if let cell = tableView.cellForRow(at: indexPath) as? ChatMessageCell {
            menu.menuItems = (myID == receiver) ? [copy] : [copy, deleteTxt]
            menu.setTargetRect(sender.view!.frame, in: cell)
            
        } else {
            menu.menuItems = (myID == receiver) ? [] : [deleteSticker]
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
        
        let msgID = message.getValue(forField: .id) as? String
        let sender = message.getValue(forField: .sender) as? String
        let receiver = message.getValue(forField: .receiver) as? String
        
        let dateString = createDateIntervalStringForMessage(from: NSDate(timeIntervalSince1970: (message.getValue(forField: .timestamp) as? NSNumber)!.doubleValue))
        var msgArray = listOfMessagesPerDate[dateString]
        
        if let j = msgArray?.index(of: message) {
            
            NetworkManager.shared.deleteMessage(with: msgID!, from: sender!, to: receiver!) {
                
                // Remove msg from listOfMessagesPerDate
                msgArray?.remove(at: j)
                self.listOfMessagesPerDate[dateString] = msgArray
                
                // If listOfMessagesPerDate becomes empty for a specific date, remove the section
                if msgArray?.count == 0 {
                    let i = self.dates.index(of: dateString)
                    self.dates.remove(at: i!)
                }
                
                self.tableView.reloadData()
            }
        }
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
            DispatchQueue.main.async { self.disconnectedView.isHidden = true }
        } else {
            DispatchQueue.main.async { self.showAlert() }
        }
    }
    
    func showAlert() {
        
        self.disconnectedView.isHidden = false
        
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
