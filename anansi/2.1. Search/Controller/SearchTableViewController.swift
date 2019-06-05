//
//  SearchTableViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 04/03/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class SearchTableViewController: UIViewController {
    
    private let identifier = "SearchCell"

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
        sc.searchBar.placeholder = "Search for attendees"
        sc.searchBar.setImage(UIImage(named: "search")!.withRenderingMode(.alwaysTemplate), for: .search, state: .normal)
        sc.searchBar.barTintColor = .secondary // color of text field background
        sc.searchBar.tintColor = .secondary // color of bar button items
        sc.searchBar.backgroundColor = .background // color of box surrounding text field
        sc.searchBar.setBackgroundImage(UIImage(), for: .top, barMetrics: .default)
        sc.searchBar.searchBarStyle = .minimal
        return sc
    }()
    
    let searchBarAttributes:[NSAttributedString.Key:Any] = [
        NSAttributedString.Key.foregroundColor  :   UIColor.primary,
        NSAttributedString.Key.font             :   UIFont.systemFont(ofSize: Const.calloutFontSize)
    ]
    
    lazy var topbar: TopBar = {
        let b = TopBar()
        b.setTitle(name: "")
        b.backgroundColor = .background
        b.backButton.isHidden = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    lazy var tableView : UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.register(SearchTableCell.self, forCellReuseIdentifier: identifier)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .background
        tv.alwaysBounceVertical = true
        tv.separatorStyle = .none
        tv.rowHeight = 60.0
        tv.estimatedRowHeight = 60.0
        tv.sectionHeaderHeight = 28.0
        tv.estimatedSectionHeaderHeight = 28.0
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    var searchString: String!
    
    lazy var barHeight : CGFloat = (navigationController?.navigationBar.frame.height)!
    let statusBarHeight : CGFloat = UIApplication.shared.statusBarFrame.height
    
    // Creates empty state for tableView
    lazy var emptyState = SearchEmptyState(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        fetchMyInterests()
        fetchRecentlyViewedUsers()
        
        // Set up UI
        [tableView].forEach { view.addSubview($0) }
        tableView.tableHeaderView = searchController.searchBar
        //navigationItem.titleView
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        searchController.searchBar.isHidden = false
        
        if searchString != nil {
            searchController.searchBar.text = searchString
        }
        
        // Fetches necessary information
        fetchMyInterests()
        fetchRecentlyViewedUsers()
        
        // Enables swipe to pop
        swipeToPop()
        
        // Sets notifications for keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchController.isActive = true
        
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
            
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchString = searchController.searchBar.text // Stores searchString
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        searchController.searchBar.isHidden = true
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchController.isActive = false
        searchController.searchBar.endEditing(true)        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(searchBarAttributes, for: .normal)
        
        NSLayoutConstraint.activate([

            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Custom functions
    
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
    
    func showProfileController(user: User) {
        
        let userController = UserPageViewController()
        userController.user = user
        searchController.searchBar.resignFirstResponder()
        
        navigationController?.pushViewController(userController, animated: true)
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
}
    
// MARK: UITableViewDelegate

extension SearchTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchBarIsEmpty() {
            return suggestedSections[section]
        } else {
            return "Attendees"
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
     
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        header.textLabel?.textColor = .secondary
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: Const.subheadFontSize)
        header.textLabel?.frame = header.frame
     }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBarIsEmpty() {
            let listOfUsers = filteredSuggestions[suggestedSections[section]]
            return listOfUsers!.count
            
        } else {
            return filteredUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SearchTableCell
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        
        showProfileController(user: user)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! SearchTableCell
        cell.profileImageView.kf.cancelDownloadTask()
    }
}


// MARK: - UIScrollViewDelegate

extension SearchTableViewController: UIScrollViewDelegate {
    
    // this delegate is called when the scrollView (i.e your UITableView) will start scrolling
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }

}

// MARK: - UISearchResultsUpdating Delegate

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
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
        
        // Removes clear Button
        guard let firstSubview = searchBar.subviews.first else { return }
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

extension SearchTableViewController: UIGestureRecognizerDelegate {
    
    func swipeToPop() {
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
        navigationController?.interactivePopGestureRecognizer?.delegate = self;
    }
}
