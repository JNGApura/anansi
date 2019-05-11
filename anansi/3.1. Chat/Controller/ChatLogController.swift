//
//  ChatLogController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 24/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class ChatLogController: UICollectionViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate  {
    
    var keyboardDidShow = false
    
    var cameFromUserProfile: Bool = false
    
    var cameFromSearch: Bool = false
    
    var hasBeenBlocked : Bool = false {
        didSet {
            emptyStateView.messageLabel.isHidden = hasBeenBlocked
            emptyStateView.waveHandEmoji.isHidden = hasBeenBlocked
            emptyStateView.waveButton.isHidden = hasBeenBlocked
            
            chatAccessoryView.isHidden = hasBeenBlocked
        }
    }
    
    let myID = NetworkManager.shared.getUID()
    
    var messages = [Message]()
    
    var unreadMessages = [String]()
    
    var dateStamps = [String]()
    
    var timestamps = [Double]()
    
    var firstname : String = "..."
    
    private var localTyping = false
    
    var titleLabelView : UIButton = {
        let b = UIButton()
        b.setTitleColor(.secondary, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        b.backgroundColor = .clear
        b.addTarget(self, action: #selector(printStuff), for: .touchUpInside)
        return b
    }()
    
    @objc func printStuff() {
        print("stuff")
    }
    
    var user: User? {
        didSet {
            observeMessages()
            
            var fullname = ((user?.getValue(forField: .name) as? String)!).components(separatedBy: " ")
            firstname = fullname.removeFirst()
            chatAccessoryView.placeholderText = "Message \(firstname)"
            
            titleLabelView.setTitle((user?.getValue(forField: .name) as? String)!, for: .normal)
            
            // Hides chatAcessoryView if user is blocked
            if let blockedDic = user?.getValue(forField: .blockedUsers) as? [String: String] {
                
                if blockedDic.index(forKey: myID!) != nil {
                    hasBeenBlocked = true
                }
            }
        }
    }
    
    override var inputAccessoryView: UIView {
        return chatAccessoryView
    }
    override var canBecomeFirstResponder: Bool { return true }
    
    lazy var chatAccessoryView: ChatAccessoryView = {
        let cv = ChatAccessoryView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50.0))
        cv.delegate = self
        return cv
    }()
    
    lazy var emptyStateView: ChatEmptyState = {
        let e = ChatEmptyState(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        e.chatLogController = self
        return e
    }()
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24.0, right: 0) // 88
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.keyboardDismissMode = .interactive
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
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
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
    
    private func observeMessages() {
        
        let userID = user?.getValue(forField: .id) as! String
        
        NetworkManager.shared.observeChatMessages(from: myID!, to: userID) { (mesgDictionary, mesgKey) in
            
            let message = Message(dictionary: mesgDictionary)
            self.messages.append(message)
            
            // Get list of unread messages
            if message.receiver == self.myID!, let isRead = message.isRead, !isRead {
                NetworkManager.shared.markMessagesAs("read", with: mesgKey, from: self.myID!, to: userID) {}
            }
            
            // Creates list of time labels
            if let seconds = message.timestamp?.doubleValue {
                
                if self.messages.count == 1 {
                    let dateA = NSDate(timeIntervalSince1970: seconds)
                    self.dateStamps.append(createTimeString(date: dateA))
                    
                    self.timestamps.append(seconds)
                    
                } else {
                    
                    let dateA = NSDate(timeIntervalSince1970: self.timestamps.last!)
                    let dateB = NSDate(timeIntervalSince1970: seconds)
                    
                    self.timestamps.append(seconds)
                    
                    self.dateStamps.append(createTimeString(dateA: dateA as Date, dateB: dateB as Date))
                }
            }
            
            self.collectionView?.reloadData()
            self.collectionView?.scrollToBottom()
        }
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        keyboardDidShow = true
        
        /*
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }*/
    }
    
    @objc func handleKeyboardDidHide() {
        keyboardDidShow = false
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        navigationController?.view.backgroundColor = .background
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.titleView = titleLabelView
        
        // Adds custom leftBarButton
        let leftButton: UIButton = {
            let b = UIButton(type: .system)
            b.setImage(UIImage(named: "back")!.withRenderingMode(.alwaysTemplate), for: .normal)
            b.frame = CGRect(x: 0, y: 0, width: Const.navButtonHeight, height: Const.navButtonHeight)
            b.tintColor = .primary
            b.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
            return b
        }()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        
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
    
    @objc func showActionSheet() {
        // TO DO: add other functionalities, like sharing contact, etc
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tintColor = UIColor.init(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1.0) // Apple's blue?
        
        let contactDetails = UIAlertAction(title: "Contact details", style: .default, handler: { (action) -> Void in
        
            if self.cameFromUserProfile {
                
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.navigationBar.isTranslucent = true
                self.navigationController?.view.backgroundColor = .background
                
                self.dismiss(animated: true, completion: nil)
                
            } else {
        
                let controller = UserPageViewController()
                controller.user = self.user
                controller.cameFromChat = true
                controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self.navigationController, action: nil)
                self.navigationController?.pushViewController(controller, animated: true)
            }
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
    
    // MARK: User Interaction
    
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
    
}

// MARK: User Interaction

extension ChatLogController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (messages.count == 0) {
            collectionView.backgroundView = emptyStateView
            titleLabelView.isHidden = true
            
        } else {
            collectionView.backgroundView = nil
            titleLabelView.isHidden = false
        }
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.message = message
        
        let timeDate = dateStamps[indexPath.item]
        if !timeDate.isEmpty {
            cell.timeDate.text = timeDate
            cell.timeDate.isHidden = false
            
        } else {
            cell.timeDate.isHidden = true
        }
        
        if message.sender == myID! {
            
            // cell is aligned to the right
            cell.stackView.alignment = .trailing
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
            // cell has red background with white text
            cell.bubbleView.backgroundColor = .primary
            cell.bubbleView.layer.borderColor = UIColor.primary.cgColor
            cell.textView.textColor = .background
            
            // If the last message is mine, then status is visible
            if indexPath.item == messages.count - 1  {
                
                cell.statusView.isHidden = false
                cell.statusView.text = (message.isRead)! ? "Read" : (message.isDelivered)! ? "Delivered" : "Sent"
                
            } else {
                cell.statusView.isHidden = true
            }
            
        } else {
            
            // cell is aligned to the left
            cell.stackView.alignment = .leading
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            
            // cell has gray background with black text
            cell.bubbleView.backgroundColor = UIColor.tertiary.withAlphaComponent(0.5)
            cell.bubbleView.layer.borderColor = UIColor.tertiary.withAlphaComponent(0.5).cgColor
            cell.textView.textColor = .secondary
            
            // status is NOT visible
            cell.statusView.isHidden = true
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80.0 // dummy
        let message = messages[indexPath.item]
        
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 17 // 17: safe margin
        }
        
        // For statusView
        if indexPath.item == messages.count - 1, message.sender == myID! {
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
    }
    
    // MARK: - Custom functions
    
    func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 224, height: 1000) // height arbitrarily high
        let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Const.bodyFontSize)], context: nil)
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
}

// MARK: - UserWasReported

extension ChatLogController: UserWasReported {
    
    func userWasReported(user: User) {
        
        let controller = ReportConfirmationView()
        controller.user = user
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        
        present(controller, animated: true, completion: nil)
    }
}

// MARK: - ChatAccessoryDelegate

extension ChatLogController: ChatAccessoryDelegate {
    
    func sendMessage(message: String) {
                
        sendMessageWith(string: message)
        
        chatAccessoryView.inputTextView.text = nil
        chatAccessoryView.inputTextView.placeholder = "Message \(firstname)"
        isTyping = false
        
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
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
            
            if self.messages.count == 0 {
                self.observeMessages()
                
            } else {
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    self.collectionView?.scrollToBottom()
                }
            }
        }
    }
}
