//
//  UserCommunityCollectionViewCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

protocol ShowUserProfileDelegate: class {
    func showUserProfileController(user: User)
}

protocol ShowSearchDelegate: class {
    func showSearchController()
}

class UserCommunityCollectionViewCell: UICollectionViewCell {
    
    // Custom Initializers
        
    weak var profileDelegate: ShowUserProfileDelegate?
    weak var searchDelegate: ShowSearchDelegate?
    
    private var areUsersLoading = true
    
    var userSectionTitles = [String]()
    var usersDictionary = [String: [User]]() {
        didSet {
            
            // This is a hack to avoid showing a list of users that's increasing in size
            if usersDictionary.count > 5 && areUsersLoading {
                areUsersLoading = false
            }
            
            tableView.reloadData()
        }
    }
        
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(CommunitySearchCell.self, forCellReuseIdentifier: "SearchUsersCell")
        tv.register(CommunityTableCell.self, forCellReuseIdentifier: "UserTableCell")
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .background
        tv.alwaysBounceVertical = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.contentInset = UIEdgeInsets(top: 8.0, left: 0, bottom: Const.marginSafeArea, right: 0)
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 96
        tv.contentInset.top = -1 * 44.0
        return tv
    }()

    /// Spinner shown during load
    let spinner : UIActivityIndicatorView = {
        let s = UIActivityIndicatorView()
        s.color = .primary
        s.startAnimating()
        s.hidesWhenStopped = true
        return s
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.tableView)
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.topAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Shows searchbar when pulled down
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y < 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.tableView.contentInset.top = 0
            })
        } else if scrollView.contentOffset.y > 44.0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.tableView.contentInset.top = -1 * 44.0
            })
        }
    }
}

// MARK: - UITableViewDelegate
    
extension UserCommunityCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return userSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !areUsersLoading {
            
            tableView.backgroundView = nil
            spinner.stopAnimating()
            
            let nameKey = userSectionTitles[section]
            if let listOfUsers = usersDictionary[nameKey] {
                return listOfUsers.count
                
            } else {
                // search bar
                return 1
            }
            
        } else {
            tableView.backgroundView = spinner
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        if !areUsersLoading {
            return userSectionTitles
        }
        return [""]
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return userSectionTitles.index(of: title)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchUsersCell", for: indexPath) as! CommunitySearchCell
            cell.selectedBackgroundView = createViewWithBackgroundColor(.clear)
            return cell
            
        } else {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell", for: indexPath) as! CommunityTableCell
            cell.profileImageView.kf.cancelDownloadTask() // cancel download task, if there's any
            
            let userKey = userSectionTitles[indexPath.section]
            if let listOfUsers = usersDictionary[userKey] {
                
                let user = listOfUsers[indexPath.row]
                
                if let name = user.getValue(forField: .name) as? String { cell.name.text = name }
                if let occupation = user.getValue(forField: .occupation) as? String { cell.field.text = occupation }
                if let location = user.getValue(forField: .location) as? String { cell.location.text = "From \(location)" }
                if let profileImageURL = user.getValue(forField: .profileImageURL) as? String { cell.profileImageURL = profileImageURL }
            }
            
            cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.tertiary.withAlphaComponent(0.3))
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            // Weird bug when there's a delayed action when tapped on a selectionStyle = .none cell
            // Solutions: changing to selectionStyle = .default or using DispatchQueue.main.async
            DispatchQueue.main.async{
                self.searchDelegate?.showSearchController()
            }
            
        } else {
            
            let nameKey = userSectionTitles[indexPath.section]
            if let listOfUsers = usersDictionary[nameKey] {
                let user = listOfUsers[indexPath.row]
                
                profileDelegate?.showUserProfileController(user: user)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section != 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell") as! CommunityTableCell
            cell.profileImageView.kf.cancelDownloadTask()
        }
    }
}
