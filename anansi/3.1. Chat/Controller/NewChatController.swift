//
//  NewChatController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 09/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

protocol StartNewChatDelegate {
    func showChatController(user: User)
}

class NewChatController: UITableViewController {
    
    var delegate: StartNewChatDelegate?
    
    var filteredUsers = [User]()
    
    var users = [User]()
    
    lazy var searchController : UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.hidesNavigationBarDuringPresentation = false
        sc.obscuresBackgroundDuringPresentation = false
        sc.dimsBackgroundDuringPresentation = false
        sc.definesPresentationContext = true
        sc.delegate = self
        sc.searchBar.delegate = self
        sc.searchBar.placeholder = "Start a new conversation"
        sc.searchBar.setImage(UIImage(named: "new_message")!.withRenderingMode(.alwaysTemplate), for: .search, state: .normal)
        sc.searchBar.barTintColor = .secondary // color of text field background
        sc.searchBar.tintColor = .secondary // color of bar button items
        sc.searchBar.backgroundColor = .background // color of box surrounding text field
        sc.searchBar.setBackgroundImage(UIImage(), for: .top, barMetrics: .default)
        sc.searchBar.searchBarStyle = .minimal
        sc.searchBar.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    var searchWasCanceled = false
    var searchString: String!
    
    // Creates empty state for collectionView
    lazy var emptyState = SearchEmptyState(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUsers()
        
        tableView.register(CommunityTableCell.self, forCellReuseIdentifier: "SearchCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .background
        tableView.alwaysBounceVertical = true
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        tableView.rowHeight = 96
        tableView.estimatedRowHeight = 96
        tableView.sectionHeaderHeight = 36.0
        tableView.estimatedSectionHeaderHeight = 36.0
        
        let attributes:[NSAttributedString.Key:Any] = [
            NSAttributedString.Key.foregroundColor : UIColor.primary,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: Const.bodyFontSize)
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        
        navigationItem.titleView = searchController.searchBar
        
        searchController.isActive = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
        // Stores searchString before de-activating SearchController
        searchString = searchController.searchBar.text
        
        searchController.isActive = false
        
        // Reverts to translucent
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
        
        // Becomes white
        navigationController?.navigationBar.barTintColor = .background
        navigationController?.navigationBar.isTranslucent = false
        
        if searchString != nil {
            searchController.searchBar.text = searchString
        }
        
        // Sets notifications for keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Network
    
    func fetchUsers() {
        
        NetworkManager.shared.fetchUsers { (dictionary, userID) in
            if userID != NetworkManager.shared.getUID() {
                let user = User()
                user.set(dictionary: dictionary, id: userID)
                self.users.append(user)
            }
        }
    }
    
    // MARK: - Private instance methods
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        searchController.dismiss(animated: true) {
            self.dismiss(animated: true, completion: nil)
        }
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
        
        // Filter users
        filteredUsers = users.filter({ (user) -> Bool in
            if let name = user.getValue(forField: .name) as? String {
                return name.lowercased().contains(searchText.lowercased())
            }
            return false
        })
        if !filteredUsers.isEmpty {
            filteredUsers = filteredUsers.sorted(by: { (($0).getValue(forField: .name) as? String)!.localizedCaseInsensitiveCompare((($1).getValue(forField: .name) as? String)!) == ComparisonResult.orderedAscending } )
        }
        
        tableView.reloadData()
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
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            emptyState.viewCenterYAnchor?.constant = -keyboardSize.height/2
            view.layoutIfNeeded() // Forces the layout of the subtree animation block and then captures all of the frame changes
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBarIsEmpty() {
            return users.count
        } else {
            return filteredUsers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! CommunityTableCell
        
        var user: User
        if searchBarIsEmpty() {
            user = users[indexPath.row]
        } else {
            user = filteredUsers[indexPath.row]
        }
        
        if let name = user.getValue(forField: .name) as? String { cell.name.text = name }
        if let occupation = user.getValue(forField: .occupation) as? String { cell.field.text = occupation }
        if let location = user.getValue(forField: .location) as? String { cell.location.text = "From \(location)" }
        if let profileImageURL = user.getValue(forField: .profileImageURL) as? String { cell.profileImageURL = profileImageURL }
        
        cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.tertiary.withAlphaComponent(0.5))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        
        var user: User
        if searchBarIsEmpty() {
            user = users[indexPath.row]
        } else {
            user = filteredUsers[indexPath.row]
        }
        
        searchController.dismiss(animated: true) {
            
            self.dismiss(animated: true) {
                self.delegate?.showChatController(user: user)
            }
        }
    }
}

extension NewChatController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    // MARK: - UISearchResultsUpdating Delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
