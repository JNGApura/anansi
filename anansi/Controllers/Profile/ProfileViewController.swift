//
//  ProfileTableViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 13/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UserSaveDelegate {
    
    // Custom initializers

    let myID = NetworkManager.shared.getUID()
    
    var sections = [String]()
    var sectionDataToDisplay = [Int : [String]]()
    var iconForContactSection = [String]()
    var gradientColors = [UIColor]()
    
    var userInterests = [String]()
    var myInterests = [String]()
    
    var progress: Int = 0
    
    var user: User? {
        didSet {
            
            sections.removeAll()
            sectionDataToDisplay.removeAll()
            iconForContactSection.removeAll()

            progress = 0
            
            if let profileImageURL = user?.profileImageURL {
                
                headerView.profileImage.loadImageUsingCacheWithUrlString(profileImageURL)
                
                if (user?.id == myID) { updateProgress() }

            } else {
                
                headerView.profileImage.image = #imageLiteral(resourceName: "profileImageTemplate").withRenderingMode(.alwaysOriginal)
            }
            
            if let name = user?.name {
                
                if user?.id == myID {
                    
                    headerView.setTitleName(name: "You")
                } else {
                    
                    headerView.setTitleName(name: name)
                }
            }
            
            if let occupation = user?.occupation {
                
                headerView.setOccupation(occupation)
            }
            
            if let location = user?.location {
                
                headerView.setLocation(location)
            }
            
            if let option = user?.gradientColor {
                
                gradientColors = Const.colorGradient[option]!
                backgroundImage.gradient.colors = [gradientColors[0].cgColor, gradientColors[1].cgColor]
            }
            
            if let bio = user?.bio {
                
                sections.append("Short biography:")
                let index = sections.count - 1
                sectionDataToDisplay[index] = [bio]
                
                if (user?.id == myID) { updateProgress() }
            }
            
            if let interests = user?.interests {
                
                sections.append("Talk to me about:")
                let index = sections.count - 1
                sectionDataToDisplay[index] = ["interests are presented here"]
                userInterests = interests.sorted()

                if (user?.id == myID) {
                    updateProgress()
                    myInterests = userInterests
                }
            }
            
            if let title = user?.TEDtitle, let speaker = user?.TEDspeaker {
                
                sections.append("My favorite TED talk:")
                let index = sections.count - 1
                sectionDataToDisplay[index] = [title, speaker]
                
                if (user?.id == myID) { updateProgress() }
            }

            if let email = user?.sharedEmail {
                
                if !sections.contains("Let's keep in touch:") {
                    
                    sections.append("Let's keep in touch:")
                    if (user?.id == myID) { updateProgress() }
                }
                
                let index = sections.count - 1
                
                if sectionDataToDisplay[index] == nil {
                    
                    sectionDataToDisplay[index] = [email]
                } else {
                    
                    sectionDataToDisplay[index]?.append(email)
                }
                
                iconForContactSection.append("email")
            }
            
            if let website = user?.website {
                
                if !sections.contains("Let's keep in touch:") {
                    
                    sections.append("Let's keep in touch:")
                    if (user?.id == myID) { updateProgress() }
                }
                
                let index = sections.count - 1
                
                if sectionDataToDisplay[index] == nil {
                    
                    sectionDataToDisplay[index] = [website]
                } else {
                    
                    sectionDataToDisplay[index]?.append(website)
                }
                
                iconForContactSection.append("website")
            }
            
            if let linkedin = user?.linkedin {
                
                if !sections.contains("Let's keep in touch:") {
                    
                    sections.append("Let's keep in touch:")
                    if (user?.id == myID) { updateProgress() }
                }
                
                let index = sections.count - 1
                
                if sectionDataToDisplay[index] == nil {
                    
                    sectionDataToDisplay[index] = [linkedin]
                } else {
                    
                    sectionDataToDisplay[index]?.append(linkedin)
                }
                
                iconForContactSection.append("linkedin-black")
            }
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
    let mask = UIImageView(image: #imageLiteral(resourceName: "Mesh").withRenderingMode(.alwaysTemplate))
    
    lazy var backgroundImage: GradientView = {
        let v = GradientView()
        v.mask = mask
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
    
    // Call-to-action view
    let callToActionView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    var callToActionViewHeightAnchor: NSLayoutConstraint?
    
    lazy var achievementsView: UIView = {
        let v = UIView()
        v.layer.borderWidth = 2
        v.layer.cornerRadius = Const.marginEight / 2.0
        v.layer.masksToBounds = true
        v.layer.borderColor = Const.progressColor[progress]!.cgColor
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var ratingIcon: UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: Const.badges[progress].lowercased())?.withRenderingMode(.alwaysOriginal)
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    lazy var ratingLabel: UILabel = {
        let l = UILabel()
        l.text = Const.badges[progress]
        l.textColor = .secondary
        l.font = UIFont.boldSystemFont(ofSize: Const.calloutFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    lazy var descriptionLabel: UILabel = {
        let l = UILabel()
        l.text = Const.progressMap[progress]
        l.textColor = UIColor.secondary.withAlphaComponent(0.6)
        l.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let achievedLabel: UILabel = {
        let l = UILabel()
        l.text = "Achieved"
        l.textColor = UIColor.init(red: 117/255.0, green: 117/255.0, blue: 117/255.0, alpha: 1.0)
        l.font = UIFont.systemFont(ofSize: Const.footnoteFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let privateToYouLabel: UILabel = {
        let l = UILabel()
        l.text = "Private to you"
        l.textColor = UIColor.init(red: 117/255.0, green: 117/255.0, blue: 117/255.0, alpha: 1.0)
        l.font = UIFont.systemFont(ofSize: Const.footnoteFontSize)
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let progressLeftView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.background.withAlphaComponent(0.8)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var progressBarView: GradientView = {
        let v = GradientView()
        v.layer.borderWidth = 1.5
        v.layer.cornerRadius = 10
        v.layer.masksToBounds = true
        v.layer.borderColor = Const.progressColor[progress]!.cgColor
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
        i.tintColor = Const.progressColor[progress]!
        i.layer.borderColor = Const.progressColor[progress]!.cgColor
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    var checkIconLeadingAnchor: NSLayoutConstraint?
    
    // Say hi! button
    let newChatButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("  Say hi!", for: .normal)
        b.setImage(#imageLiteral(resourceName: "new_message").withRenderingMode(.alwaysTemplate), for: .normal)
        b.tintColor = .background
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.cornerRadius = 20
        b.layer.masksToBounds = true
        b.addTarget(self, action: #selector(showChatLogController), for: .touchUpInside)
        b.isHidden = true
        return b
    }()
    
    // Table with profile data
    lazy var tableView : UIDynamicTableView = {
        let tv = UIDynamicTableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "ProfileCell")
        tv.register(InterestTableCell.self, forCellReuseIdentifier: "InterestTableCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = false
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.allowsSelection = true
        tv.sectionHeaderHeight = 56.0
        tv.estimatedSectionHeaderHeight = 56.0
        tv.estimatedRowHeight = 44.0
        tv.rowHeight = UITableViewAutomaticDimension
        return tv
    }()
    
    lazy var barHeight : CGFloat = (self.navigationController?.navigationBar.frame.height)!
    let statusBarHeight : CGFloat = UIApplication.shared.statusBarFrame.height
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetches user
        fetchUser()
        
        // Sets up UI
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [backgroundImage, headerView, callToActionView, tableView].forEach { contentView.addSubview($0)}
        
        NSLayoutConstraint.activate([
            
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            backgroundImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -(barHeight + statusBarHeight)),
            backgroundImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImage.heightAnchor.constraint(equalToConstant: 318.0),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 234.0),
            
            callToActionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            callToActionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            callToActionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: callToActionView.bottomAnchor),
            tableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24.0)
        ])
        
        callToActionViewHeightAnchor = callToActionView.heightAnchor.constraint(equalToConstant: 0.0)
        callToActionViewHeightAnchor?.isActive = true
        
        // CALL-TO-ACTION VIEW
        
        [achievementsView, newChatButton].forEach { callToActionView.addSubview($0) }
        [ratingIcon, ratingLabel, privateToYouLabel, achievedLabel, descriptionLabel, progressBarView, progressLeftView, checkIcon].forEach { achievementsView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            achievementsView.topAnchor.constraint(equalTo: callToActionView.topAnchor, constant: Const.marginEight),
            achievementsView.leadingAnchor.constraint(equalTo: callToActionView.leadingAnchor, constant: Const.marginEight * 2.0),
            achievementsView.trailingAnchor.constraint(equalTo: callToActionView.trailingAnchor, constant: -Const.marginEight * 2.0),
            achievementsView.bottomAnchor.constraint(equalTo: callToActionView.bottomAnchor, constant: -Const.marginEight),

            ratingIcon.topAnchor.constraint(equalTo: achievementsView.topAnchor, constant: Const.marginEight * 1.5),
            ratingIcon.leadingAnchor.constraint(equalTo: achievementsView.leadingAnchor, constant: Const.marginEight * 1.5),
            ratingIcon.widthAnchor.constraint(equalToConstant: 44.0),
            ratingIcon.heightAnchor.constraint(equalToConstant: 44.0),
            
            ratingLabel.topAnchor.constraint(equalTo: achievementsView.topAnchor, constant: Const.marginEight * 1.5),
            ratingLabel.leadingAnchor.constraint(equalTo: ratingIcon.trailingAnchor, constant: Const.marginEight),
            ratingLabel.trailingAnchor.constraint(equalTo: privateToYouLabel.leadingAnchor),
            ratingLabel.heightAnchor.constraint(equalToConstant: 24.0),
            
            privateToYouLabel.topAnchor.constraint(equalTo: achievementsView.topAnchor, constant: Const.marginEight * 1.5),
            privateToYouLabel.trailingAnchor.constraint(equalTo: achievementsView.trailingAnchor, constant: -Const.marginEight * 1.5),
            privateToYouLabel.widthAnchor.constraint(equalToConstant: 88.0),
            privateToYouLabel.heightAnchor.constraint(equalToConstant: 22.0),
            
            achievedLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor),
            achievedLabel.leadingAnchor.constraint(equalTo: ratingIcon.trailingAnchor, constant: Const.marginEight),
            achievedLabel.trailingAnchor.constraint(equalTo: achievementsView.trailingAnchor, constant: -Const.marginEight * 1.5),
            achievedLabel.heightAnchor.constraint(equalToConstant: 20.0),
            
            descriptionLabel.topAnchor.constraint(equalTo: achievedLabel.bottomAnchor, constant: Const.marginEight * 1.5),
            descriptionLabel.leadingAnchor.constraint(equalTo: achievementsView.leadingAnchor, constant: Const.marginEight * 1.5),
            descriptionLabel.trailingAnchor.constraint(equalTo: achievementsView.trailingAnchor, constant: -Const.marginEight * 1.5),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 44.0),
            
            checkIcon.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Const.marginEight * 2.0),
            checkIcon.widthAnchor.constraint(equalToConstant: 32.0),
            checkIcon.heightAnchor.constraint(equalToConstant: 32.0),
            
            progressBarView.centerYAnchor.constraint(equalTo: checkIcon.centerYAnchor),
            progressBarView.leadingAnchor.constraint(equalTo: achievementsView.leadingAnchor, constant: Const.marginEight * 1.5),
            progressBarView.trailingAnchor.constraint(equalTo: achievementsView.trailingAnchor, constant: -Const.marginEight * 1.5),
            progressBarView.heightAnchor.constraint(equalToConstant: 22.0),
            
            progressLeftView.centerYAnchor.constraint(equalTo: checkIcon.centerYAnchor),
            progressLeftView.leadingAnchor.constraint(equalTo: checkIcon.centerXAnchor),
            progressLeftView.trailingAnchor.constraint(equalTo: progressBarView.trailingAnchor),
            progressLeftView.heightAnchor.constraint(equalToConstant: 22.0),
            
            // NewChatButton
            newChatButton.centerXAnchor.constraint(equalTo: callToActionView.centerXAnchor),
            newChatButton.centerYAnchor.constraint(equalTo: callToActionView.centerYAnchor),
            newChatButton.heightAnchor.constraint(equalToConstant: 40.0),
            newChatButton.widthAnchor.constraint(equalToConstant: 132.0),
        ])

        checkIconLeadingAnchor = checkIcon.leadingAnchor.constraint(equalTo: progressBarView.leadingAnchor)
        checkIconLeadingAnchor?.isActive = true
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // I need dispatchQueue because I was getting EXC_BAD_ACCESS code (probably I was adding this when the view was not ready yet)
        DispatchQueue.main.async {
            
            // Sets gradients for backgroundImage and progressBarView
            if !self.gradientColors.isEmpty {
                self.backgroundImage.applyGradient(withColours: [self.gradientColors[0], self.gradientColors[1]], gradientOrientation: .topLeftBottomRight)
            }
            
            let color : UIColor = Const.progressColor[self.progress]!
            self.progressBarView.applyGradient(withColours: [color.withAlphaComponent(0.1), color], gradientOrientation: .horizontal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Sets Nav bar to translucent
        navigationController?.navigationBar.isTranslucent = true
        
        // Fetch user!
        fetchUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.titleView?.isHidden = false
        navigationItem.titleView?.alpha = 0.0
        
        if !UserDefaults.standard.isProfileOnboarded() {
            
            // Presents bottom sheet
            let controller = BottomSheetView()
            controller.setContent(title: "Your Profile",
                                  description: "This is were your profile lives. Add info about yourself so other attendees can easily find and recognize you.")
            controller.setIcon(image: #imageLiteral(resourceName: "Profile_filled").withRenderingMode(.alwaysTemplate))
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            present(controller, animated: true, completion: nil)
            
            // Sets CommunityOnboarded to true
            UserDefaults.standard.setProfileOnboarded(value: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewDidDisappear(animated)
        navigationItem.titleView?.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    // Sets up call-to-action view
    func createCallToActionView() {
        
        if user?.id == myID  {
            
            callToActionViewHeightAnchor?.constant = 188.0
            
            achievementsView.isHidden = false
            newChatButton.isHidden = true
            
            checkIconLeadingAnchor?.constant = (CGFloat(progress) + 1) / 6 * ((view.frame.width - 32.0 - 24.0) - 32.0)
            
        } else {
            
            callToActionViewHeightAnchor?.constant = 56.0
            
            newChatButton.isHidden = false
            achievementsView.isHidden = true
        }
    }
    
    // Sets up navigation bar
    func setupNavigationBarItems() {
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .background
        
        navigationItem.title = ""

        if user?.id == myID  {
            
            let settingsButton: UIButton = {
                let button = UIButton(type: .system)
                button.setImage(#imageLiteral(resourceName: "settings").withRenderingMode(.alwaysTemplate), for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: Const.navButtonHeight, height: Const.navButtonHeight)
                button.tintColor = .secondary
                button.backgroundColor = .background
                button.layer.cornerRadius = Const.navButtonHeight / 2.0
                button.layer.masksToBounds = true
                button.addTarget(self, action: #selector(navigateToSettingsViewController), for: .touchUpInside)
                return button
            }()
            
            let editButton: UIButton = {
                let button = UIButton(type: .system)
                button.setImage(#imageLiteral(resourceName: "edit").withRenderingMode(.alwaysTemplate), for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: Const.navButtonHeight, height: Const.navButtonHeight)
                button.tintColor = .secondary
                button.backgroundColor = .background
                button.layer.cornerRadius = Const.navButtonHeight / 2.0
                button.layer.masksToBounds = true
                button.addTarget(self, action: #selector(navigateToEditProfileViewController), for: .touchUpInside)
                return button
            }()
            
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: editButton), UIBarButtonItem(customView: settingsButton)]
        } else {
            
            let backButton: UIButton = {
                let button = UIButton(type: .system)
                button.setImage(#imageLiteral(resourceName: "back").withRenderingMode(.alwaysTemplate), for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: Const.navButtonHeight, height: Const.navButtonHeight)
                button.tintColor = .primary
                button.backgroundColor = .background
                button.layer.cornerRadius = Const.navButtonHeight / 2.0
                button.layer.masksToBounds = true
                button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
                return button
            }()
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        }
    }
    
    // MARK: Network
    
    private func fetchUser() {
        
        if let id = user?.id, id != myID {
            
            print("id != myID, let's show his/her profile")
            NetworkManager.shared.fetchUser(userID: id) { (dictionary) in
                self.user = User(dictionary: dictionary, id: id)
            }
            
        } else {
            
            if user == nil {
                
                print("id == myID & user is nil, so it's ME time!")
                NetworkManager.shared.fetchUser(userID: myID!) { (dictionary) in
                    self.user = User(dictionary: dictionary, id: self.myID!)
                }
            } else {
                
                print("id == myID, but I've came from the editViewController yey!")
            }
        }
        
        // Sets up call-to-action view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            self.tableView.reloadData()
            
            UIView.animate(withDuration: 0.3, animations: {
                self.checkIconLeadingAnchor?.constant = (CGFloat(self.progress) + 1) / 6 * ((self.view.frame.width - 88.0)) // 32.0 (margins to view) + 24.0 (margins of progress bar) + 32.0 (width checkIcon)
                self.view.layoutIfNeeded()
            })
            
            self.setupNavigationBarItems()
            
            self.createCallToActionView()
        }
    }
    
    // MARK: Custom functions
    
    func updateProgress() {
        
        progress += 1
        
        let badge : String = Const.badges[progress]
        let color : UIColor = Const.progressColor[progress]!
        
        achievementsView.layer.borderColor = color.cgColor
        
        progressBarView.layer.borderColor = color.cgColor
        
        checkIcon.layer.borderColor = color.cgColor
        checkIcon.tintColor = color
        
        ratingIcon.image = UIImage(named: badge.lowercased())?.withRenderingMode(.alwaysOriginal)
        
        ratingLabel.text = badge
        
        descriptionLabel.text = Const.progressMap[progress]
    }
    
    func userWasSaved(user: User) {
        
        self.user = user
    }
    
    func estimateFrameForText(text: String, lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0, hyphenation: Float = 1.0, alignment: NSTextAlignment = .natural) -> CGRect {
        
        let size = CGSize(width: view.frame.width - Const.marginEight * 4.0, height: 1000) // height arbitrarily high
        let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.lineHeightMultiple = lineHeightMultiple
        style.hyphenationFactor = hyphenation
        style.alignment = alignment
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: Const.bodyFontSize), NSAttributedStringKey.paragraphStyle: style], context: nil)
    }
    
    private func openURLfromString(string : String) {
        
        let url = URL(string: string)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc func navigateToSettingsViewController(_ sender: UIBarButtonItem){
        
        let settingsController = SettingsViewController()
        settingsController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissSettingsView))
        
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func navigateToEditProfileViewController(_ sender: UIBarButtonItem){
        
        let editProfileController = EditProfileTableViewController()
        editProfileController.user = user
        editProfileController.delegate = self
        
        let navController = UINavigationController(rootViewController: editProfileController)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func dismissSettingsView(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func backAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func showChatLogController() {
        
        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        chatController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    // MARK: UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let v = UIView()
        v.backgroundColor = .clear
        
        let l = UILabel(frame: CGRect(x: Const.marginEight * 2.0, y: Const.marginEight * 3.0, width: tableView.frame.width - Const.marginEight * 4.0, height: 32.0))
        l.text = sections[section]
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        l.textColor = .secondary
        v.addSubview(l)
        
        if sections[section] == "Talk to me about:" && user?.id != myID {
            
            let countInterestsInCommon = userInterests.filter({ myInterests.contains($0) }).count
            
            let u = UILabel(frame: CGRect(x: tableView.frame.width - 120.0 - Const.marginEight * 2.0, y: Const.marginEight * 3.0, width: 120.0, height: 32.0))
            u.text = "\(countInterestsInCommon) shared interests"
            u.font = UIFont.boldSystemFont(ofSize: Const.footnoteFontSize)
            u.textAlignment = .right
            u.textColor = .primary
            v.addSubview(u)
        }
        
        return v
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sectionDataToDisplay[section]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        
        if sections[section] != "Talk to me about:" {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)

            cell.textLabel?.text = sectionDataToDisplay[section]?[indexPath.row]
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
            cell.textLabel?.textColor = .secondary
            
            if sections[section] == "Short biography:" {
                cell.textLabel?.formatTextWithLineSpacing(lineSpacing: 6, lineHeightMultiple: 1.05, hyphenation: 0.5, alignment: .left)
            }
            
            if sections[section] == "My favorite TED talk:" && indexPath.row == 1 {
                cell.textLabel?.textColor = UIColor.secondary.withAlphaComponent(0.4)
            }
            
            if sections[section] == "Let's keep in touch:" && (sectionDataToDisplay[section]?.count == iconForContactSection.count){
                cell.imageView!.image = UIImage(named: iconForContactSection[indexPath.row] as String)
            } else {
                cell.imageView!.image = nil
            }
            
            return cell
        } else {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "InterestTableCell", for: indexPath) as? InterestTableCell {
            
                // If user is not me, then I need to fetch my interests to be able to compare them
                if user?.id != myID {
                    NetworkManager.shared.fetchUser(userID: myID!) { (dictionary) in
                        if let myInterests = dictionary["interests"] as! [String]! {
                            self.myInterests = myInterests.sorted()
                        }
                    }
                }
                
                cell.userInterests = userInterests
                cell.myInterests = myInterests
                cell.interestCollectionView.reloadData()
                cell.interestCollectionViewHeightAnchor?.constant = cell.interestCollectionView.collectionViewLayout.collectionViewContentSize.height
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = indexPath.section
        
        if sections[section] == "Let's keep in touch:" {
            
            let row = indexPath.row
            var stringURL = ""
            
            if iconForContactSection[row] == "email" {
                
                stringURL = "mailto:\(sectionDataToDisplay[section]![row])"
                
            } else {
                
                let replaced = sectionDataToDisplay[section]![row].replacingOccurrences(of: "http://", with: "")
                stringURL = "http://\(replaced)"
            }
            
            openURLfromString(string: stringURL)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Only allows selection of certain cells
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        let section = indexPath.section
        
        if sections[section] == "Let's keep in touch:" {
            return indexPath
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        let section = indexPath.section
        
        if sections[section] == "Let's keep in touch:" {
            return true
        }
        
        return false
    }
    
    // MARK: ScrollViewDidScroll function
    
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
