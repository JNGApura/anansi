//
//  CommunityViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 24/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class CommunityViewController: UIViewController, UINavigationControllerDelegate, ShowProfileDelegate, ShowPartnerPageDelegate {

    // Custom initializers
    
    private let userIdentifier : String = "UserCell"
    private let partnerIdentifier : String = "PartnerCell"
    
    var currentIndex: Int = 0
    
    let tabList = Const.communityTabs
    
    private let titleLabelView: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondary
        label.alpha = 0.0
        label.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        label.text = "Community"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var headerView : Header = {
        let hv = Header()
        hv.setTitleName(name: "Community")
        hv.profileButton.addTarget(self, action: #selector(navigateToSettingsViewController), for: .touchUpInside)
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
        cv.register(UserCommunityCollectionViewCell.self, forCellWithReuseIdentifier: userIdentifier)
        cv.register(PartnerCommunityCollectionViewController.self, forCellWithReuseIdentifier: partnerIdentifier)
        cv.isPagingEnabled = true
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .background
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        return cv
    }()
        
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(headerView)
        view.addSubview(pageSelector)
        view.addSubview(collectionView)
        
        //view.addSubview(topTabBar)
        NSLayoutConstraint.activate([
            
            // Activates headerView constraints
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80.0),
            
            // Activates pageSelector constraints
            pageSelector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageSelector.widthAnchor.constraint(equalTo: view.widthAnchor),
            pageSelector.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            pageSelector.heightAnchor.constraint(equalToConstant: 50.0),
            
            // Activates insideView constraints
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
            collectionView.topAnchor.constraint(equalTo: pageSelector.bottomAnchor),
            //collectionView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Layout
    
    private func setupNavigationBarItems() {
        
        navigationController?.view.backgroundColor = .background
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.titleView = titleLabelView
    }
    
    // MARK: - Custom functions
    
    @objc func navigateToSettingsViewController() {
        
        let controller = SettingsViewController()
        let navController = UINavigationController(rootViewController: controller)
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func showSearchViewController() {
        
        let searchController = SearchTableViewController(style: .grouped) //collectionViewLayout: UICollectionViewFlowLayout()
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
        
        let partnerPageController = PartnerPageViewController()
        partnerPageController.partner = partner
        partnerPageController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        
        navigationController?.pushViewController(partnerPageController, animated: true)
    }
}

// MARK: - UICollectionView
    
extension CommunityViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
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
