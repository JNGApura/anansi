//
//  SearchTableViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 04/03/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {
    
    private let identifier = "SearchCell"
    
    var sections = [String]()
    
    var filteredUsers = [User]()
    var filteredPartners = [Partner]()
    
    var users = [User]()
    var partners =  [Partner]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var searchWasCanceled = false
    var searchString: String!
    
    // Creates empty state for collectionView
    lazy var emptyState = SearchEmptyState(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUsers()
        fetchPartners()
        
        tableView.register(CommunityTableCell.self, forCellReuseIdentifier: identifier)
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
        
        searchController.isActive = true
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
        
        // Sets notifications for keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Network
    
    func fetchUsers() {
        
        NetworkManager.shared.fetchUsers { (dictionary, userUID) in
            if userUID != NetworkManager.shared.getUID() {
                let user = User(dictionary: dictionary, id: userUID)
                self.users.append(user)
            }
        }
    }
    
    func fetchPartners() {
        
        NetworkManager.shared.fetchPartners { (dictionary, partnerID) in
            let partner = Partner(dictionary: dictionary, id: partnerID)
            self.partners.append(partner)
        }
    }
    
    // MARK: - Custom functions
    
    func showProfileController(user: User) {
        
        let profileController = ProfileViewController()
        profileController.user = user
        profileController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        searchController.searchBar.resignFirstResponder()
        
        navigationController?.pushViewController(profileController, animated: true)
    }
    
    func showPartnerPageController(partner: Partner) {
        
        let partnerPageController = PartnerPageViewController()
        partnerPageController.partner = partner
        partnerPageController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        
        navigationController?.pushViewController(partnerPageController, animated: true)
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
        
        sections.removeAll()
        
        // Filter users
        filteredUsers = users.filter({ (user) -> Bool in
            return user.name!.lowercased().contains(searchText.lowercased())
        })
        if !filteredUsers.isEmpty {
            filteredUsers = filteredUsers.sorted(by: { ($0).name!.localizedCaseInsensitiveCompare(($1).name!) == ComparisonResult.orderedAscending } )
            sections.append("Attendees")
        }
        
        // Filter partners
        filteredPartners = partners.filter({ (partner) -> Bool in
            return partner.name!.lowercased().contains(searchText.lowercased())
        })
        if !filteredPartners.isEmpty {
            filteredPartners = filteredPartners.sorted(by: { ($0).name!.localizedCaseInsensitiveCompare(($1).name!) == ComparisonResult.orderedAscending } )
            sections.append("Partners")
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

        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            emptyState.viewCenterYAnchor?.constant = -keyboardSize.height/2
            view.layoutIfNeeded() // Forces the layout of the subtree animation block and then captures all of the frame changes
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if (sections.count == 0 && !searchBarIsEmpty()) {
            tableView.backgroundView = emptyState
        } else {
            tableView.backgroundView = nil
        }
        
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
     
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        header.textLabel?.textColor = .secondary
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: Const.subheadFontSize)
        header.textLabel?.frame = header.frame
     }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections[section] == "Attendees" {
            return filteredUsers.count
        } else {
            return filteredPartners.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CommunityTableCell
        
        if sections[indexPath.section] == "Attendees" {
            
            let user = filteredUsers[indexPath.row]
            cell.dictionary = ["profileImageURL": user.profileImageURL as Any,
                               "name": user.name as Any,
                               "field": user.occupation as Any,
                               "location": "From \(user.location!)" as Any]
        } else {
            
            let partner = filteredPartners[indexPath.row]
            cell.dictionary = ["profileImageURL": partner.profileImageURL as Any,
                               "name": partner.name as Any,
                               "field": partner.field as Any,
                               "location": partner.location as Any]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        searchController.searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        
        if sections[indexPath.section] == "Attendees" {
            
            let user = filteredUsers[indexPath.row]
            showProfileController(user: user)
        } else {
            
            let partner = filteredPartners[indexPath.row]
            showPartnerPageController(partner: partner)
        }
    }
}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    // MARK: - UISearchResultsUpdating Delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
