//
//  CommunityViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 24/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class CommunityViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ShowProfileDelegate, ShowPartnerPageDelegate {

    // Custom initializers
    
    private let userIdentifier = "UserCollectionViewCell"
    private let partnerIdentifier = "PartnerCollectionViewCell"
    
    let listTabs = Const.listTabs
    
    private lazy var topTabBar: TopTabBar = {
        let tb = TopTabBar()
        tb.listTabs = listTabs
        tb.communityController = self
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
    }()
    
    var users: [User] = []
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarItems()
        
        view.addSubview(topTabBar)
        NSLayoutConstraint.activate([
            topTabBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topTabBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            topTabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topTabBar.heightAnchor.constraint(equalToConstant: 50.0),
        ])

        collectionView!.register(UserCommunityCollectionViewCell.self, forCellWithReuseIdentifier: userIdentifier)
        collectionView!.register(PartnerCommunityCollectionViewController.self, forCellWithReuseIdentifier: partnerIdentifier)
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.backgroundColor = .background
        
        collectionView!.contentInset = UIEdgeInsets(top: 50.0, left: 0.0, bottom: 0.0, right: 0.0)
        //collectionView!.scrollIndicatorInsets = UIEdgeInsets(top: 50.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        if let flowLayout = collectionView!.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            collectionView!.isPagingEnabled = true
            collectionView!.showsHorizontalScrollIndicator = false
        }
        
        // Need this for search (I need to find a more effective way of doing this)
        NetworkManager.shared.fetchUsers { (dictionary, userUID) in
            
            if userUID != NetworkManager.shared.getUID() {
                let user = User(dictionary: dictionary, id: userUID)
                self.users.append(user)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBarItems()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserDefaults.standard.isCommunityOnboarded() {
            
            // Presents bottom sheet
            let controller = BottomSheetView()
            controller.setContent(title: "Community",
                                  description: "Discover your friends and other attendees here. Check their profile and find out what they’re into.")
            controller.setIcon(image: #imageLiteral(resourceName: "Community_filled").withRenderingMode(.alwaysTemplate))
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            present(controller, animated: true, completion: nil)
            
            // Sets CommunityOnboarded to true
            UserDefaults.standard.setCommunityOnboarded(value: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewDidDisappear(animated)
        navigationItem.titleView?.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Layout
    
    private func setupNavigationBarItems() {
        
        navigationController?.view.backgroundColor = .background
        navigationController?.navigationBar.isTranslucent = false
        //navigationController?.hidesBarsOnSwipe = true
        
        navigationItem.title = ""
        
        // Sets rightButtonItem - change to "magnifying glass"
        let settingsButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "search").withRenderingMode(.alwaysTemplate), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: Const.navButtonHeight, height: Const.navButtonHeight)
            button.tintColor = .secondary
            button.addTarget(self, action: #selector(showSearchViewController), for: .touchUpInside)
            return button
        }()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }

    // MARK: - Custom functions
    
    @objc func showSearchViewController() {
        
        let searchController = SearchBarViewController(collectionViewLayout: UICollectionViewFlowLayout())
        searchController.users = users
        searchController.hidesBottomBarWhenPushed = true
        
        let navController = UINavigationController(rootViewController: searchController)
        navController.modalPresentationStyle = .overFullScreen
        navController.modalTransitionStyle = .crossDissolve
        present(navController, animated: true, completion: nil)
    }
    
    func showProfileController(user: User) {
        
        let profileController = ProfileViewController()
        profileController.user = user
        profileController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        
        navigationController?.pushViewController(profileController, animated: true)
    }
    
    func showPartnerPageController(partner: Partner) {
        
        /*let profileController = ProfileViewController()
         profileController.user = user
         profileController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
         
         navigationController?.pushViewController(profileController, animated: true)*/
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        topTabBar.horizontalBarLeftAnchor?.constant = scrollView.contentOffset.x / CGFloat(listTabs.count)
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let index = targetContentOffset.pointee.x / view.frame.width
        let indexPath = IndexPath(item: Int(index), section: 0)
        topTabBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
    }
    
    func scrollToTabIndex(tabIndex: Int) {
        
        let indexPath = IndexPath(item: tabIndex, section: 0)
        collectionView!.scrollToItem(at: indexPath, at: [], animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listTabs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userIdentifier, for: indexPath) as! UserCommunityCollectionViewCell
            cell.delegate = self
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: partnerIdentifier, for: indexPath) as! PartnerCommunityCollectionViewController
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: collectionView.bounds.height - 50)
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
