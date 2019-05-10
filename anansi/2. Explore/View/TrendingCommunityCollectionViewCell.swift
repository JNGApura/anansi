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
    
    var users = [User]() {
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
        cell.imageView?.kf.cancelDownloadTask() // cancel download task, if there's any
        
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell")
        cell?.imageView?.kf.cancelDownloadTask()
    }
}
