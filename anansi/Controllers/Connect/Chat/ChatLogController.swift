//
//  ChatLogController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 24/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import MobileCoreServices
import AVFoundation
import UIKit.UIGestureRecognizerSubclass

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var cameFromProfile: Bool = false
    
    private let cellIdentifier = "cell"
    
    override var canBecomeFirstResponder: Bool { return true }
    
    lazy var chatAccessoryView: ChatAccessoryView = {
        let cv = ChatAccessoryView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50.0))
        cv.chatLogController = self
        return cv
    }()
    
    override var inputAccessoryView: UIView {
        return chatAccessoryView
    }
    
    @objc func handleUploadTap() {
        
        self.chatAccessoryView.inputTextView.resignFirstResponder()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        
            let imagePickerController = UIImagePickerController()
            
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            //imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // refactor this
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let url = info[UIImagePickerControllerMediaURL] as? URL {
            
            let filename = NSUUID().uuidString + ".mov"
            let uploadTask = Storage.storage().reference().child("message_movies").child(filename).putFile(from: url, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed upload of video:", error!)
                    return
                }
                
                if let storageURL = metadata?.downloadURL()?.absoluteString {
                    //print(storageURL)
                    
                    if let thumbnailImage = self.thumbnailImageForVideoURL(fileURL: url) {
                        
                        // stuff here
                        self.uploadToFirebaseStorageUsingImage(image: thumbnailImage, completion: { (imageURL) in
                            
                            let properties: [String: Any] = ["imageURL": imageURL, "imageWidth": thumbnailImage.size.width, "imageHeight": thumbnailImage.size.height, "videoURL": storageURL]
                            self.sendMessageWithProperties(properties: properties)
                        })
                    }
                }
            })
            
            uploadTask.observe(.progress, handler: { (snapshot) in
                if let completedUnitCount = snapshot.progress?.completedUnitCount {
                    //self.navigationItem.title = String(completedUnitCount)
                    print(String(completedUnitCount))
                }
            })
            
            uploadTask.observe(.success, handler: { (snapshot) in
                self.navigationItem.title = self.user?.name // change this
            })
            
        } else {
         
            var selectedImageFromPicker: UIImage?
            
            if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                selectedImageFromPicker = editedImage
            } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                selectedImageFromPicker = originalImage
            }
            
            if let selectedImage = selectedImageFromPicker {
                uploadToFirebaseStorageUsingImage(image: selectedImage, completion: { (imageURL) in
                    self.sendMessageWithImageURL(imageURL: imageURL, image: selectedImage)
                })
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func thumbnailImageForVideoURL(fileURL: URL) -> UIImage? {
        
        let asset = AVAsset(url: fileURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            print(err)
        }
        
        return nil
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ url: String) -> Void) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image:", error!)
                    return
                }
                
                if let imageURL = metadata?.downloadURL()?.absoluteString {
                    completion(imageURL)
                }
                
            })
        }        
    }
    
    var messages = [Message]()
    
    var unreadMessages = [String]()
    
    var dateStamps = [String]()
    var previousTimestamp : NSNumber = 0
    
    var user: User? {
        didSet {
            observeMessages()
            
            let titleLabelView = UILabel()
            titleLabelView.text = user!.name
            titleLabelView.textColor = .secondary
            titleLabelView.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
            navigationItem.titleView = titleLabelView
        }
    }
    
    private func observeMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid, let toID = user?.id else { return }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toID)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageID = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageID)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }    
                let message = Message(dictionary: dictionary)

                if self.messages.isEmpty {
                    self.previousTimestamp = 0
                } else {
                    self.previousTimestamp = self.messages[self.messages.count - 1].timestamp!
                }
                
                let startTimestampDate = Date(timeIntervalSince1970: self.previousTimestamp.doubleValue)
                let endTimestampDate = Date(timeIntervalSince1970: message.timestamp!.doubleValue)
                let timeDate = self.createTimeString(dateFromMessageA: startTimestampDate, dateFromMessageB: endTimestampDate)
                self.dateStamps.append(timeDate)
                
                if uid == message.receiver, let isRead = message.isRead, !isRead {
                    self.unreadMessages.append(messageID)
                }
                
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    
                    self.collectionView?.scrollToBottom()
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarItems()

        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24.0, right: 0) // 88
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView?.keyboardDismissMode = .interactive
        
        setupKeyboardObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        observeTyping()
        
        for id in unreadMessages {
            Database.database().reference().child("messages").child(id).updateChildValues(["isRead": true])
        }
        unreadMessages.removeAll()
        
        // Automatically presents keyboard and scrolls to last message
        chatAccessoryView.inputTextView.becomeFirstResponder()
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Automatically hides keyboard
        chatAccessoryView.inputTextView.resignFirstResponder()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    var keyboardDidShow = false
    
    @objc func handleKeyboardDidShow() {
        
        keyboardDidShow = true
        /*if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }*/
    }
    
    @objc func handleKeyboardDidHide() {
        //keyboardDidShow = false
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        navigationController?.view.backgroundColor = .background
        navigationController?.navigationBar.isTranslucent = false
        
        // Adds custom leftBarButton
        let leftButton: UIButton = {
            let b = UIButton(type: .system)
            b.setImage(#imageLiteral(resourceName: "back").withRenderingMode(.alwaysTemplate), for: .normal)
            b.frame = CGRect(x: 0, y: 0, width: Const.navButtonHeight, height: Const.navButtonHeight)
            b.tintColor = .primary
            b.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
            return b
        }()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        
        // Adds custom rightBarButton
        let rightButton: UIButton = {
            let b = UIButton(type: .system)
            b.setImage(#imageLiteral(resourceName: "info").withRenderingMode(.alwaysTemplate), for: .normal)
            b.frame = CGRect(x: 0, y: 0, width: Const.navButtonHeight, height: Const.navButtonHeight)
            b.tintColor = .secondary
            b.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
            return b
        }()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
    }
    
    @objc func showActionSheet() {
        // TO DO: add other functionalities, like sharing contact, block user, etc
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tintColor = UIColor.init(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1.0) // Apple's blue?
        
        let contactDetails = UIAlertAction(title: "Contact details", style: .default, handler: { (action) -> Void in
        
            if self.cameFromProfile {
                
                self.navigationController?.popViewController(animated: true)
            } else {
                
                let controller = ProfileViewController()
                controller.user = self.user
                controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self.navigationController, action: nil)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        })
        alertController.addAction(contactDetails)
        
        /*let reportUser = UIAlertAction(title: "Report user", style: .destructive, handler: { (action) -> Void in
            print("Report user")
        })
        alertController.addAction(reportUser)*/
        
        let deleteChat = UIAlertAction(title: "Delete conversation", style: .destructive, handler: { (action) -> Void in
            
            guard let uid = NetworkManager.shared.getUID() else { return }
            
            if let userID = self.user?.id {
                
                let ref = Database.database().reference().child("user-messages").child(uid).child(userID)
                ref.removeValue(completionBlock: { (error, ref) in
                    
                    if error != nil {
                        print("Failed to delete message:", error!)
                        return
                    }
                    
                    self.navigationController?.popViewController(animated: true)
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
    }
    
    lazy var emptyStateView: ChatEmptyState = {
        let e = ChatEmptyState(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        e.chatLogController = self
        return e
    }()
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (messages.count == 0) {
            
            self.collectionView?.backgroundView = emptyStateView
        } else {
            self.collectionView?.backgroundView = nil
        }
        
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let message = messages[indexPath.item]
        cell.message = message
        
        let timeDate = dateStamps[indexPath.item]
        
        setupCell(cell: cell, message: message, date: timeDate)
        
        if let text = message.text {
            cell.bubbleViewWidthAnchor?.constant = estimateFrameForText(text: text).width + 28.0 // 28: safe margin?
            cell.textView.isHidden = false
            
        } else if message.imageURL != nil {
            cell.bubbleViewWidthAnchor?.constant = 240
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.videoURL == nil
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message, date: String) {
        
        if !date.isEmpty {
            
            cell.timeDate.text = date
            cell.timeDateHeightAnchor?.constant = Const.timeDateHeightChatCells
            cell.bubbleViewHeightAnchor?.constant = -Const.timeDateHeightChatCells
            
        } else {
            
            cell.timeDateHeightAnchor?.constant = 0.0
        }
        
        if message.sender == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = .primary
            cell.bubbleView.layer.borderColor = UIColor.primary.cgColor
            cell.textView.textColor = .background
            cell.playButton.tintColor = .primary
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            cell.bubbleView.backgroundColor = .background
            cell.bubbleView.layer.borderColor = UIColor.secondary.cgColor
            cell.textView.textColor = .secondary
            cell.playButton.tintColor = .secondary
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let text = message.text {
            
            cell.textView.text = text
            cell.messageImageView.isHidden = true
            
        } else if let messageImageURL = message.imageURL {
            
            cell.messageImageView.loadImageUsingCacheWithUrlString(messageImageURL)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
            cell.bubbleView.layer.borderWidth = 0
            
            if message.sender == Auth.auth().currentUser?.uid {
                
                cell.messageImageView.layer.borderColor = UIColor.primary.cgColor
                
            } else {
                
                cell.messageImageView.layer.borderColor = UIColor.secondary.cgColor
            }
            
        }
    }
    
    func createTimeString(dateFromMessageA: Date, dateFromMessageB: Date) -> String {
        
        let formatter = DateFormatter()
        var calendar = NSCalendar.current
        calendar.timeZone = NSTimeZone.local
        
        let now = Date()
        
        //let dateMessageB = calendar.dateComponents([.month, .day, .hour], from: dateFromMessageB, to: now)
        let fromMessageBtoDayOfMessageA = calendar.dateComponents([.month, .day], from: dateFromMessageB, to: calendar.startOfDay(for: dateFromMessageA))
        let fromDayOfMessageBtoNow = calendar.dateComponents([.day], from: calendar.startOfDay(for: dateFromMessageB), to: now)

        if fromMessageBtoDayOfMessageA.month! < 0 {
            formatter.dateFormat = "dd/MMM/yy, hh:mm a"
            
        } else if fromMessageBtoDayOfMessageA.day! < 0 {
            
            if fromDayOfMessageBtoNow.day! > 1 { //dateMessageB.day! >= 1 &&
                formatter.dateFormat = "E, hh:mm a"
                
            } else if fromDayOfMessageBtoNow.day! == 1 { //dateMessageB.day! <= 1 &&
                formatter.dateFormat = "'yesterday', hh:mm a"
                
            } else if fromDayOfMessageBtoNow.day! < 1 { //dateMessageB.day! < 1 {
                formatter.dateFormat = "'today', hh:mm a"
            }
 
        } else {
            formatter.dateFormat = ""
        }
        
        return formatter.string(from: dateFromMessageB as Date)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80.0 // dummy
        let message = messages[indexPath.item]
        
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 17 // 17: safe margin
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 240.0)
        }
                
        let timeDate = dateStamps[indexPath.item]
        if !timeDate.isEmpty {
            height += Const.timeDateHeightChatCells
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 224, height: 1000) // height arbitrarily high
        let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: Const.bodyFontSize)], context: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    @objc func handleSend() {
        
        let properties = ["text": chatAccessoryView.inputTextView.text!]
        sendMessageWithProperties(properties: properties)
        
        self.chatAccessoryView.inputTextView.text = nil
        self.chatAccessoryView.inputTextView.placeholder = "Type a message"
        self.isTyping = false
        
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    @objc func sendWave() {
        
        let properties = ["text": "👋"]
        sendMessageWithProperties(properties: properties)

    }
    
    private func sendMessageWithImageURL(imageURL: String, image: UIImage) {
        let properties : [String: Any] = ["imageURL": imageURL, "imageWidth": image.size.width, "imageHeight": image.size.height]
        sendMessageWithProperties(properties: properties)
    }
    
    
    private func sendMessageWithProperties(properties: [String: Any]) {
            
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        var values : [String: Any] = ["sender": Auth.auth().currentUser!.uid, "receiver": user!.id!, "timestamp": timestamp, "isRead": false,]
        properties.forEach({values[$0] = $1 as? NSObject})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            let messageID = childRef.key
            let userMessagesRef = Database.database().reference().child("user-messages").child(Auth.auth().currentUser!.uid).child(self.user!.id!)  //from: UID, to: USER.ID
            userMessagesRef.updateChildValues([messageID: true])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(self.user!.id!).child(Auth.auth().currentUser!.uid)
            recipientUserMessagesRef.updateChildValues([messageID: true])
            
        }
    }
    
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            let userRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("isSendingMessageTo")
            userRef.child(user!.id!).setValue(newValue)
        }
    }
    
    private func observeTyping() {
        
        let childRef = Database.database().reference().child("users").child(user!.id!).child("isSendingMessageTo")
        childRef.child(Auth.auth().currentUser!.uid).onDisconnectRemoveValue()
        
        let userTypingQuery = childRef.child(Auth.auth().currentUser!.uid)//.child(user!.id!)//.queryOrderedByValue()//.queryEqual(toValue: true)
        userTypingQuery.observe(.value) { (snapshot) in
            
            if !snapshot.exists() { return }
            
            if let value = snapshot.value {
                if value as! Bool {
                    
                    self.chatAccessoryView.isTypingBox.isHidden = false
                    self.chatAccessoryView.isTypingBox.text = self.user!.name! + " is typing..."
                    
                } else {
                    self.chatAccessoryView.isTypingBox.isHidden = true
                    self.chatAccessoryView.isTypingBox.text = ""
                }
            }

            //self.scrollToBottom(animated: true)
        }
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var imageView: UIImageView?
    var zoomedImage: UIImageView?
    var maxZoomSize: CGFloat = 1
    
    var closeButton: UIButton?
    var shareButton: UIButton?
    
    // my custom zooming logic
    func performZoomInForStartingImageView(imageView: UIImageView) {
        
        self.chatAccessoryView.inputTextView.resignFirstResponder()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        
            self.imageView = imageView
            self.imageView?.isHidden = true
            
            self.startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
            self.zoomedImage = UIImageView(frame: self.startingFrame!)
            self.zoomedImage?.image = imageView.image
            self.zoomedImage?.isUserInteractionEnabled = true
                        
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch))
            pinch.delegate = self
            self.zoomedImage?.addGestureRecognizer(pinch)
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan))
            pan.delegate = self
            self.zoomedImage?.addGestureRecognizer(pan)
            
            if let keyWindow = UIApplication.shared.keyWindow {
                
                keyWindow.makeKeyAndVisible()
                keyWindow.windowLevel = UIWindowLevelStatusBar
                
                self.blackBackgroundView = UIView(frame: keyWindow.frame)
                self.blackBackgroundView?.backgroundColor = .black
                self.blackBackgroundView?.alpha = 0
                keyWindow.addSubview(self.blackBackgroundView!)
                keyWindow.addSubview(self.zoomedImage!)
                
                self.closeButton = UIButton(frame: CGRect(x: keyWindow.frame.width - 64.0, y: 34.0, width: 56.0, height: 56.0))
                self.closeButton?.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)
                self.closeButton?.tintColor = .white
                self.closeButton?.alpha = 0
                self.closeButton?.addTarget(self, action: #selector(self.handleZoomOut), for: .touchUpInside)
                keyWindow.addSubview(self.closeButton!)
                
                self.shareButton = UIButton(frame: CGRect(x: keyWindow.frame.width - 64.0, y: keyWindow.frame.height - 84.0, width: 56.0, height: 56.0))
                self.shareButton?.setImage(#imageLiteral(resourceName: "share").withRenderingMode(.alwaysTemplate), for: .normal)
                self.shareButton?.tintColor = .white
                self.shareButton?.alpha = 0
                self.shareButton?.addTarget(self, action: #selector(self.handleShare), for: .touchUpInside)
                keyWindow.addSubview(self.shareButton!)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    
                    self.blackBackgroundView?.alpha = 1
                    self.closeButton?.alpha = 1
                    self.shareButton?.alpha = 1
                    self.inputAccessoryView.alpha = 0
                    
                    let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                    self.zoomedImage?.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                    self.zoomedImage?.center = keyWindow.center
                    self.originalImageCenter = keyWindow.center
                    
                    self.maxZoomSize = keyWindow.frame.height / height
                    
                }, completion: nil)
            }
        }
    }
    
    var isOkForPan = false
    var originalImageCenter: CGPoint?
    var newScale : CGFloat = 1.0
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func pan(sender: UIPanGestureRecognizer) {
        
        if let view = sender.view {

            if self.isOkForPan {
                
                let translation = sender.translation(in: view.superview)
                view.center = CGPoint(x:view.center.x + translation.x,
                                      y:view.center.y)
                sender.setTranslation(CGPoint.zero, in: view.superview)
                
                if sender.state == .ended {
                    
                    let minx = 0
                    let maxx = minx + Int((view.superview?.frame.size.width)!)
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        
                        if Int(view.frame.origin.x) > minx {
                            view.center.x = view.center.x - (view.frame.origin.x)
                        }
                        
                        if Int(view.frame.origin.x + view.frame.width) < maxx {
                            view.center.x = view.center.x + (CGFloat(maxx) - (view.frame.origin.x + view.frame.width))
                        }
                        
                    })
                }
            }
        }
    }
    
    
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        
        if let view = sender.view {
            
            let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                      y: sender.location(in: view).y - view.bounds.midY)
            
            let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: sender.scale, y: sender.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            
            let currentScale = view.frame.size.width / view.bounds.size.width
            newScale = currentScale * sender.scale
            
            view.transform = transform
            
            sender.scale = 1
            
            self.isOkForPan = true
            
            if sender.state == .ended {
                
                let generator = UISelectionFeedbackGenerator()
                
                guard let center = self.originalImageCenter else {return}
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    if self.newScale < 1 {
                        view.transform = CGAffineTransform.identity
                        view.center = center
                        self.isOkForPan = false
                        
                    } else if self.newScale > self.maxZoomSize {
                        
                        view.transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                            .scaledBy(x: self.maxZoomSize / self.newScale, y: self.maxZoomSize / self.newScale)
                            .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                        
                        view.frame.origin.y = 0
                    }
                }, completion: { _ in
                    generator.selectionChanged()
                })
            }
        }
    }
    
    @objc func handleZoomOut() {
        
        zoomedImage?.layer.cornerRadius = 16 / newScale
        zoomedImage?.clipsToBounds = true
        
        UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelNormal
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.zoomedImage?.frame = self.startingFrame!
            self.inputAccessoryView.alpha = 1
            self.blackBackgroundView?.alpha = 0
            self.shareButton?.alpha = 0
            self.closeButton?.alpha = 0
            
        }, completion: { (completed: Bool) in
            
            self.imageView?.isHidden = false
            self.zoomedImage?.removeFromSuperview()
            self.closeButton?.removeFromSuperview()
            self.shareButton?.removeFromSuperview()
            self.blackBackgroundView?.removeFromSuperview()
            
        })
    }
    
    @objc func handleShare(sender: UIButton) {
        
        handleZoomOut()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            if let sharingImage = self.imageView?.image {
                
                let activity = UIActivityViewController(activityItems: [sharingImage], applicationActivities: nil)
                activity.popoverPresentationController?.sourceView = sender
                
                self.present(activity, animated: true, completion: nil)
            }
        }
    }
}
