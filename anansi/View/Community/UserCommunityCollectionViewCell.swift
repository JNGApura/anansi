//
//  UserCommunityCollectionViewCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

protocol ShowProfileDelegate: class {
    func showProfileController(user: User)
}

class UserCommunityCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    // Custom Initializers
    
    let identifier = "UserTableCell"
    
    var delegate: ShowProfileDelegate?
    
    var users : [User] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(CommunityTableCell.self, forCellReuseIdentifier: identifier)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .background
        tv.alwaysBounceVertical = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.contentInset = UIEdgeInsets(top: 16.0, left: 0, bottom: 0, right: 0)
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
        
        NetworkManager.shared.fetchUsers { (dictionary, userUID) in
            
            if userUID != NetworkManager.shared.getUID() {
                let user = User(dictionary: dictionary, id: userUID)
                self.users.append(user)
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CommunityTableCell
        
        let user = users[indexPath.row]
        cell.dictionary = ["profileImageURL": user.profileImageURL as Any,
                           "name": user.name as Any,
                           "field": user.occupation as Any]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.item]
        delegate?.showProfileController(user: user)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
