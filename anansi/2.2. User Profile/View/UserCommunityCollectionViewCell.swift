//
//  UserCommunityCollectionViewCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

protocol UserDidScrollOnCollectionViewCell: class {
    func collectionViewCellDidScroll(offset: CGFloat)
}

protocol ShowUserProfileDelegate: class {
    func showUserProfileController(user: User)
}

class UserCommunityCollectionViewCell: UICollectionViewCell {
    
    // Custom Initializers
        
    var delegate: ShowUserProfileDelegate?
    var scrollDelegate: UserDidScrollOnCollectionViewCell?
    
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
        tv.register(CommunityTableCell.self, forCellReuseIdentifier: "UserTableCell")
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .background
        tv.alwaysBounceVertical = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.contentInset = UIEdgeInsets(top: 8.0, left: 0, bottom: 0, right: 0)
        tv.separatorStyle = .none
        tv.rowHeight = 96
        tv.estimatedRowHeight = 96
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
}

// MARK: - UITableViewDelegate
    
extension UserCommunityCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !areUsersLoading {
            
            tableView.backgroundView = nil
            spinner.stopAnimating()
            
            let nameKey = userSectionTitles[section]
            if let listOfUsers = usersDictionary[nameKey] {
                return listOfUsers.count
            }
            
        } else {
            tableView.backgroundView = spinner
        }
        
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return userSectionTitles.count
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
        
        cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.tertiary.withAlphaComponent(0.5))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let nameKey = userSectionTitles[indexPath.section]
        if let listOfUsers = usersDictionary[nameKey] {
            let user = listOfUsers[indexPath.row]
            
            delegate?.showUserProfileController(user: user)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell") as! CommunityTableCell
        cell.profileImageView.kf.cancelDownloadTask()
    }
}

// MARK: - UIScrollViewDelegate

extension UserCommunityCollectionViewCell: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        let offsetY : CGFloat = tableView.contentOffset.y
        //scrollDelegate?.collectionViewCellDidScroll(offset: offsetY)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY : CGFloat = tableView.contentOffset.y
        //scrollDelegate?.collectionViewCellDidScroll(offset: offsetY)

    }
}
