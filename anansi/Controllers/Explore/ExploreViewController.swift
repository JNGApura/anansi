//
//  ExploreViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 08/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ExploreViewController: UITableViewController {
    
    let cellIdentifier = "cellId"

    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Update navigation bar
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellIdentifier)
        
        // Fetch users
        fetchUsers()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchUsers() {
        
        NetworkManager.shared.fetchUserData { (dictionary) in
            
            let user = User()
            let email = dictionary["email"] as? String ?? ""
            let ticketReference = dictionary["ticket"] as? String ?? ""
            let profileImage = dictionary["profileImageURL"] as? String ?? ""
            
            user.email = email
            user.ticketReference = ticketReference
            user.profileImageURL = profileImage
            self.users.append(user)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.email
        cell.detailTextLabel?.text = user.ticketReference
        
        if let profileImageURL = user.profileImageURL {
            if profileImageURL.isEmpty {
                cell.profileImageView.image = #imageLiteral(resourceName: "profileImageTemplate").withRenderingMode(.alwaysOriginal)
            } else {
                cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageURL)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
}

class UserCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: Const.exploreImageHeight + 2 * Const.marginEight, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: Const.exploreImageHeight + 2 * Const.marginEight, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = Const.exploreImageHeight / 2
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: Const.exploreImageHeight),
            profileImageView.heightAnchor.constraint(equalToConstant: Const.exploreImageHeight)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
