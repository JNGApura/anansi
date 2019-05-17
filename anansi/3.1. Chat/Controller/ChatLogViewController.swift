//
//  ChatLogViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 15/05/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

protocol UpdatesBadgeCountDelegate {
    func updatesBadgeCount(for userID: String)
}

class ChatLogViewController: UITableViewController {
    
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
    
    // MARK: Accessory view
    
    override var inputAccessoryView: UIView {
        return chatAccessoryView
    }
    override var canBecomeFirstResponder: Bool { return true }
    
    lazy var chatAccessoryView: ChatAccessoryView = {
        let cv = ChatAccessoryView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50.0))
        cv.delegate = self
        return cv
    }()
    
    lazy var noMessageStateView: ChatEmptyState = {
        let e = ChatEmptyState(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        e.chatLogViewController = self
        return e
    }()

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        //tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24.0, right: 0) // 88
        tableView.alwaysBounceVertical = true
        tableView.backgroundColor = .background
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "cell")
        tableView.keyboardDismissMode = .interactive
        tableView.isDirectionalLockEnabled = true
        //tableView.isPagingEnabled = true
        tableView.isScrollEnabled = true
        tableView.separatorColor = .none
        
        titleLabelView.setCustomSpacing(Const.marginEight, after: userImageView)
        NSLayoutConstraint.activate([
            
            userImageView.topAnchor.constraint(equalTo: titleLabelView.topAnchor),
            userImageView.bottomAnchor.constraint(equalTo: titleLabelView.bottomAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 28.0),
            userImageView.heightAnchor.constraint(equalToConstant: 28.0),
            
            userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
        ])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBarItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hasBeenBlocked {
            chatAccessoryView.inputTextView.becomeFirstResponder()
            setupKeyboardObservers()
        }
        
        // Automatically presents keyboard and scrolls to last message
        if dates.count > 0 {
            
            reloadChats()
            
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
        
        chatAccessoryView.inputTextView.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        navigationController?.view.backgroundColor = .background
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.titleView = nil
        
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
    }
    
    // MARK: - Network
    
    private func observeMessages() {
        
        let userID = user?.getValue(forField: .id) as! String
        
        NetworkManager.shared.observeChatMessages(from: myID!, to: userID) { (mesgDictionary, mesgKey) in
            
            let message = Message(dictionary: mesgDictionary, messageID: mesgKey)
            
            let timestampSec = (message.getValue(forField: .timestamp) as? NSNumber)!.doubleValue
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
    
    // MARK: - Keyboard-related functions
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        keyboardDidShow = true
    }
    
    @objc func handleKeyboardDidHide() {
        keyboardDidShow = false
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
    
    @objc override func dismissKeyboard() {
        chatAccessoryView.inputTextView.resignFirstResponder()
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
        let lastRow = self.listOfMessagesPerDate[self.dates[lastSection]]!.count - 1
        
        self.tableView.reloadData()
        let indexPath = IndexPath(item: lastRow, section: lastSection)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension ChatLogViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dates.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let firstMessageInSection = listOfMessagesPerDate[dates[section]]?.first
        let timestampSec = (firstMessageInSection!.getValue(forField: .timestamp) as? NSNumber)!.doubleValue
        let currentMsgDate = NSDate(timeIntervalSince1970: timestampSec)
        
        return timestring(from: currentMsgDate)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (dates.count == 0) {
            tableView.backgroundView = noMessageStateView
            
        } else {
            tableView.backgroundView = nil
        }
        
        let dateString = dates[section]
        return listOfMessagesPerDate[dateString]!.count
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatMessageCell
        
        let date = dates[indexPath.section]
        let message = listOfMessagesPerDate[date]![indexPath.row]
        
        var isIncoming = false, isLast = false
        
        if (message.getValue(forField: .sender) as? String) != myID! {
            isIncoming = true
            
        } else {
            let lastsection = dates.count - 1
            let lastrow = listOfMessagesPerDate[dates[lastsection]]!.count - 1
            if indexPath.section == lastsection && indexPath.row == lastrow { isLast = true }
        }
        
        cell.config(message: message, isIncoming: isIncoming, isLast: isLast)
        
        return cell
     }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.beginUpdates()
                
        let cell = tableView.cellForRow(at: indexPath) as! ChatMessageCell
        cell.handleTimeShowRequest()
        
        tableView.endUpdates()
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80.0 // dummy
        let message = messages[indexPath.item]
        
        if let text = message.getValue(forField: .text) as? String {
            height = estimateFrameForText(text: text).height + 17 // 17: safe margin
        }
        
        // For statusView
        if indexPath.item == messages.count - 1, (message.getValue(forField: .sender) as? String) == myID! {
            height += Const.timeDateHeightChatCells
        } else {
            height += 0
        }
        
        // For timeDate text
        let timeDate = dateStamps[indexPath.item]
        if !timeDate.isEmpty {
            height += Const.timeDateHeightChatCells
            
        } else {
            height += 0
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
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
