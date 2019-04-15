//
//  EventViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 12/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class EventViewController: UIViewController, UINavigationControllerDelegate {
    
    // Custom initializers
    
    let tabList : [String] = Const.eventTabs
    
    private let scheduleIdentifier : String = "scheduleCell"
    private let challengeIdentifier : String = "challengeCell"
    private let locationIdentifier : String = "locationCell"
    
    var currentIndex: Int = 0
    
    private let titleLabelView: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondary
        label.alpha = 0.0
        label.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        label.text = "Event"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var scrollView : UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
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
        cv.register(EventScheduleCollectionViewCell.self, forCellWithReuseIdentifier: scheduleIdentifier)
        cv.register(EventChallengeCollectionViewCell.self, forCellWithReuseIdentifier: challengeIdentifier)
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
        
        //view.addSubview(topTabBar)
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
        
        if !UserDefaults.standard.isCommunityOnboarded() {
            
            // Presents bottom sheet
            let controller = BottomSheetView()
            controller.setContent(title: "Event",
                                  description: "Check this page regularly for updates on our event schedule and speaker lineup.")
            controller.setIcon(image: #imageLiteral(resourceName: "Event_filled").withRenderingMode(.alwaysTemplate))
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

// MARK: ScrollViewDidScroll function
/*
 override func scrollViewDidScroll(_ scrollView: UIScrollView) {
 
 let offsetY : CGFloat = scrollView.contentOffset.y
 let titleOriginY : CGFloat = headerView.headerTitle.frame.origin.y
 let lineMaxY : CGFloat = headerView.bottomLine.frame.maxY
 let label = navigationItem.titleView as! UILabel
 
 if offsetY >= titleOriginY {
 if (offsetY - lineMaxY) < 0 {
 label.alpha = (offsetY - titleOriginY) / (lineMaxY - titleOriginY)
 } else {
 label.alpha = 1.0
 }
 } else {
 label.alpha = 0.0
 }
 }*/

// MARK: - UICollectionView

extension EventViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.item {
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: challengeIdentifier, for: indexPath) as! EventChallengeCollectionViewCell
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: locationIdentifier, for: indexPath) as! EventLocationCollectionViewCell
            cell.delegate = self
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: scheduleIdentifier, for: indexPath) as! EventScheduleCollectionViewCell
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

// MARK: - LocationButtonDelegate

extension EventViewController: DirectionsButtonDelegate {
    
    func didTapForDirections(bool: Bool) {
        
        let alert = UIAlertController(title: "Address", message: "Please choose an option below:", preferredStyle: .actionSheet)
        
        // Open Apple Maps
        alert.addAction(UIAlertAction(title: "Open in Apple Maps", style: .default , handler:{ (UIAlertAction)in
            
            if let url = URL(string: "http://maps.apple.com/maps?saddr=&daddr=\(Const.addressLatitude),\(Const.addressLongitude)") {
                UIApplication.shared.open(url, options: [:])
            } else {
                NSLog("Can't use maps://");
            }
            
        }))
        
        // Open Google Maps
        alert.addAction(UIAlertAction(title: "Open in Google Maps", style: .default , handler:{ (UIAlertAction)in
            
            if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(Const.addressLatitude),\(Const.addressLongitude)") {
                UIApplication.shared.open(url, options: [:])
                
            } else {
                if let url = URL(string: "https://maps.google.com/?q=@\(Const.addressLatitude),\(Const.addressLongitude)"){
                    UIApplication.shared.open(url, options: [:])
                    
                } else {
                    NSLog("Can't use Google Maps");
                }
            }
        }))
        
        // Copy address
        alert.addAction(UIAlertAction(title: "Copy address", style: .default , handler:{ (UIAlertAction) in
            
            let pasteboard = UIPasteboard.general
            pasteboard.string = Const.addressULisboa
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func didCopyPromoCode(with promoCode: String) {
    
        let alert = UIAlertController(title: "Let's get you movin' 🚗", message: "You've successfuly copied \(Const.kaptenPromoCode). Open Kapten's app and apply the promocode to enjoy 5€ off your first ride.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Got it!", style: .default , handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

}
