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

class ChatLogViewController: UITableViewController {
    
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
    
    var user: User? {
        didSet {
            
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
    
    var allMessages = [Message]() {
        didSet {
            
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
    
    /*
     lazy var transition : CATransition = {
     let t = CATransition()
     t.type = CATransitionType.push
     t.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
     t.fillMode = CAMediaTimingFillMode.forwards
     t.duration = 0.25
     t.subtype = CATransitionSubtype.fromBottom
     return t
     }()*/
    
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
        let cv = ChatAccessoryView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 44.0))
        cv.delegate = self
        return cv
    }()
    
    lazy var noMessageStateView: ChatEmptyState = {
        let e = ChatEmptyState(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        e.user = self.user
        e.delegate = self
        return e
    }()
    
    // Disconnection
    lazy var disconnectedView : UILabel = {
        let v = UILabel()
        //v.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 32.0)
        v.text = "No internet connection"
        v.textColor = .primary
        v.font = UIFont.boldSystemFont(ofSize: 14.0)
        v.textAlignment = .center
        v.backgroundColor = .background
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.hideKeyboardWhenTappedAround()
        
        // 1. TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatCell")
        tableView.register(StickerMessageCell.self, forCellReuseIdentifier: "StickerCell")
        tableView.alwaysBounceVertical = true
        tableView.isDirectionalLockEnabled = true
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.sectionHeaderHeight = 32.0
        tableView.rowHeight = UITableView.automaticDimension
        
        //tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -44.0, right: 0)
        //tableView.scrollIndicatorInsets = tableView.contentInset

        tableView.backgroundColor = .yellow
    
        //tableView.isPagingEnabled = true
        
        //tableView.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
        
        
        
        // 2. Set up observers for messages & typing
        observeMessages()
        observeTyping()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavigationBarItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
                if let receiver = message.getValue(forField: .receiver) as? String, receiver == self.myID!,
                    let isRead = message.getValue(forField: .isRead) as? Bool, !isRead {
                    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        // Adds custom titleLabelView
        titleLabelView.setCustomSpacing(Const.marginEight, after: userImageView)
        //view.addSubview(disconnectedView)
        
        NSLayoutConstraint.activate([
            
            //disconnectedView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -32.0),
            //disconnectedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //disconnectedView.widthAnchor.constraint(equalTo: view.widthAnchor),
            //disconnectedView.heightAnchor.constraint(equalToConstant: 32.0),
            
            userImageView.topAnchor.constraint(equalTo: titleLabelView.topAnchor),
            userImageView.bottomAnchor.constraint(equalTo: titleLabelView.bottomAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 28.0),
            userImageView.heightAnchor.constraint(equalToConstant: 28.0),
            
            userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
        ])
        
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
    
    // MARK: - UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dates.isEmpty ? 1 : dates.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if dates.isEmpty {
            tableView.backgroundView = noMessageStateView
            return 0
            
        } else {
            tableView.backgroundView = nil
        }
        
        let dateString = dates[section]
        return listOfMessagesPerDate[dateString]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
            
            //navigationController?.popViewController(animated: true)
            navigationController?.navigationBar.isTranslucent = true
            navigationController?.view.backgroundColor = .background
            navigationController?.fadeBack()
            
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
                self.navigationController?.fadeTo(controller)
            })
            alertController.addAction(reportUser)
        }
        
        let deleteChat = UIAlertAction(title: "Delete conversation", style: .destructive, handler: { (action) -> Void in
            
            if let userID = self.user?.getValue(forField: .id) as? String {
                
                NetworkManager.shared.deleteUserMessageNode(from: self.myID!, to: userID, onDelete: {
                    
                    //self.navigationController?.navigationBar.isHidden = !(self.cameFromUserProfile || self.cameFromSearch) // this should be commented when faceback()
                    self.navigationController?.navigationBar.isTranslucent = true
                    self.navigationController?.view.backgroundColor = .background
                    self.navigationController?.fadeBack()
                    
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
        
        //navigationController?.navigationBar.isHidden = !(cameFromUserProfile || cameFromSearch) // this should be commented when fadeback()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .background
        navigationController?.fadeBack()
        
        dismiss(animated: true, completion: nil)
    }
    
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            let myID = NetworkManager.shared.getUID()
            
            if newValue {
                let receiverID = (user?.getValue(forField: .id) as? String)!
                NetworkManager.shared.createTypingInstance(from: myID!, to: receiverID, onSucess: nil)
                
            } else {
                NetworkManager.shared.removeTypingInstance(from: myID!, onSucess: nil)
            }
        }
    }
    
    func observeTyping() {
        
        let receiverID = (user?.getValue(forField: .id) as? String)!
        
        NetworkManager.shared.observeTypingInstances(from: receiverID, onTyping: { (partnerID) in
            
            if partnerID == self.myID {
                self.chatAccessoryView.isTypingBox.isHidden = false
                self.chatAccessoryView.isTypingLabel.text = self.firstname + " is typing..."
            }
            
        }, onNotTyping: {
            
            self.chatAccessoryView.isTypingBox.isHidden = true
            self.chatAccessoryView.isTypingLabel.text = ""
        })
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension ChatLogViewController  {
    
    
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
        let userID = user?.getValue(forField: .id) as! String
        
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
        
        let partnerID = user?.getValue(forField: .id) as! String
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
