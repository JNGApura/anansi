//
//  ReportAbuseController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 04/03/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

protocol UserWasReported {
    func userWasReported(user: User)
}

class ReportAbuseViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    // Custom initializers
    let abuseOptions = ["Inappropriate messages", "Feels like spam", "Other"] // "Inappropriate photos",
    let abuseOptionIcon = ["inappropriate-message", "robot", "edit"] //"inappropriate-photo",
    
    var delegate: UserWasReported?
    
    var user: User? {
        didSet {
            pageDescription.text = "Why are you reporting " + (user?.getValue(forField: .name) as? String)! + "?"
        }
    }
    
    // Navbar
    
    lazy var topbar: TopBar = {
        let b = TopBar()
        b.setTitle(name: "")
        b.backgroundColor = .background
        b.hidesBottomLine()
        b.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // View
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .background
        sv.delegate = self
        sv.isScrollEnabled = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let groupedView: UIView = {
        let u = UIView()
        u.translatesAutoresizingMaskIntoConstraints = false
        return u
    }()
    
    private let pageTitle: UILabel = {
        let l = UILabel()
        l.text = "Report abuse"
        l.textColor = .secondary
        l.numberOfLines = 0
        l.lineBreakMode = NSLineBreakMode.byWordWrapping
        l.font = UIFont.boldSystemFont(ofSize: Const.titleFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let pageDescription: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.lineBreakMode = NSLineBreakMode.byWordWrapping
        l.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private lazy var abuseOptionsTable: UITableView = {
        let t = UITableView()
        t.delegate = self
        t.dataSource = self
        t.register(UITableViewCell.self, forCellReuseIdentifier: "AbuseOptionsCell")
        t.isScrollEnabled = false
        t.separatorStyle = .none
        t.rowHeight = 56
        t.estimatedRowHeight = 56
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    private lazy var feedbackTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: Const.calloutFontSize)
        tv.backgroundColor = .background
        tv.layer.borderColor = UIColor.tertiary.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.textColor = UIColor.secondary.withAlphaComponent(0.6)
        tv.isEditable = true
        tv.isScrollEnabled = true
        tv.autocorrectionType = .no
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8) // top, left, bottom, right
        tv.isHidden = true
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    private var feedbackTextLabel = "Tell us what happened"
    
    private let firstButton : PrimaryButton = {
        let p = PrimaryButton()
        p.setTitle("Submit", for: .normal)
        p.alpha = 0.4
        p.isEnabled = false
        p.addTarget(self, action: #selector(submitFeedback), for: .touchUpInside)
        return p
    }()
    
    private let secondButton : TertiaryButton = {
        let p = TertiaryButton()
        p.setTitle("Cancel", for: .normal)
        p.addTarget(self, action: #selector(back), for: .touchUpInside)
        return p
    }()
    
    private let hiddenButton : TertiaryButton = {
        let p = TertiaryButton()
        p.setTitle("  Take me back", for: .normal)
        p.setImage(UIImage(named: "back")!.withRenderingMode(.alwaysTemplate), for: .normal)
        p.tintColor = .secondary
        p.addTarget(self, action: #selector(showFullTableView), for: .touchUpInside)
        p.isHidden = true
        return p
    }()

    private let buttonGroupView : UIView = {
        let bgv = UIView()
        bgv.translatesAutoresizingMaskIntoConstraints = false
        return bgv
    }()
    
    let statusBarHeight : CGFloat = UIApplication.shared.statusBarFrame.height
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        [topbar, scrollView].forEach { view.addSubview($0) }
        [groupedView, buttonGroupView].forEach { scrollView.addSubview($0) }
        [pageTitle, pageDescription, abuseOptionsTable, feedbackTextView].forEach { groupedView.addSubview($0) }
        [firstButton, secondButton, hiddenButton].forEach { buttonGroupView.addSubview($0) }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Creates keyboard-specific notification observers, so that we can track when the keyboard is presented or is hidden
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)

        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        topbar.setStatusBarHeight(with: statusBarHeight)
        topbar.setNavigationBarHeight(with: Const.barHeight)
        
        NSLayoutConstraint.activate([
            
            // Navbar
            
            topbar.topAnchor.constraint(equalTo: view.topAnchor),
            topbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topbar.heightAnchor.constraint(equalToConstant: Const.barHeight + statusBarHeight),
            
            // View
            
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: topbar.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            groupedView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: view.frame.size.height / 4),
            groupedView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            groupedView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            groupedView.heightAnchor.constraint(equalToConstant: 300.0),
            
            pageTitle.topAnchor.constraint(equalTo: groupedView.topAnchor),
            pageTitle.leadingAnchor.constraint(equalTo: groupedView.leadingAnchor, constant: Const.marginSafeArea),
            pageTitle.widthAnchor.constraint(equalTo: groupedView.widthAnchor, constant: -Const.marginSafeArea * 2.0),
            pageTitle.heightAnchor.constraint(equalToConstant: 28.0),
            
            pageDescription.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: 36.0),
            pageDescription.leadingAnchor.constraint(equalTo: groupedView.leadingAnchor, constant: Const.marginSafeArea),
            pageDescription.widthAnchor.constraint(equalTo: groupedView.widthAnchor, constant: -Const.marginSafeArea * 2.0),
            pageDescription.heightAnchor.constraint(equalToConstant: 28.0),
            
            abuseOptionsTable.topAnchor.constraint(equalTo: pageDescription.bottomAnchor, constant: 16.0),
            abuseOptionsTable.leadingAnchor.constraint(equalTo: groupedView.leadingAnchor, constant: 4.0),
            abuseOptionsTable.widthAnchor.constraint(equalTo: groupedView.widthAnchor, constant: -8.0),
            abuseOptionsTable.heightAnchor.constraint(equalToConstant: 56 * 4.0),
            
            feedbackTextView.topAnchor.constraint(equalTo: abuseOptionsTable.topAnchor, constant: 72.0),
            feedbackTextView.leadingAnchor.constraint(equalTo: groupedView.leadingAnchor, constant: 8.0),
            feedbackTextView.widthAnchor.constraint(equalTo: groupedView.widthAnchor, constant: -16.0),
            feedbackTextView.heightAnchor.constraint(equalToConstant: 72.0),
            
            buttonGroupView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Const.marginSafeArea * 1.25),
            buttonGroupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonGroupView.widthAnchor.constraint(equalToConstant: 246.0),
            buttonGroupView.heightAnchor.constraint(equalToConstant: 100.0),
            
            firstButton.topAnchor.constraint(equalTo: buttonGroupView.topAnchor),
            firstButton.centerXAnchor.constraint(equalTo: buttonGroupView.centerXAnchor),
            firstButton.widthAnchor.constraint(equalTo: buttonGroupView.widthAnchor),
            firstButton.heightAnchor.constraint(equalToConstant: 48.0),
            
            secondButton.topAnchor.constraint(equalTo: firstButton.bottomAnchor, constant: 4.0),
            secondButton.centerXAnchor.constraint(equalTo: buttonGroupView.centerXAnchor),
            secondButton.widthAnchor.constraint(equalTo: buttonGroupView.widthAnchor),
            secondButton.heightAnchor.constraint(equalToConstant: 48.0),
            
            hiddenButton.topAnchor.constraint(equalTo: firstButton.bottomAnchor, constant: 4.0),
            hiddenButton.centerXAnchor.constraint(equalTo: buttonGroupView.centerXAnchor),
            hiddenButton.widthAnchor.constraint(equalTo: buttonGroupView.widthAnchor),
            hiddenButton.heightAnchor.constraint(equalToConstant: 48.0),
        ])
    }
    
    // MARK: Custom functions
    
    @objc func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func submitFeedback(_ sender: UIButton){

        // Sends report to back-end
        let reason = abuseOptionsTable.cellForRow(at: lastSelection)?.textLabel?.text
        let myID = NetworkManager.shared.getUID()
        let guiltyID = user?.getValue(forField: .id) as? String
        
        // Timestamp
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let currentTime = formatter.string(from: Date())
        
        // Sends feedback to backend
        let message : [String:Any]
        if reason != "Other" {
            message = [ "guilty": guiltyID!, "motive": reason!, "time": currentTime, "user": myID!]
        } else {
            message = [ "guilty": guiltyID!, "motive": (feedbackTextView.text)!, "time": currentTime, "user": myID!]
        }
        
        NetworkManager.shared.reportsUserWithMessage(post: message)
        NetworkManager.shared.register(value: currentTime, for: "blockedUsers/\(String(describing: guiltyID!))", in: myID!)
 
        // Returns to chatController
        delegate?.userWasReported(user: user!)
    }
    
    @objc func showFullTableView() {
        
        otherSelected = false
        abuseOptionsTable.reloadData()
        
        // Removes checkmark from other visible cells
        for cell in abuseOptionsTable.visibleCells {
            cell.accessoryType = .none
            cell.backgroundColor = .background
        }
        
        secondButton.isHidden = false
        hiddenButton.isHidden = true
        feedbackTextView.isHidden = true
    }
    
    // MARK: Keyboard-specific functions
    
    @objc func keyboardWillHide() {
        scrollView.transform = CGAffineTransform.identity
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            
            let textBoxRelativeMaxY = feedbackTextView.frame.maxY + groupedView.frame.origin.y + Const.barHeight + statusBarHeight
            let screenHeight = view.frame.height
            
            let offsetY = (screenHeight - textBoxRelativeMaxY - 16)
            
            if offsetY < keyboardHeight {
                scrollView.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight - offsetY))
                view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !otherSelected {
            return abuseOptions.count
        } else {
            return 1
        }
    }
    
    var otherSelected = false
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AbuseOptionsCell", for: indexPath)
        
        var row = indexPath.row
        if otherSelected {
            row = abuseOptions.count - 1
            cell.backgroundColor = .tertiary
            cell.accessoryType = .checkmark
        }
        
        cell.textLabel?.text = abuseOptions[row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        cell.imageView?.image = UIImage(named: abuseOptionIcon[row])?.withRenderingMode(.alwaysTemplate)
        cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.tertiary.withAlphaComponent(0.5))

        return cell
    }
    
    var lastSelection : IndexPath!
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath)
        
        if lastSelection != nil {
            cell?.accessoryType = .none
        }

        // Removes checkmark from other visible cells
        for c in tableView.visibleCells {
            
            if cell != c {
                c.accessoryType = .none
                c.backgroundColor = .background
            } else {
                
                cell?.accessoryType = .checkmark
                cell?.backgroundColor = .tertiary
                lastSelection = indexPath
            }
        }
        
        // Enables submit button, reloads table with only other (if chosen)
        if tableView.visibleCells.count != 1 && indexPath.row != abuseOptions.count - 1 {
            
            firstButton.isEnabled = true
            firstButton.alpha = 1.0
            
            otherSelected = false
            tableView.reloadData()
            
            hiddenButton.isHidden = true
            feedbackTextView.isHidden = true
            secondButton.isHidden = false
        } else {
            
            firstButton.isEnabled = false
            firstButton.alpha = 0.4
            
            otherSelected = true
            UIView.animate(withDuration: 0.3) {
                tableView.reloadData()
            }
            
            lastSelection.row = 0
            
            secondButton.isHidden = true
            hiddenButton.isHidden = false
            feedbackTextView.isHidden = false
            feedbackTextView.becomeFirstResponder()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: TextViewDelegate functions

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let prospectiveText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let textLength = prospectiveText.count
        
        // Enables button when length > 2
        if textLength > 2 {
            
            firstButton.isEnabled = true
            firstButton.alpha = 1
        } else {
            
            firstButton.isEnabled = false
            firstButton.alpha = 0.4
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if (textView.text == "") {
            textView.text = feedbackTextLabel
        }
        textView.textColor = .secondary
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if (textView.text == "" || textView.text == feedbackTextLabel) {
            textView.text = feedbackTextLabel
            textView.textColor = UIColor.secondary.withAlphaComponent(0.6)
        }
    }
}
