//
//  EmployeeTableCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 03/03/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class EmployeeTableCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    // Create question label
    let identifier = "EmployeeTableCell"
    
    weak var delegate: ShowUserProfileDelegate?
    
    var users : [User] = [] {
        didSet {
            employeeTableView.reloadData()
        }
    }
    var usersIDList : [String] = [] {
        didSet {
            users.removeAll()
            fetchUsers()
        }
    }
    
    lazy var employeeTableView : UITableView = {
        let tv = UITableView()
        tv.register(UserTableCell.self, forCellReuseIdentifier: identifier)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .background
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.rowHeight = 72.0
        tv.estimatedRowHeight = UITableView.automaticDimension
        return tv
    }()
    var employeeTableViewHeightAnchor: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(employeeTableView)
        NSLayoutConstraint.activate([
            employeeTableView.topAnchor.constraint(equalTo: topAnchor),
            employeeTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            employeeTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            employeeTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        employeeTableViewHeightAnchor = employeeTableView.heightAnchor.constraint(equalToConstant: 0.0)
        employeeTableViewHeightAnchor?.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Custom functions
    
    func fetchUsers() {

        for id in usersIDList {
            
            NetworkManager.shared.fetchUserOnce(userID: id) { (dictionary) in
                let user = User()
                user.set(dictionary: dictionary, id: id)
                
                // I call emptyTableCell twice, which is creating 2x more users (?)
                if self.users.count < self.usersIDList.count {
                    self.users.append(user)
                }
            }
        }
    }
    
    // MARK: UITableViewDelegate functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! UserTableCell
        
        let user = users[indexPath.row]
        cell.user = user
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        delegate?.showUserProfileController(user: user)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
