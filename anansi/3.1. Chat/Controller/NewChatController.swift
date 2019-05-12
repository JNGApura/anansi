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
    
    var suggestedSections = [String]()
    
    var filteredUsers = [User]()
    var filteredSuggestions = [String : [User]]()
    
    var myInterests = [String]()
    var myRecentViewIDs = [String]()
    
    var trendingUsers = [User]()
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
        
        tableView.register(SearchTableCell.self, forCellReuseIdentifier: "SearchCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .background
        tableView.alwaysBounceVertical = true
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        tableView.rowHeight = 60.0
        tableView.estimatedRowHeight = 60.0
        tableView.sectionHeaderHeight = 20.0
        tableView.estimatedSectionHeaderHeight = 20.0
        
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
        searchController.searchBar.endEditing(true)
        
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
        
        // Fetches necessary information
        fetchMyInterests()
        fetchRecentlyViewedUsers()
        fetchUsers()
        fetchTrendingUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Network
    
    private func fetchMyInterests() {
        
        if let interests = UserDefaults.standard.value(forKey: userInfoType.interests.rawValue) as? [String] {
            myInterests = interests
        }
    }
    
    private func fetchRecentlyViewedUsers() {
        
        if let recentlyViewed = UserDefaults.standard.value(forKey: "recentlyViewedIDs") as? [String] {
            myRecentViewIDs = recentlyViewed
        }
    }
    
    func fetchUsers() {
        
        NetworkManager.shared.fetchUsers { (dictionary, userID) in
            if userID != NetworkManager.shared.getUID() {
                let user = User()
                user.set(dictionary: dictionary, id: userID)
                self.users.append(user)
            }
        }
    }
    
    func fetchTrendingUsers() {
        
        NetworkManager.shared.fetchTrendingUsers(limited: 5, onSuccess: { (dictionary, userID) in
            if userID != NetworkManager.shared.getUID() {
                let user = User()
                user.set(dictionary: dictionary, id: userID)
                self.trendingUsers.append(user)
            }
        })
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
        
        if !searchBarIsEmpty() && filteredUsers.count == 0 {
            tableView.backgroundView = emptyState
            return 0
            
        } else {
            tableView.backgroundView = nil
            
            if searchBarIsEmpty() {
                return suggestedSections.count
            } else {
                return 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchBarIsEmpty() {
            return suggestedSections[section]
        } else {
            return "Attendees"
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        header.textLabel?.textColor = .secondary
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: Const.subheadFontSize)
        header.textLabel?.frame = header.frame
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBarIsEmpty() {
            let listOfUsers = filteredSuggestions[suggestedSections[section]]
            return listOfUsers!.count
            
        } else {
            return filteredUsers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchTableCell
        cell.profileImageView.kf.cancelDownloadTask() // cancel download task, if there's any
        
        let section = suggestedSections[indexPath.section]
        let listOfUsers = filteredSuggestions[section]
        
        var user: User
        if searchBarIsEmpty() && indexPath.row < listOfUsers!.count {
            user = listOfUsers![indexPath.row]
        } else {
            user = filteredUsers[indexPath.row]
        }
        
        if let name = user.getValue(forField: .name) as? String { cell.name.text = name }
        if let interests = user.getValue(forField: .interests) as? [String] {
            cell.interestsInCommon.text = "\(interests.filter { myInterests.contains($0) }.count) shared interests"
        } else {
            cell.interestsInCommon.text = "0 shared interests"
        }
        if let profileImageURL = user.getValue(forField: .profileImageURL) as? String { cell.profileImageURL = profileImageURL }
        
        cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.tertiary.withAlphaComponent(0.5))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        searchController.searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = suggestedSections[indexPath.section]
        let listOfUsers = filteredSuggestions[section]
        
        var user: User
        if searchBarIsEmpty() {
            user = listOfUsers![indexPath.row]
        } else {
            user = filteredUsers[indexPath.row]
        }
        
        searchController.dismiss(animated: true) {
            
            self.dismiss(animated: true) {
                self.delegate?.showChatController(user: user)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchTableCell
        cell.profileImageView.kf.cancelDownloadTask()
    }
    
    // MARK: - UIScrollViewDelegate
    
    // this delegate is called when the scrollView (i.e your UITableView) will start scrolling
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchController.searchBar.resignFirstResponder()
    }
}

extension NewChatController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    // MARK: - UISearchResultsUpdating Delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.resignFirstResponder()
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
        
        searchController.searchBar.endEditing(true)
        filterContentForSearchText(searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        if !searchBarIsEmpty() {
            
            //Clean up
            filteredUsers.removeAll()
            
            // Filter users
            filteredUsers = users.filter({ (user) -> Bool in
                if let name = user.getValue(forField: .name) as? String,
                    let interests = user.getValue(forField: .interests) as? [String] {
                    
                    let nameResults = name.lowercased().contains(searchText.lowercased())
                    let interestResults = interests.map{$0.lowercased()}.contains(searchText.lowercased())
                    
                    return nameResults || interestResults
                }
                return false
            })
            if !filteredUsers.isEmpty {
                filteredUsers = filteredUsers.sorted(by: { (($0).getValue(forField: .name) as? String)!.localizedCaseInsensitiveCompare((($1).getValue(forField: .name) as? String)!) == .orderedAscending } )
            }
            
        } else {
            
            // Clean up
            suggestedSections.removeAll()
            filteredSuggestions.removeAll()
            
            // Suggested
            var suggested = [User]()
            if !myInterests.isEmpty {
                let suggestedUsers = users.sorted(by: { (lhs, rhs) in
                    
                    let lc = ((lhs.getValue(forField: .interests) as? [String]) ?? []).filter { myInterests.contains($0) }.count
                    let rc = ((rhs.getValue(forField: .interests) as? [String]) ?? []).filter { myInterests.contains($0) }.count
                    
                    if lc == 0 && rc != 0 {
                        return true
                    } else if lc != 0 && rc == 0 {
                        return false
                    } else if lc == rc {
                        return (lhs.getValue(forField: .name) as? String)!.localizedCaseInsensitiveCompare((rhs.getValue(forField: .name) as? String)!) == .orderedDescending
                    } else {
                        return lc < rc
                    }
                }).reversed().prefix(5)
                suggested = Array(suggestedUsers)
                
            } else {
                let suggestedUsers = trendingUsers.prefix(5)
                suggested = Array(suggestedUsers)
            }
            
            if !suggested.isEmpty {
                suggestedSections.append("Suggested")
                filteredSuggestions["Suggested"] = Array(suggested)
            }
            
            // Recently viewed
            let recentlyViewed = users.filter { (user) -> Bool in
                
                if let id = user.getValue(forField: .id) as? String {
                    return myRecentViewIDs.contains(id)
                }
                return false
                
                }.sorted { (lhs, rhs) -> Bool in
                    
                    let lc = lhs.getValue(forField: .id) as! String
                    let rc = rhs.getValue(forField: .id) as! String
                    
                    return myRecentViewIDs.index(of: lc)! < myRecentViewIDs.index(of: rc)!
                    
                }.prefix(5)
            
            if !recentlyViewed.isEmpty {
                suggestedSections.append("Recently viewed")
                filteredSuggestions["Recently viewed"] = Array(recentlyViewed)
            }
        }
        
        tableView.reloadData()
        tableView.layoutIfNeeded()
    }
    
    // Returns true if the text is empty or nil
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
}
