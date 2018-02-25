//
//  SearchBarViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 21/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class SearchBarViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate, UISearchBarDelegate {
    
    private let reuseIdentifier = "Cell"
    
    var filteredUsers : [User] = []
    var users: [User] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var searchWasCanceled = false
    var searchString: String!
    
    
    let searchView : UIView = {
        let v = UIView()
        v.backgroundColor = .primary
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let searchBarView : UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // Creates empty state for collectionView
    lazy var emptyState = SearchEmptyState(frame: CGRect(x: 0, y: 0, width: self.collectionView!.bounds.width, height: self.collectionView!.bounds.height))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.register(UserCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.backgroundColor = .background
        collectionView!.alwaysBounceVertical = true
        collectionView!.contentInset = UIEdgeInsets(top: 20.0, left: 0, bottom: 0, right: 0)
        
        // Create searchView
        /*navigationController?.view.addSubview(searchView)
        NSLayoutConstraint.activate([
            searchView.bottomAnchor.constraint(equalTo: navigationController!.navigationBar.bottomAnchor),
            searchView.leadingAnchor.constraint(equalTo: navigationController!.view.leadingAnchor),
            searchView.trailingAnchor.constraint(equalTo: navigationController!.view.trailingAnchor),
            searchView.topAnchor.constraint(equalTo: navigationController!.view.topAnchor)
        ])
        
        searchView.addSubview(searchBarView)
        NSLayoutConstraint.activate([
            searchBarView.bottomAnchor.constraint(equalTo: searchView.bottomAnchor),
            searchBarView.leadingAnchor.constraint(equalTo: searchView.leadingAnchor),
            searchBarView.trailingAnchor.constraint(equalTo: searchView.trailingAnchor),
            searchBarView.heightAnchor.constraint(equalToConstant: 44.0)
        ])*/
        
        //searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search attendees"
        searchController.searchBar.setImage(#imageLiteral(resourceName: "search").withRenderingMode(.alwaysTemplate), for: .search, state: .normal)
        searchController.searchBar.sizeToFit()
        
        searchController.searchBar.tintColor = .red // color of bar button items
        searchController.searchBar.barTintColor = .red // color of text field background
        searchController.searchBar.backgroundColor = .primary // color of box surrounding text field
        searchController.searchBar.setBackgroundImage(UIImage(), for: .top, barMetrics: .default)
        searchController.searchBar.searchBarStyle = .prominent
        
        let attributes:[NSAttributedStringKey:Any] = [
            NSAttributedStringKey.foregroundColor : UIColor.background,
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: Const.bodyFontSize)
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        
        searchController.definesPresentationContext = true
        navigationController?.navigationBar.barTintColor = .primary
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.titleView = searchController.searchBar
        
        //searchBarView.addSubview(searchController.searchBar)
        //searchView.transform = CGAffineTransform(translationX: 0, y: -50)
        
        searchController.isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
        // Stores searchString before de-activating SearchController
        searchString = searchController.searchBar.text
        
        searchController.isActive = false

        // Reverts to white
        navigationController?.navigationBar.barTintColor = .background
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Becomes red
        navigationController?.navigationBar.barTintColor = .primary
        navigationController?.navigationBar.isTranslucent = false
        
        if searchString != nil {
            searchController.searchBar.text = searchString
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private instance methods
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchString = nil
        searchWasCanceled = true
        
        searchController.searchBar.resignFirstResponder()
        
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        guard let firstSubview = searchBar.subviews.first else { return }
        
        // Removes clear Button
        firstSubview.subviews.forEach {
            ($0 as? UITextField)?.clearButtonMode = .never
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchController.searchBar.resignFirstResponder()
        
        filterContentForSearchText(searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        filteredUsers = users.filter({ (user) -> Bool in
            return user.name!.lowercased().contains(searchText.lowercased())
        })
        
        // Attemps to sort alphabetically (there's a bug here, somewhere)
        filteredUsers = filteredUsers.sorted(by: { ($0).name!.localizedCaseInsensitiveCompare(($1).name!) == ComparisonResult.orderedAscending } )
        
        collectionView!.reloadData()
    }
    
    
    // Returns true if the text is empty or nil
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    // MARK : KEYBOARD-related functions
    
    @objc func keyboardWillHide() {
        emptyState.viewCenterYAnchor?.constant = 0
        view.layoutIfNeeded() // Forces the layout of the subtree animation block and then captures all of the frame changes
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            emptyState.viewCenterYAnchor?.constant = -keyboardSize.height/2
            view.layoutIfNeeded() // Forces the layout of the subtree animation block and then captures all of the frame changes
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (filteredUsers.count == 0 && !searchBarIsEmpty()) {
            collectionView.backgroundView = emptyState
        } else {
            collectionView.backgroundView = nil
        }
        
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserCollectionCell
        
        let user = filteredUsers[indexPath.item]
        cell.user = user
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width / 2.0, height: 150.0)
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let user = filteredUsers[indexPath.item]
        
        searchController.searchBar.resignFirstResponder()
        
        showProfileController(user: user)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func showProfileController(user: User) {
        
        let profileController = ProfileViewController()
        profileController.user = user
        profileController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        searchController.searchBar.resignFirstResponder()
        
        navigationController?.pushViewController(profileController, animated: true)
    }
}

extension SearchBarViewController: UISearchResultsUpdating {
    
    // MARK: - UISearchResultsUpdating Delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
