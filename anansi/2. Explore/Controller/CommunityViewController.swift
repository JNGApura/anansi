//
//  CommunityViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 24/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class CommunityViewController: UIViewController {

    // Custom initializers
    private let trendingIdentifier : String = "TrendingCell"
    private let userIdentifier : String = "UserCell"
    private let partnerIdentifier : String = "PartnerCell"
    
    var currentIndex: Int = 0
    
    let tabList = Const.communityTabs
    
    var me = User()
    var userSectionTitles = [String]()
    var usersDictionary = [String: [User]]()
    var userIDs = [String]()
    
    var trendingUsers = [User]()
    var trendingIDs = [String]()
    
    var partnerSections = [String]()
    var partnersInEachSection = [String : [Partner]]()
    var partnerIDs = [String]()
    
    lazy var scrollView : UIScrollView = {
        let sv = UIScrollView()
        //sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.backgroundColor = .background
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView : UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    lazy var headerView : Header = {
        let hv = Header()
        hv.setTitleName(name: "Community")
        hv.actionButton.setImage(UIImage(named: "search")?.withRenderingMode(.alwaysTemplate), for: .normal)
        hv.actionButton.addTarget(self, action: #selector(showSearchViewController), for: .touchUpInside)
        hv.actionButton.isHidden = false
        hv.backgroundColor = .background
        hv.translatesAutoresizingMaskIntoConstraints = false
        return hv
    }()
    
    private lazy var pageSelector: PageSelector = {
        let tb = PageSelector()
        tb.tabList = tabList
        tb.selectorDelegate = self
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
    }()
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(TrendingCommunityCollectionViewCell.self, forCellWithReuseIdentifier: trendingIdentifier)
        cv.register(UserCommunityCollectionViewCell.self, forCellWithReuseIdentifier: userIdentifier)
        cv.register(PartnerCommunityCollectionViewController.self, forCellWithReuseIdentifier: partnerIdentifier)
        cv.isPagingEnabled = true
        cv.allowsSelection = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .background
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
        
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch me
        let myID = NetworkManager.shared.getUID()
        NetworkManager.shared.fetchUser(userID: myID!) { (dictionary) in
            self.me.set(dictionary: dictionary, id: myID!)
        }

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        contentView.addSubview(pageSelector)
        contentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            
            // Activates scrollView constraints
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Activates contentView constraints
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            
            // Activates headerView constraints
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80.0),
            
            // Activates pageSelector constraints
            pageSelector.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pageSelector.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            pageSelector.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            pageSelector.heightAnchor.constraint(equalToConstant: 50.0),
            
            // Activates insideView constraints
            collectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            collectionView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            collectionView.topAnchor.constraint(equalTo: pageSelector.bottomAnchor),
            //collectionView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        currentIndex = 0
        let indexPath = IndexPath.init(item: currentIndex, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBarItems()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if !UserDefaults.standard.isCommunityOnboarded() {
            
            // Presents bottom sheet
            let controller = BottomSheetView()
            controller.setContent(title: "Community",
                                  description: "Discover your friends and other attendees here. Check their profile and find out what they’re into.")
            controller.setIcon(image: UIImage(named: "Community")!.withRenderingMode(.alwaysTemplate))
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            present(controller, animated: true, completion: nil)
            
            // Sets CommunityOnboarded to true
            UserDefaults.standard.setCommunityOnboarded(value: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //*** This is required to fix navigation bar forever disappear on fast backswipe bug.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Layout
    
    private func setupNavigationBarItems() {
        
        navigationController?.view.backgroundColor = .background
        navigationController?.navigationBar.isTranslucent = false
        //navigationItem.titleView = titleLabelView
    }
    
    // MARK: Network calls
    
    func fetchUsers(onSuccess: @escaping () -> Void) {
        
        NetworkManager.shared.fetchUsers { (dictionary, userID) in
            
            let user = User()
            user.set(dictionary: dictionary, id: userID)
            
            if userID != NetworkManager.shared.getUID() {
                
                if userID != "VE0sgL8MhIcHEt7U1Hqo6Ps8DDg2" && !self.userIDs.contains(userID) { // iOS tester (Apple)
                    
                    let name = user.getValue(forField: .name) as! String
                    let nameKey = String(name.uppercased().replacingOccurrences(of:" ", with: "").prefix(1))
                    
                    if !(self.userSectionTitles.contains(nameKey)) {
                        self.userSectionTitles.append(nameKey)
                        self.usersDictionary[nameKey] = [user]
                        
                        self.userSectionTitles = self.sort(array: self.userSectionTitles)
                        
                    } else {
                        self.usersDictionary[nameKey]?.append(user)
                    }
                    
                    // guard to avoid duplicates
                    self.userIDs.append(userID)
                }
            }
            
            onSuccess()
        }
    }
    
    func fetchTrendingUsers(onSuccess: @escaping () -> Void) {
        
        NetworkManager.shared.fetchTrendingUsers { (dictionary, userID) in
            
            let user = User()
            user.set(dictionary: dictionary, id: userID)
            
            if userID != NetworkManager.shared.getUID() {
                
                if !self.trendingIDs.contains(userID) {
                    
                    self.trendingUsers.append(user)
                    self.trendingIDs.append(userID)
                }
            }
            
            onSuccess()
        }
    }
    
    func fetchPartners(onSuccess: @escaping () -> Void) {
        
        NetworkManager.shared.fetchPartners { (dictionary, partnerID) in
            
            let partner = Partner()
            partner.set(dictionary: dictionary, id: partnerID)
            
            // Sorts partners by their type of partnership
            if !self.partnerIDs.contains(partnerID), let type = partner.getValue(forField: .type) as? String {
                
                if !(self.partnerSections.contains(type)) {
                    self.partnerSections.append(type)
                    self.partnersInEachSection[type] = [partner]
                    
                    self.partnerSections.sort { (lhs, rhs) -> Bool in
                        (Const.typePartners.index(of: lhs) ?? 0) < (Const.typePartners.index(of: rhs) ?? 0)
                    }
                    
                } else {
                    self.partnersInEachSection[type]?.append(partner)
                }
                
                // guard to avoid duplicates
                self.partnerIDs.append(partnerID)
            }
            onSuccess()
        }
    }
    
    // MARK: - Custom functions
    
    // Sort array with punctuation & numbers at the end
    func sort(array: [String]) -> [String] {
        
        //array.sorted(by: { $0 < $1 })
        return array.sorted(by: { (lhs, rhs) -> Bool in
            
            let regex = try? NSRegularExpression(pattern: "[0-9.!?\\-]", options: .caseInsensitive)
            let lc = regex?.matches(in: lhs, options: [], range: NSRange(location: 0, length: 1))
            let rc = regex?.matches(in: rhs, options: [], range: NSRange(location: 0, length: 1))
            
            if lc!.isEmpty && !(rc!.isEmpty) {
                return true
            } else if !(lc!.isEmpty) && rc!.isEmpty {
                return false
            } else {
                return lhs < rhs
            }
        })
    }
    
    @objc func showSearchViewController() {
        
        let searchController = SearchTableViewController(style: .grouped)
        searchController.hidesBottomBarWhenPushed = true
        
        let navController = UINavigationController(rootViewController: searchController)
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionView
    
extension CommunityViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.item {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: trendingIdentifier, for: indexPath) as! TrendingCommunityCollectionViewCell
            cell.delegate = self
            
            DispatchQueue.main.async {
                self.fetchTrendingUsers {
                    cell.users = self.trendingUsers
                }
            }
            
            if let myInterests = me.getValue(forField: .interests) as? [String] {
                cell.myInterests = myInterests
            }
            
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userIdentifier, for: indexPath) as! UserCommunityCollectionViewCell
            cell.delegate = self
            cell.scrollDelegate = self
            
            DispatchQueue.main.async {
                self.fetchUsers {
                    cell.userSectionTitles = self.userSectionTitles
                    cell.usersDictionary = self.usersDictionary
                }
            }
            
            if let myInterests = me.getValue(forField: .interests) as? [String] {
                cell.myInterests = myInterests
            }
        
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: partnerIdentifier, for: indexPath) as! PartnerCommunityCollectionViewController
            cell.delegate = self
            
            DispatchQueue.main.async {
                self.fetchPartners {
                    cell.partnerSections = self.partnerSections
                    cell.partnersInEachSection = self.partnersInEachSection
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: - UISCrollViewDelegate

extension CommunityViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let index = Int(targetContentOffset.pointee.x / view.frame.width)
        
        if index != currentIndex {
            currentIndex = index
            
            let indexPath = IndexPath(item: currentIndex, section: 0)
            
            pageSelector.collectionView.selectItem(at: indexPath, animated: true, scrollPosition:.centeredHorizontally)
            pageSelector.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

// MARK: - PageSelectorDelegate

extension CommunityViewController: PageSelectorDelegate {
    
    func pageSelectorDidSelectItemAt(selector: PageSelector, index: Int) {
        
        if index != currentIndex {
            
            currentIndex = index
            
            let indexPath = IndexPath(item: currentIndex, section: 0)
            
            selector.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            selector.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

// MARK: - ShowProfileDelegate

extension CommunityViewController: ShowUserProfileDelegate {
    
    func showUserProfileController(user: User) {
        
        let userProfile = UserPageViewController()
        userProfile.user = user
        userProfile.cameFromCommunity = true
        userProfile.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: navigationController, action: nil)
        
        navigationController?.pushViewController(userProfile, animated: true)
    }
}

// MARK: - ShowPartnerPageDelegate

extension CommunityViewController: ShowPartnerPageDelegate {
    
    func showPartnerPageController(partner: Partner) {
        
        let partnerPageController = PartnerPageViewController()
        partnerPageController.partner = partner
        partnerPageController.cameFromCommunity = true
        partnerPageController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: navigationController, action: nil)
        
        self.navigationController?.pushViewController(partnerPageController, animated: true)
    }
}

// MARK: - ShowProfileDelegate

extension CommunityViewController: UserDidScrollOnCollectionViewCell {
    
    func collectionViewCellDidScroll(offset: CGFloat) {
        
        print(offset)
        
        if headerView.frame.height < offset {
            
            var scrollViewOffset = scrollView.contentOffset
            scrollViewOffset.y = headerView.frame.height
            
            print(headerView.frame.height)
            
            scrollView.setContentOffset(scrollViewOffset, animated: true)
        } else {
            
            var scrollViewOffset = scrollView.contentOffset
            scrollViewOffset.y = 0
            scrollView.setContentOffset(scrollViewOffset, animated: true)
            
        }

    }
}