//
//  ProfileTableViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 13/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // Custom initializers
    let myID = NetworkManager.shared.getUID()
    
    let sections : [userInfoSection] = [.about, .tedTalk, .contactInfo]
    let fields : [userInfoSection : [userInfoType]] = [.about : [.bio, .interests],
                                                       .tedTalk : [.tedTitle],
                                                       .contactInfo : [.sharedEmail, .website, .linkedin],]
    var progressFields : [userInfoType] = []
    var activeField : userInfoType! = nil
    var currentIndexPath : IndexPath!
    
    var user: User? {
        didSet {
            
            if let profileImageURL = user?.getValue(forField: .profileImageURL) as? String {
                headerView.profileImage.setImage(with: profileImageURL)
                
                if !progressFields.contains(.profileImageURL) {
                    progressFields.append(.profileImageURL)
                    updateProgress(with: progressFields.count)
                }
                
            } else {
                headerView.profileImage.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
            }
            
            if let name = user?.getValue(forField: .name) as? String { headerView.setTitleName(name: name) }
            
            if let occupation = user?.getValue(forField: .occupation) as? String { headerView.setOccupation(occupation) }
            
            if let location = user?.getValue(forField: .location) as? String { headerView.setLocation("From " + location) }
            
            updateProgress(with: progressFields.count)
            tableView.reloadData()
        }
    }
    
    lazy var scrollView : UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.backgroundColor = .background
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView : UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // Cover
    lazy var backgroundImage: GradientView = {
        let v = GradientView()
        v.mask = UIImageView(image: UIImage(named: "cover-users")?.withRenderingMode(.alwaysTemplate))
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // Header
    lazy var headerView : ProfileHeader = {
        let hv = ProfileHeader()
        hv.setTitleColor(textColor: .secondary)
        hv.setBottomBorderColor(lineColor: .primary)
        hv.translatesAutoresizingMaskIntoConstraints = false
        return hv
    }()
    
    lazy var settingsButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(named: "settings")!.withRenderingMode(.alwaysTemplate), for: .normal)
        b.tintColor = .secondary
        b.backgroundColor = .background
        b.layer.cornerRadius = 16.0
        b.layer.masksToBounds = true
        b.addTarget(self, action: #selector(navigateToSettingsViewController), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // Achievement view
    lazy var achievementView: UIView = {
        let v = UIView()
        v.layer.borderWidth = 2
        v.layer.cornerRadius = Const.marginEight / 2.0
        v.layer.masksToBounds = true
        v.layer.borderColor = Const.progressColor[progressFields.count]!.cgColor
        v.layer.backgroundColor = UIColor.background.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var ratingIcon: UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: Const.badges[progressFields.count].lowercased())?.withRenderingMode(.alwaysOriginal)
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    lazy var titleAchievement: UILabel = {
        let l = UILabel()
        l.text = "Profile strength indicator"
        l.textColor = .secondary
        l.font = UIFont.boldSystemFont(ofSize: Const.calloutFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let privateToYouLabel: UILabel = {
        let l = UILabel()
        l.text = "Private to you"
        l.textColor = UIColor.init(red: 117/255.0, green: 117/255.0, blue: 117/255.0, alpha: 1.0)
        l.font = UIFont.systemFont(ofSize: Const.footnoteFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    lazy var progressLeftView: UIView = {
        let v = UIView()
        v.backgroundColor = Const.progressColor[progressFields.count]!.withAlphaComponent(0.25)
        v.layer.cornerRadius = 10
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var progressBarView: GradientView = {
        let v = GradientView()
        v.layer.borderWidth = 1.5
        v.layer.cornerRadius = 10
        v.clipsToBounds = true
        v.layer.borderColor = Const.progressColor[progressFields.count]!.cgColor
        v.layer.backgroundColor = Const.progressColor[progressFields.count]!.withAlphaComponent(0.05).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var checkIcon: UIImageView = {
        let i = UIImageView()
        i.image = #imageLiteral(resourceName: "check-progress").withRenderingMode(.alwaysTemplate)
        i.backgroundColor = .background
        i.layer.borderWidth = 2
        i.layer.cornerRadius = 16.0
        i.layer.masksToBounds = true
        i.tintColor = Const.progressColor[progressFields.count]!
        i.layer.borderColor = Const.progressColor[progressFields.count]!.cgColor
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    var checkIconLeadingAnchor: NSLayoutConstraint?
    
    // Table with profile data
    lazy var tableView : UIDynamicTableView = {
        let tv = UIDynamicTableView()
        tv.register(TextViewTableCell.self, forCellReuseIdentifier: "TextViewCell")
        tv.register(TextFieldTableCell.self, forCellReuseIdentifier: "TextFieldCell")
        tv.register(InterestProfileTableCell.self, forCellReuseIdentifier: "InterestTableCell")
        tv.register(InterestProfileEmptyTableCell.self, forCellReuseIdentifier: "InterestEmptyTableCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = false
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.allowsSelection = true
        tv.sectionHeaderHeight = 56.0
        tv.estimatedSectionHeaderHeight = 56.0
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 84
        return tv
    }()
    
    lazy var barHeight : CGFloat = (self.navigationController?.navigationBar.frame.height)!
    let statusBarHeight : CGFloat = UIApplication.shared.statusBarFrame.height
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // Fetches meeee!
        fetchMe()
        
        // Sets up UI
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [backgroundImage, headerView, settingsButton, achievementView, tableView].forEach { contentView.addSubview($0)}
        
        NSLayoutConstraint.activate([
            
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            backgroundImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -statusBarHeight),
            backgroundImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImage.heightAnchor.constraint(equalToConstant: 374.0),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Const.marginSafeArea),
            headerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 214.0),
            
            settingsButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Const.marginSafeArea),
            settingsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Const.marginSafeArea),
            settingsButton.widthAnchor.constraint(equalToConstant: 32.0),
            settingsButton.heightAnchor.constraint(equalToConstant: 32.0),
            
            achievementView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Const.marginSafeArea),
            achievementView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            achievementView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -Const.marginSafeArea * 2.0),
            achievementView.heightAnchor.constraint(equalToConstant: 112.0),

            tableView.topAnchor.constraint(equalTo: achievementView.bottomAnchor, constant: Const.marginEight),
            tableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24.0),
        ])
        
        // CALL-TO-ACTION VIEW
        
        [ratingIcon, titleAchievement, privateToYouLabel, progressBarView, progressLeftView, checkIcon].forEach { achievementView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            ratingIcon.topAnchor.constraint(equalTo: achievementView.topAnchor, constant: Const.marginSafeArea / 2.0),
            ratingIcon.trailingAnchor.constraint(equalTo: achievementView.trailingAnchor, constant: -Const.marginSafeArea / 2.0),
            ratingIcon.widthAnchor.constraint(equalToConstant: 44.0),
            ratingIcon.heightAnchor.constraint(equalToConstant: 44.0),
            
            titleAchievement.topAnchor.constraint(equalTo: achievementView.topAnchor, constant: Const.marginSafeArea / 2.0),
            titleAchievement.leadingAnchor.constraint(equalTo: achievementView.leadingAnchor, constant: Const.marginSafeArea / 2.0),
            titleAchievement.trailingAnchor.constraint(equalTo: ratingIcon.leadingAnchor, constant: -Const.marginSafeArea / 2.0),
            titleAchievement.heightAnchor.constraint(equalToConstant: 24.0),
            
            privateToYouLabel.topAnchor.constraint(equalTo: titleAchievement.bottomAnchor),
            privateToYouLabel.leadingAnchor.constraint(equalTo: achievementView.leadingAnchor, constant: Const.marginSafeArea / 2.0),
            privateToYouLabel.trailingAnchor.constraint(equalTo: ratingIcon.leadingAnchor, constant: -Const.marginSafeArea / 2.0),
            privateToYouLabel.heightAnchor.constraint(equalToConstant: 20.0),
            
            checkIcon.topAnchor.constraint(equalTo: ratingIcon.bottomAnchor, constant: Const.marginEight),
            checkIcon.widthAnchor.constraint(equalToConstant: 32.0),
            checkIcon.heightAnchor.constraint(equalToConstant: 32.0),
            
            progressBarView.centerYAnchor.constraint(equalTo: checkIcon.centerYAnchor),
            progressBarView.leadingAnchor.constraint(equalTo: achievementView.leadingAnchor, constant: Const.marginEight * 1.5),
            progressBarView.trailingAnchor.constraint(equalTo: achievementView.trailingAnchor, constant: -Const.marginEight * 1.5),
            progressBarView.heightAnchor.constraint(equalToConstant: 22.0),
            
            progressLeftView.centerYAnchor.constraint(equalTo: checkIcon.centerYAnchor),
            progressLeftView.centerXAnchor.constraint(equalTo: checkIcon.centerXAnchor),
            progressLeftView.leadingAnchor.constraint(equalTo: progressBarView.leadingAnchor),
            progressLeftView.trailingAnchor.constraint(equalTo: checkIcon.centerXAnchor),
            progressLeftView.heightAnchor.constraint(equalToConstant: 22.0),
        ])
        
        checkIconLeadingAnchor = checkIcon.leadingAnchor.constraint(equalTo: progressBarView.leadingAnchor)
        checkIconLeadingAnchor?.isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // I need dispatchQueue because I was getting EXC_BAD_ACCESS code (probably I was adding this when the view was not ready yet)
        DispatchQueue.main.async {
            
            // Sets gradients for backgroundImage and progressBarView
            self.backgroundImage.applyGradient(withColours: [.primary, .primary], gradientOrientation: .vertical)
        }
                
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationItem.titleView?.isHidden = true
        
        // Fetch meeee!
        fetchMe()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if !UserDefaults.standard.isProfileOnboarded() {
            
            // Presents bottom sheet
            let controller = BottomSheetView()
            controller.setContent(title: "Your Profile",
                                  description: "This is were your profile lives. Add info about yourself so other attendees can easily find and recognize you.")
            controller.setIcon(image: UIImage(named: "Profile")!.withRenderingMode(.alwaysTemplate))
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            present(controller, animated: true, completion: nil)
            
            // Sets CommunityOnboarded to true
            UserDefaults.standard.setProfileOnboarded(value: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewDidDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = ""
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Network
    
    private func fetchMe() {
        
        NetworkManager.shared.fetchUserOnce(userID: myID!) { (dictionary) in
            
            let me = User()
            me.set(dictionary: dictionary, id: self.myID!)
            self.user = me
            
            self.tableView.reloadData()
            
            self.updateProgress(with: self.progressFields.count)
        }
    }
    
    // MARK: Custom functions
    
    func updateProgress(with progress: Int) {
        
        let progress = progressFields.count
        
        if progress >= 0 && progress < 6 {
        
            let badge : String = Const.badges[progress]
            let color : UIColor = Const.progressColor[progress]!
            
            achievementView.layer.borderColor = color.cgColor
            
            progressBarView.layer.borderColor = color.cgColor
            progressBarView.layer.backgroundColor = color.withAlphaComponent(0.05).cgColor
            
            progressLeftView.layer.backgroundColor = color.withAlphaComponent(0.25).cgColor
            
            checkIcon.layer.borderColor = color.cgColor
            checkIcon.tintColor = color
            
            ratingIcon.image = UIImage(named: badge.lowercased())?.withRenderingMode(.alwaysOriginal)
            
            UIView.animate(withDuration: 0.3, animations: {
                // 104.0 = 48.0 (margins to view) + 24.0 (margins of progress bar) + 32.0 (width checkIcon)
                // + 1 because I'm using a LeadingAnchor, and I need to account for its width
                if progress <= 6 { self.checkIconLeadingAnchor?.constant = (CGFloat(progress) + 1) / 6 * (self.view.frame.width - 104.0)}
            })
        }
    }
    
    /*
    func estimateFrameForText(text: String, lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0, hyphenation: Float = 1.0, alignment: NSTextAlignment = .natural) -> CGRect {
        
        let size = CGSize(width: view.frame.width - Const.marginEight * 4.0, height: 1000) // height arbitrarily high
        let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.lineHeightMultiple = lineHeightMultiple
        style.hyphenationFactor = hyphenation
        style.alignment = alignment
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Const.bodyFontSize), NSAttributedString.Key.paragraphStyle: style], context: nil)
    }*/
    
    @objc func navigateToSettingsViewController(_ sender: UIBarButtonItem){
        
        let settingsController = SettingsViewController()
        settingsController.user = user
        
        let navController = UINavigationController(rootViewController: settingsController)
        navController.setNavigationBarHidden(false, animated: false)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func navigateToInterestsViewController() {
        
        let interests = user?.getValue(forField: .interests) as? [String] ?? []
        
        let interestController = InterestsViewController()
        interestController.hidesBottomBarWhenPushed = true
        interestController.selectedInterests = interests
        interestController.delegate = self
        
        let navController = UINavigationController(rootViewController: interestController)
        navController.setNavigationBarHidden(false, animated: false)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo,
            let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let keyboardHeight = keyboardEndFrame.height
        let screenHeight = view.frame.height
        let offset : CGFloat = 24.0
        
        print(activeField)
        
        if activeField != nil {
            
            var section : Int = 0, row : Int = 0
            for (sec, fieldList) in fields {
                if (fieldList.contains(activeField!)) {
                    section = sections.index(of: sec)!
                    row = fieldList.index(of: activeField!)!
                }
            }
            
            var cellMaxY : CGFloat
            if activeField == .bio {
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as! TextViewTableCell
                cellMaxY = cell.frame.maxY
                
            } else {
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as! TextFieldTableCell
                cellMaxY = cell.frame.maxY
            }

            let distanceToBottom = screenHeight - (cellMaxY + tableView.frame.origin.y - scrollView.contentOffset.y - statusBarHeight - offset)
            let collapseSpace = keyboardHeight - distanceToBottom
            
            if collapseSpace < 0 { return }
            scrollView.frame.origin.y -= collapseSpace
            view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.frame.origin.y = 0
            self.view.layoutIfNeeded()
        })
    }
    
}

// MARK: UITableViewDelegate

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionType = sections[section]
        return fields[sectionType]!.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let v : UIView =  {
            let v = UIView()
            v.backgroundColor = .clear
            return v
        }()
        
        let l : UILabel = {
            let l = UILabel()
            l.text = sections[section].rawValue
            l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
            l.textColor = .secondary
            l.translatesAutoresizingMaskIntoConstraints = false
            return l
        }()
        
        v.addSubview(l)
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .leading, relatedBy: .equal, toItem: v, attribute: .leading, multiplier: 1.0, constant: 24.0))
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .trailing, relatedBy: .equal, toItem: v, attribute: .trailing, multiplier: 1.0, constant: -24.0))
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .top, relatedBy: .equal, toItem: v, attribute: .top, multiplier: 1.0, constant: 24.0))
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .bottom, relatedBy: .equal, toItem: v, attribute: .bottom, multiplier: 1.0, constant: 0.0))
    
        return v
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionType = sections[indexPath.section]
        let field = (fields[sectionType]?[indexPath.row])!
        
        if field != .interests {
            
            let valueForField = user?.getValue(forField: field) as? String ?? ""
            let labelForField = User().label(forField: field) // Access label before user is set
            let placeholderForField = User().placeholder(forField: field) // Access placeholder before user is set
            
            if !valueForField.isEmpty {
                if !progressFields.contains(field) {
                    progressFields.append(field)
                    updateProgress(with: progressFields.count)
                }
            }
            
            if field == .bio {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as! TextViewTableCell
                cell.delegate = self
                cell.configureWithField(field: field, andValue: valueForField, withLabel: labelForField, withPlaceholder: placeholderForField)
                return cell
                
            } else {
        
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldTableCell
                cell.delegate = self
                cell.configureWithField(field: field, andValue: valueForField, withLabel: labelForField, withPlaceholder: placeholderForField)
                return cell
            }
            
        } else {
            
            if let interests : [String] = user?.getValue(forField: .interests) as? [String] {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "InterestTableCell", for: indexPath) as! InterestProfileTableCell
                
                cell.myInterests = interests.sorted()
                cell.delegate = self
                
                if !interests.isEmpty {
                    if !progressFields.contains(.interests) {
                        progressFields.append(.interests)
                        updateProgress(with: progressFields.count)
                    }
                }
                return cell
                
            } else {
             
                let cell = tableView.dequeueReusableCell(withIdentifier: "InterestEmptyTableCell", for: indexPath) as! InterestProfileEmptyTableCell
                cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.tertiary.withAlphaComponent(0.5))
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /*
        let sectionType = sections[indexPath.section]
        let field = (fields[sectionType]?[indexPath.row])!
        
        if field == .interests {
            navigateToInterestsViewController()
        }*/
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - TextFieldTableCellDelegate

extension ProfileViewController:  TextFieldTableCellDelegate {
    
    func field(field: userInfoType, changedValueTo value: String) {
        
        let uid = user?.getValue(forField: .id) as! String
        
        if !value.isEmpty {
            user?.setValue(value: value, for: field)
            NetworkManager.shared.register(value: value, for: field.rawValue, in: uid)
            
            if [.bio, .tedTitle, .sharedEmail, .website, .linkedin].contains(field) {
                
                if !progressFields.contains(field) {
                    progressFields.append(field)
                    updateProgress(with: progressFields.count)
                }
            }
            
        } else {
            user?.removeValue(for: field)
            NetworkManager.shared.removeData(field.rawValue)
            
            if [.bio, .tedTitle, .sharedEmail, .website, .linkedin].contains(field) {

                let removeFieldAtIndex = progressFields.index(of: field)
                progressFields.remove(at: removeFieldAtIndex!)
                updateProgress(with: progressFields.count)
            }
        }
        
        activeField = nil
        tableView.reloadData()
    }
    
    func fieldDidBeginEditing(field: userInfoType) {
        activeField = field
    }
    
    func fieldChangeForbidden(field: userInfoType) {
        // In case I need this for some reason
    }
}

// MARK: TextViewTableCellDelegate

extension ProfileViewController: TextViewTableCellDelegate {
    
    func didBeginEditingTextView(field: userInfoType) {
        activeField = field
    }
    
    func didChangeValueIn(field: userInfoType, to value: String) {
        
        let uid = user?.getValue(forField: .id) as! String
        
        if !value.isEmpty {
            user?.setValue(value: value, for: field)
            NetworkManager.shared.register(value: value, for: field.rawValue, in: uid)
            
            if !progressFields.contains(field) {
                progressFields.append(field)
                updateProgress(with: progressFields.count)
            }
            
        } else {
            user?.removeValue(for: field)
            NetworkManager.shared.removeData(field.rawValue)
            
            if let removeFieldAtIndex = progressFields.index(of: field) {
                progressFields.remove(at: removeFieldAtIndex)
            }
            updateProgress(with: progressFields.count)
        }
        
        activeField = nil
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

// MARK: InterestListDelegate

extension ProfileViewController: InterestListDelegate {
    
    func interestListWasSaved(list: [String]) {
                
        let sortedList = list.sorted()
        let uid = user?.getValue(forField: .id) as! String

        user?.setValue(value: sortedList, for: .interests)
        user?.saveInDisk(value: sortedList, for: .interests)
        NetworkManager.shared.register(value: sortedList, for: userInfoType.interests.rawValue, in: uid)
        
        if !list.isEmpty {
            if !progressFields.contains(.interests) {
                progressFields.append(.interests)
                updateProgress(with: progressFields.count)
            }
            
        } else {
            let removeFieldAtIndex = progressFields.index(of: .interests)
            if let index = removeFieldAtIndex {
                progressFields.remove(at: index)
                updateProgress(with: progressFields.count)
            }
        }        
    }
}

// MARK: InterestListDelegate

extension ProfileViewController: ShowsInterestSelectorDelegate {
    
    func didTapToShowInterestSelector() {
        navigateToInterestsViewController()
    }
}

// MARK: ScrollViewDidScroll function
    
extension ProfileViewController: UIScrollViewDelegate {
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let topDistance = barHeight + statusBarHeight
        let offsetY : CGFloat = scrollView.contentOffset.y
        
        // Zooms out image when scrolled down
        if  offsetY + topDistance < 0 {
            let zoomRatio = (-(offsetY + topDistance) * 0.0065) + 1.0
            backgroundImage.transform = CGAffineTransform(scaleX: zoomRatio, y: zoomRatio)
            
        } else {
            backgroundImage.transform = CGAffineTransform.identity
        }
        backgroundImage.layoutIfNeeded()
    }
}
