//
//  CommunityViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 06/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class CommunityViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchBarDelegate {
    
    private let reuseIdentifier = "Cell"
    
    private let titleLabelView: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondary
        label.alpha = 0.0
        label.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        label.text = "Community"
        return label
    }()
    
    lazy var scrollView : UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.alwaysBounceVertical = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView : UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let headerView : Header = {
        let hv = Header()
        hv.setTitleName(name: "Community")
        hv.translatesAutoresizingMaskIntoConstraints = false
        return hv
    }()
    
    lazy var collectionView : UICollectionView = {
        let cv = UICollectionView(frame: self.contentView.frame, collectionViewLayout: UICollectionViewFlowLayout())
        cv.register(UserCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .background
        cv.alwaysBounceVertical = true
        cv.isScrollEnabled = false
        return cv
    }()
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up navigation bar
        setupNavigationBarItems()
        
        // Sets up UI
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        contentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            
            // Activates scrollView constraints
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Activates contentView constraints
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // Activates headerView constraints
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
            headerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 58.0),
            
            // Activates collectionView constraints
            collectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            collectionView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20.0),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.0),
        ])
        
        // Fetch users
        fetchUsers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.titleView?.isHidden = false
        navigationItem.titleView?.alpha = 0.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewDidDisappear(animated)
        navigationItem.titleView?.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func fetchUsers() {
        
        NetworkManager.shared.fetchUsers { (dictionary, userUID) in
            
            if userUID != NetworkManager.shared.getUID() {
                
                let user = User(dictionary: dictionary, id: userUID)
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    
                    NSLayoutConstraint.activate([
                        self.collectionView.heightAnchor.constraint(equalToConstant: ceil(CGFloat(self.users.count) / 2.0) * 150.0),
                    ])
                }
            }
        }
    }
    
    private func setupNavigationBarItems() {
        
        navigationController?.view.backgroundColor = .background
        navigationController?.navigationBar.isTranslucent = true
        
        // Sets title
        navigationItem.titleView = titleLabelView
        
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
    
    @objc func showSearchViewController() {
        
        let searchController = SearchViewController(collectionViewLayout: UICollectionViewFlowLayout())
        searchController.users = users
        searchController.hidesBottomBarWhenPushed = true
        
        let navController = UINavigationController(rootViewController: searchController)
        navController.modalPresentationStyle = .overFullScreen
        navController.modalTransitionStyle = .crossDissolve
        present(navController, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY : CGFloat = scrollView.contentOffset.y
        let titleOriginY : CGFloat = headerView.headerTitle.frame.origin.y
        let lineMaxY : CGFloat = headerView.headerBottomBorder.frame.maxY
        let label = navigationItem.titleView as? UILabel
        
        if offsetY >= titleOriginY {
            if (offsetY - lineMaxY) < 0 {
                label?.alpha = (offsetY - titleOriginY) / (lineMaxY - titleOriginY)
            } else {
                label?.alpha = 1.0
            }
        } else {
            label?.alpha = 0.0
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserCollectionCell
        
        let user = users[indexPath.item]
        cell.user = user
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2.0, height: 150.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let user = users[indexPath.item]
        showProfileController(user: user)
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func showProfileController(user: User) {
        
        let profileController = ProfileViewController()
        profileController.user = user
        profileController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        
        navigationController?.pushViewController(profileController, animated: true)
    }
}
