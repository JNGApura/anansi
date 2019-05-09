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
    
    lazy var searchController : UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.hidesNavigationBarDuringPresentation = false
        sc.obscuresBackgroundDuringPresentation = false
        sc.dimsBackgroundDuringPresentation = false
        sc.definesPresentationContext = true
        sc.delegate = self
        sc.searchBar.delegate = self
        sc.searchBar.placeholder = "Search in community"
        sc.searchBar.setImage(UIImage(named: "search")!.withRenderingMode(.alwaysTemplate), for: .search, state: .normal)
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
    
    func fetchPartners() {
        
        NetworkManager.shared.fetchPartners { (dictionary, partnerID) in
            
            let partner = Partner()
            partner.set(dictionary: dictionary, id: partnerID)
            self.partners.append(partner)
        }
    }
    
    // MARK: - Custom functions
    
    func showProfileController(user: User) {
        
        let profileController = UserPageViewController()
        profileController.user = user
        profileController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: navigationController, action: nil)
        searchController.searchBar.resignFirstResponder()
        
        navigationController?.pushViewController(profileController, animated: true)
    }
    
    func showPartnerPageController(partner: Partner) {
        
        let partnerPageController = PartnerPageViewController()
        partnerPageController.partner = partner
        partnerPageController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: navigationController, action: nil)
        
        navigationController?.pushViewController(partnerPageController, animated: true)
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
        
        sections.removeAll()
        
        // Filter users
        filteredUsers = users.filter({ (user) -> Bool in
            if let name = user.getValue(forField: .name) as? String {
                return name.lowercased().contains(searchText.lowercased())
            }
            return false
        })
        if !filteredUsers.isEmpty {
            filteredUsers = filteredUsers.sorted(by: { (($0).getValue(forField: .name) as? String)!.localizedCaseInsensitiveCompare((($1).getValue(forField: .name) as? String)!) == ComparisonResult.orderedAscending } )
            sections.append("Attendees")
        }
        
        // Filter partners
        filteredPartners = partners.filter({ (partner) -> Bool in
            if let name = partner.getValue(forField: .name) as? String {
                return name.lowercased().contains(searchText.lowercased())
            }
            return false
        })
        if !filteredPartners.isEmpty {
            
            filteredPartners = filteredPartners.sorted(by: { (($0).getValue(forField: .name) as? String)!.localizedCaseInsensitiveCompare((($1).getValue(forField: .name) as? String)!) == ComparisonResult.orderedAscending } )
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

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
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
            if let name = user.getValue(forField: .name) as? String { cell.name.text = name }
            if let occupation = user.getValue(forField: .occupation) as? String { cell.field.text = occupation }
            if let location = user.getValue(forField: .location) as? String { cell.location.text = "From \(location)" }
            if let profileImageURL = user.getValue(forField: .profileImageURL) as? String { cell.profileImageURL = profileImageURL }

        } else {
            
            let partner = filteredPartners[indexPath.row]
            if let name = partner.getValue(forField: .name) as? String { cell.name.text = name }
            if let occupation = partner.getValue(forField: .field) as? String { cell.field.text = occupation }
            if let location = partner.getValue(forField: .location) as? String { cell.location.text = location }
            if let profileImageURL = partner.getValue(forField: .profileImageURL) as? String { cell.profileImageURL = profileImageURL }
        }
        
        cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.tertiary.withAlphaComponent(0.5))
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
