//
//  EventViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 12/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {
    
    // Custom initializers
    
    let tabList : [String] = Const.eventTabs
    
    private let scheduleIdentifier : String = "scheduleCell"
    private let challengeIdentifier : String = "challengeCell"
    private let locationIdentifier : String = "locationCell"
    
    var currentIndex: Int = 0
    
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
        hv.setTitleName(name: "Event")
        hv.setProfileImage()
        hv.profileButton.addTarget(self, action: #selector(navigateToProfile), for: .touchUpInside)
        hv.alertButton.addTarget(self, action: #selector(showOfflineAlert), for: .touchUpInside)
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
        cv.register(EventScheduleCollectionViewCell.self, forCellWithReuseIdentifier: scheduleIdentifier)
        //cv.register(EventChallengeCollectionViewCell.self, forCellWithReuseIdentifier: challengeIdentifier)
        cv.register(EventLocationCollectionViewCell.self, forCellWithReuseIdentifier: locationIdentifier)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .background
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.allowsSelection = false;
        return cv
    }()
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    deinit {
        print("EventViewController:  Memory is freeee")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !userDefaults.bool(for: userDefaults.isEventOnboarded) {
            
            // Presents bottom sheet
            let controller = BottomSheetView(title: "Event", description: "Check this page regularly for updates on our event schedule and speaker lineup.", image: UIImage(named: "Event")!.withRenderingMode(.alwaysTemplate))
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            present(controller, animated: true, completion: nil)
            
            // Sets CommunityOnboarded to true
            userDefaults.updateObject(for: userDefaults.isEventOnboarded, with: true)
        }
        
        // Handles network connectivity
        startMonitorConnectivity()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Handles network connectivity
        stopMonitorConnectivity()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerView.setProfileImage()
    }
    
    // MARK: - Custom functions
    
    @objc func navigateToProfile() {
        
        let newChatController = ProfileViewController()
        newChatController.hidesBottomBarWhenPushed = true
        
        let navController = UINavigationController(rootViewController: newChatController)
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionView

extension EventViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.item {
        
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: locationIdentifier, for: indexPath) as! EventLocationCollectionViewCell
            cell.delegate = self
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: scheduleIdentifier, for: indexPath) as! EventScheduleCollectionViewCell
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

extension EventViewController: UIScrollViewDelegate {
    
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

extension EventViewController: PageSelectorDelegate {
    
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

// MARK: ShowSpeakerDetailedPageDelegate

extension EventViewController: ShowSpeakerDetailedPageDelegate {
    
    func showSpeakerDetailedPageWith(data: ScheduleData) {
        
        let speakerDetailed = SpeakerCardDetailedController()
        speakerDetailed.scheduleData = data
        
        navigationController?.pushViewController(speakerDetailed, animated: true)
    }
    
    func showUserPageWith(id: String) {
        
        NetworkManager.shared.fetchUserOnce(userID: id) { [weak self] (dictionary) in
            
            let user = User()
            user.set(dictionary: dictionary, id: id)
            
            let userProfile = UserPageViewController(user: user)
            self?.navigationController?.pushViewController(userProfile, animated: true)
        }
    }
}

// MARK: - LocationButtonDelegate

extension EventViewController: DirectionsButtonDelegate {
    
    func didTapForDirections(bool: Bool) {
        showDirectionsAlertFor(controller: self)
    }
    
    func didCopyPromoCode(with promoCode: String) {
        showKaptenAlertFor(controller: self)
    }
}

// MARK: - ConnectionManager

extension EventViewController {

    func startMonitorConnectivity() {
        
        NetworkManager.shared.setOnlineObserver(onConnected: { [weak self] in
            DispatchQueue.main.async { self?.hideAlert() }
        }, onDisconnected: { [weak self] in
            DispatchQueue.main.async { self?.showAlert() }
        })
    }
    
    func stopMonitorConnectivity() {
        NetworkManager.shared.removeOnlineObserver()
    }
    
    func showAlert() {
        
        headerView.showAlertButton()
        
        if !userDefaults.bool(for: userDefaults.wasOfflineAlertShown) {
            userDefaults.updateObject(for: userDefaults.wasOfflineAlertShown, with: true)
            showOfflineAlert()
        }
    }
    
    func hideAlert() {
        
        headerView.hideAlertButton()
        userDefaults.updateObject(for: userDefaults.wasOfflineAlertShown, with: false)
    }
    
    @objc func showOfflineAlert() {
        showConnectionAlertFor(controller: self)
    }
}
