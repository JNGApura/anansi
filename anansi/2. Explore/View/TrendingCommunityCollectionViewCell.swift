//
//  TrendingCommunityCollectionViewCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 10/05/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class TrendingCommunityCollectionViewCell: UICollectionViewCell {
    
    // Custom Initializers
    
    var delegate: ShowUserProfileDelegate?
    weak var communityViewController: CommunityViewController?
    
    var users = [User]() {
        didSet {
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
        tv.contentInset = UIEdgeInsets(top: 8.0, left: 0, bottom: Const.marginSafeArea, right: 0)
        tv.separatorStyle = .none
        tv.rowHeight = 96
        tv.estimatedRowHeight = 96
        return tv
    }()
    
    // Spinner shown during load
    let spinner : UIActivityIndicatorView = {
        let s = UIActivityIndicatorView()
        s.color = .primary
        s.startAnimating()
        s.hidesWhenStopped = true
        return s
    }()
    
    // Refresh view
    lazy var refreshControl : UIRefreshControl = {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.primary]
        let c = UIRefreshControl()
        c.tintColor = .primary
        c.backgroundColor = .clear
        c.addTarget(self, action: #selector(fetchTrendingUsers), for: .valueChanged)
        c.attributedTitle = NSAttributedString(string: "Just a second... ⌛", attributes: attributes)
        return c
    }()
    
    @objc func fetchTrendingUsers() {
        
        if !(communityViewController!.reachability.isReachable) {
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.primary]
            refreshControl.attributedTitle = NSAttributedString(string: "No internet connection 😳", attributes: attributes)
        } else {
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.primary]
            refreshControl.attributedTitle = NSAttributedString(string: "Just a second... ⌛", attributes: attributes)
        }
        
        communityViewController!.fetchTrendingUsers {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                
                self.users = self.communityViewController!.trendingUsers
                
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            })
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView.refreshControl = refreshControl
        addSubview(tableView)
        
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

extension TrendingCommunityCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if users.count == 0 {
            tableView.backgroundView = spinner
        } else {
            tableView.backgroundView = nil
            spinner.stopAnimating()
        }
        return users.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell", for: indexPath) as! CommunityTableCell
        cell.profileImageView.kf.cancelDownloadTask() // cancel download task, if there's any
        
        let user = users[indexPath.row]
        
        if let name = user.getValue(forField: .name) as? String { cell.name.text = name }
        if let occupation = user.getValue(forField: .occupation) as? String { cell.field.text = occupation }
        if let location = user.getValue(forField: .location) as? String { cell.location.text = "From \(location)" }
        if let profileImageURL = user.getValue(forField: .profileImageURL) as? String { cell.profileImageURL = profileImageURL }
        
        cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.tertiary.withAlphaComponent(0.5))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        delegate?.showUserProfileController(user: user)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell") as! CommunityTableCell
        cell.profileImageView.kf.cancelDownloadTask()
    }
}
