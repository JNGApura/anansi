//
//  NewChatController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 09/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class NewChatController: UITableViewController {

    // Custom initializers
    
    private let cellIdentifier = "TableCell"
    
    var users = [User]()
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarItems()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserTableCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        tableView.rowHeight = 72
        tableView.estimatedRowHeight = 72
        
        // Fetch users
        fetchUsers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = .background
            navigationBar.isTranslucent = false
            
            let titleLabelView = UILabel()
            titleLabelView.text = "New chat"
            titleLabelView.textColor = .secondary
            titleLabelView.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
            navigationItem.titleView = titleLabelView
            
            let barButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissNewChatView))
            barButtonItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: Const.bodyFontSize)], for: .normal)
            barButtonItem.tintColor = .primary
            navigationItem.rightBarButtonItem = barButtonItem
        }
    }
    
    // MARK: Custom functions
    
    private func fetchUsers() {
        
        NetworkManager.shared.fetchUsers { (dictionary, userUID) in
            
            if userUID != NetworkManager.shared.getUID() {
                
                let user = User(dictionary: dictionary, id: userUID)
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func dismissNewChatView(){
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITableViewDelegate functions
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! UserTableCell
        
        let user = users[indexPath.row]
        cell.user = user
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var connectViewController : ConnectViewController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        
        dismiss(animated: true) {
            self.connectViewController?.showChatLogController(user: user)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
