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

class UserCommunityCollectionViewCell: UICollectionViewCell {
    
    // Custom Initializers
    
    var delegate: ShowUserProfileDelegate?
    
    var users : [User] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var myInterests : [String]!
    
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
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        fetchUsers()

        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Network
    
    func fetchUsers() {
        
        NetworkManager.shared.fetchUsers { (dictionary, userID) in
            
            let user = User()
            user.set(dictionary: dictionary, id: userID)
            
            if userID != NetworkManager.shared.getUID() {
                if userID != "VE0sgL8MhIcHEt7U1Hqo6Ps8DDg2" {
                    
                    self.users.append(user)
                }
                
            } else if userID == NetworkManager.shared.getUID(){
                
                if let interests = dictionary[userInfoType.interests.rawValue] as? [String] {
                    UserDefaults.standard.set(interests, forKey: userInfoType.interests.rawValue)
                    UserDefaults.standard.synchronize()
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate
    
extension UserCommunityCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell", for: indexPath) as! CommunityTableCell
        
        let user = users[indexPath.row]
        
        if let name = user.getValue(forField: .name) as? String { cell.name.text = name }
        if let occupation = user.getValue(forField: .occupation) as? String { cell.field.text = occupation }
        if let location = user.getValue(forField: .location) as? String { cell.location.text = "From \(location)" }
        if let profileImageURL = user.getValue(forField: .profileImageURL) as? String { cell.profileImageURL = profileImageURL }

        cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.tertiary.withAlphaComponent(0.5))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.item]
        delegate?.showUserProfileController(user: user)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
