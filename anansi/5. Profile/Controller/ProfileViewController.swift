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
    
    var estimatedHeightForTextView : CGFloat? = nil
    
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
    
    // View
    
    lazy var scrollView : UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.backgroundColor = .background
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView : UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    lazy var buttonListBackground: UIView = {
        let l = UIView()
        l.layer.cornerRadius = 17.0
        l.clipsToBounds = true
        l.backgroundColor = .background
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    // Nav bar
    
    var previousAlpha : CGFloat = 0.0
    
    lazy var topbar: TopBar = {
        let b = TopBar()
        b.setTitle(name: "Profile")
        b.backgroundColor = .clear
        b.setModalStyle()
        b.alpha(with: 0)
        b.actionButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        b.setActionButton(with: UIImage(named: "close")!.withRenderingMode(.alwaysTemplate))
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    lazy var settingsButton: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named: "settings")!.withRenderingMode(.alwaysTemplate), for: .normal)
        b.contentMode = .scaleAspectFit
        b.tintColor = .secondary
        b.backgroundColor = UIColor.tertiary.withAlphaComponent(0.4)
        b.layer.cornerRadius = 16.0
        b.layer.masksToBounds = true
        b.addTarget(self, action: #selector(navigateToSettingsViewController), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let statusBarHeight : CGFloat = UIApplication.shared.statusBarFrame.height
    
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
        i.image = UIImage(named: "check-progress")!.withRenderingMode(.alwaysTemplate)
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
        tv.sectionHeaderHeight = UITableView.automaticDimension
        tv.estimatedSectionHeaderHeight = 56.0
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 84
        return tv
    }()
    
    // Tap to dismiss keyboard
    lazy var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation bar is hidden for the entire stack!
        navigationController?.navigationBar.isHidden = true
        
        view.backgroundColor = .background
        
        // Fetches meeee!
        fetchMe()
        
        // Sets up UI
        [scrollView, topbar, settingsButton].forEach { view.addSubview($0) }
        scrollView.addSubview(contentView)
        [backgroundImage, headerView, achievementView, tableView].forEach { contentView.addSubview($0)}
        
        [ratingIcon, titleAchievement, privateToYouLabel, progressBarView, progressLeftView, checkIcon].forEach { achievementView.addSubview($0) }
        
        // This needs to happen when view loads
        checkIconLeadingAnchor = checkIcon.leadingAnchor.constraint(equalTo: progressBarView.leadingAnchor)
        checkIconLeadingAnchor?.isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !userDefaults.bool(for: userDefaults.isProfileOnboarded) {
            
            // Presents bottom sheet
            let controller = BottomSheetView(title: "Your Profile", description: "This is were your profile lives. Add info about yourself so other attendees can easily find and recognize you.", image: UIImage(named: "Profile")!.withRenderingMode(.alwaysTemplate))
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            present(controller, animated: true, completion: nil)
            
            // Sets CommunityOnboarded to true
            userDefaults.updateObject(for: userDefaults.isProfileOnboarded, with: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topbar.setLargerBackButton()
        topbar.setStatusBarHeight(with: statusBarHeight)
        topbar.setNavigationBarHeight(with: Const.barHeight)
        
        NSLayoutConstraint.activate([
            
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            backgroundImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImage.heightAnchor.constraint(equalToConstant: 374.0),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: statusBarHeight),
            headerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 214.0),
            
            achievementView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Const.marginSafeArea),
            achievementView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            achievementView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -Const.marginSafeArea * 2.0),
            achievementView.heightAnchor.constraint(equalToConstant: 112.0),
            
            tableView.topAnchor.constraint(equalTo: achievementView.bottomAnchor, constant: Const.marginEight),
            tableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // STATUS & NAVIGATION BAR
            
            topbar.topAnchor.constraint(equalTo: view.topAnchor),
            topbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topbar.heightAnchor.constraint(equalToConstant: Const.barHeight + statusBarHeight),
            
            settingsButton.centerYAnchor.constraint(equalTo: topbar.navigationbar.centerYAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: topbar.actionButton.leadingAnchor, constant: -Const.marginEight * 2.0),
            settingsButton.heightAnchor.constraint(equalTo: settingsButton.widthAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 32.0),
            
            // CALL TO ACTION
            
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
        
        // I need dispatchQueue because I was getting EXC_BAD_ACCESS code (probably I was adding this when the view was not ready yet)
        DispatchQueue.main.async {
            
            // Sets gradients for backgroundImage and progressBarView
            self.backgroundImage.applyGradient(withColours: [.primary, .primary], gradientOrientation: .vertical)
        }
        
        tableView.reloadData()
    }
    
    // MARK: Network
    
    private func fetchMe() {
        
        NetworkManager.shared.fetchUserOnce(userID: myID!) { (dictionary) in
            
            // Gets me!
            let me = User()
            me.set(dictionary: dictionary, id: self.myID!)
            self.user = me
            
            // If interests are NOT on disk, save them
            if (userDefaults.stringList(for: userInfoType.interests.rawValue) == nil) {
                
                if let interests = me.getValue(forField: .interests) as? [String] {
                    me.saveInDisk(value: interests, for: .interests)
                }
            }
            
            // If profile image is NOT on disk, save it
            if (userDefaults.string(for: userInfoType.profileImageURL.rawValue) == nil) {
                
                if let profileImageURL = me.getValue(forField: .profileImageURL) as? String {
                    me.saveInDisk(value: profileImageURL, for: .profileImageURL)
                }
            }

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
    
    @objc func dismissViewController() {

        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func navigateToSettingsViewController(_ sender: UIBarButtonItem){
        
        let settingsController = SettingsViewController()
        settingsController.user = user

        view.endEditing(true)
        navigationController?.pushViewController(settingsController, animated: true)
    }
    
    @objc func navigateToInterestsViewController() {
        
        let interests = user?.getValue(forField: .interests) as? [String] ?? []

        let interestController = InterestsViewController()
        interestController.selectedInterests = interests
        interestController.delegate = self
        
        view.endEditing(true)
        navigationController?.pushViewController(interestController, animated: true)
    }
    
    var collapseSpace : CGFloat = 0
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo,
            let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let keyboardHeight = keyboardEndFrame.height
        
        if activeField != nil {
            
            var section : Int = 0, row : Int = 0
            for (sec, fieldList) in fields {
                if (fieldList.contains(activeField!)) {
                    section = sections.index(of: sec)!
                    row = fieldList.index(of: activeField!)!
                }
            }
            
            let cell = [.sharedEmail, .website, .linkedin].contains(activeField) ? tableView.cellForRow(at: IndexPath(row: row, section: section)) as! TextFieldTableCell :
                tableView.cellForRow(at: IndexPath(row: row, section: section)) as! TextViewTableCell
            
            let cellRealOrigin = tableView.convert(cell.frame.origin, to: self.view)
            let distanceCellKeyboard = keyboardHeight - (view.frame.maxY - (cell.frame.height + cellRealOrigin.y))
            
            if collapseSpace < 0 { return }
            
            collapseSpace = distanceCellKeyboard
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y + distanceCellKeyboard), animated: false)
            view.layoutIfNeeded()
            
            // Adds tapToDismissKeyboard gesture
            if view.gestureRecognizers == nil || (view.gestureRecognizers != nil && !view.gestureRecognizers!.contains(tap)) {
                view.addGestureRecognizer(tap)
            }
            
            //print(keyboardHeight)
            
            scrollView.isScrollEnabled = false
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentOffset.y - self.collapseSpace), animated: true)
            self.tableView.reloadData()
            self.view.layoutIfNeeded()
        })
        
        // Removes tapToDismissKeyboard gesture
        if view.gestureRecognizers != nil,
            view.gestureRecognizers!.contains(tap) {
            view.removeGestureRecognizer(tap)
        }
        
        collapseSpace = 0
        scrollView.isScrollEnabled = true
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
            
            if [.sharedEmail, .website, .linkedin].contains(field) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldTableCell
                cell.delegate = self
                cell.configureWithField(field: field, andValue: valueForField, withLabel: labelForField, withPlaceholder: placeholderForField)
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as! TextViewTableCell
                cell.delegate = self
                cell.configureWithField(field: field, andValue: valueForField, withLabel: labelForField, withPlaceholder: placeholderForField)
                return cell
            }

        } else {
            
            if let interests : [String] = user?.getValue(forField: .interests) as? [String] {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "InterestTableCell", for: indexPath) as! InterestProfileTableCell
                
                cell.selectionStyle = .none
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
                cell.selectionStyle = .none
                cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.tertiary.withAlphaComponent(0.5))
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionType = sections[indexPath.section]
        let field = (fields[sectionType]?[indexPath.row])!
        
        if field == .interests, (tableView.cellForRow(at: indexPath) as? InterestProfileEmptyTableCell != nil) {
            navigateToInterestsViewController()
        }
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
            NetworkManager.shared.removeData(field.rawValue, in: myID!)
            
            if [.bio, .tedTitle, .sharedEmail, .website, .linkedin].contains(field) {

                if progressFields.contains(field),
                    let removeFieldAtIndex = progressFields.index(of: field) {
                    progressFields.remove(at: removeFieldAtIndex)
                }
                updateProgress(with: progressFields.count)
            }
        }
        
        activeField = nil
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
    
    func didBeginEditingTextView(field: userInfoType, withHeight height: CGFloat) {
        activeField = field
        estimatedHeightForTextView = height
    }
    
    func didEndEditingTextView(field: userInfoType) {
        activeField = nil
        estimatedHeightForTextView = nil
        view.layoutIfNeeded()
    }
    
    func didChangeValueIn(field: userInfoType, to value: String, by height: CGFloat) {
        
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
            NetworkManager.shared.removeData(field.rawValue, in: myID!)
            
            if let removeFieldAtIndex = progressFields.index(of: field) {
                progressFields.remove(at: removeFieldAtIndex)
            }
            updateProgress(with: progressFields.count)
        }
        
        // Change scrollview's frame origin if there's a line change
        if estimatedHeightForTextView != height {
            
            UIView.animate(withDuration: 0.2, animations: {
                self.scrollView.frame.origin.y -= (height - self.estimatedHeightForTextView!)
                self.view.layoutIfNeeded()
            })
            
            estimatedHeightForTextView = height
        }
        
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
            
            if let removeFieldAtIndex = progressFields.index(of: .interests) {
                
                progressFields.remove(at: removeFieldAtIndex)
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
        
        let topDistance = statusBarHeight // + barHeight
        let offsetY : CGFloat = scrollView.contentOffset.y
        
        // Zooms out image when scrolled down
        if  offsetY + topDistance < 0 {
            let zoomRatio = (-(offsetY + topDistance) * 0.0065) + 1.0
            backgroundImage.transform = CGAffineTransform(scaleX: zoomRatio, y: zoomRatio)
            
            topbar.alpha(with: 0.0)
            
        } else {
            
            let delta = headerView.profileImage.frame.maxY == 0.0 ? 1.0 : (headerView.profileImage.frame.maxY - (offsetY + topDistance)) / headerView.profileImage.frame.maxY
            let alpha = delta <= 1.0 ? 1.0 - delta : 1.0
                
            topbar.alpha(with: alpha)
            
            backgroundImage.transform = CGAffineTransform.identity
        }
        
        backgroundImage.layoutIfNeeded()
    }
}
