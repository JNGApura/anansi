//
//  SettingsViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 10/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import ReachabilitySwift
import SafariServices

class SettingsViewController: UIViewController {
    
    // Custom initializers
    private let identifier = "SettingsCell"
    
    private var items = [SettingsRow]()
    
    let titleLabel : UILabel = {
        let l = UILabel()
        l.text = "Settings"
        l.textColor = .secondary
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        return l
    }()
    
    lazy var tableView : UITableView = {
        let t = UITableView()
        t.register(SettingsTableViewCell.self, forCellReuseIdentifier: identifier)
        t.delegate = self
        t.dataSource = self
        t.alwaysBounceVertical = true
        t.separatorColor = .clear
        t.backgroundColor = .background
        t.translatesAutoresizingMaskIntoConstraints = false
        t.estimatedRowHeight = 72.0
        t.rowHeight = UITableViewAutomaticDimension
        t.showsVerticalScrollIndicator = false
        return t
    }()

    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarItems()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        
        // Fetches data from settings.JSON
        if let data = dataFromFile("settings") {
            if let settings = Settings(data: data) {
                items = settings.structure
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = .background
            navigationBar.isTranslucent = false
            
            navigationItem.titleView = titleLabel
        }
    }
    
    // MARK: Custom functions
    
    private func openURLfromStringInWebViewer(string : String) {
        
        let url = URL(string: string)!
        
        // Open link inside the app, instead of leaving the app. Needs import SafariServices
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
    private func presentController(identifier: String){
        let controller : UIViewController
        
        if identifier == "feedback" {
            controller = FeedbackPagesViewController() // PageViewController for "Give us feedback"
            
        } else {
            controller = AboutPageView(id: identifier) // About Pages
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    // Handles logout
    private func handleLogout() {
        
        // When network is unreachable
        if !ReachabilityManager.shared.reachability.isReachable {
            
            let alertController = UIAlertController(title: "No internet connection", message: "It seems you are not connected to the internet. Please enable Wifi or Cellular data, and try again.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        NetworkManager.shared.logout {
            
            DispatchQueue.main.async {
                // Sets transition animation
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromLeft
                transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
                self.view.window!.layer.add(transition, forKey: kCATransition)
                
                let loginController = SignUpController()
                self.present(loginController, animated: false, completion: nil)
            }
        }
    }
}

// MARK: TableViewDataSource

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath as IndexPath) as! SettingsTableViewCell
        cell.selectionStyle = .none
        
        // Title
        cell.itemTitle.text = item.title
        
        // Icon
        if !(item.icon!.isEmpty) {
            if let image = UIImage(named: item.icon!) {
                cell.itemIcon.image = image
            }
        } else {
            cell.itemIcon.image = nil
        }
        
        // Made with love
        if indexPath.row == (items.count - 2) {
            cell.itemTitle.font = UIFont.systemFont(ofSize: Const.captionFontSize)
            cell.itemTitle.text = "Made with ❤️ in Lisbon\n\(Bundle.main.releaseVersionBuildPretty)"
            //cell.itemTitle.textAlignment = .center
            
            cell.itemIcon.isHidden = true
            cell.itemArrow.isHidden = true
        }
        
        // Logout
        if item.action == "logout" {
            cell.itemTitle.textColor = .primary
            cell.itemIcon.tintColor = .primary
            cell.itemSubtitle.text = "Signed in as X"
            cell.itemSubtitle.isHidden = false
            cell.itemArrow.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        
        if item.action == "link" {
            openURLfromStringInWebViewer(string: item.url!)
        
        } else if item.action == "view" {
            let url = item.url
            presentController(identifier: url!)
            
        } else if item.action == "logout" {
            handleLogout()
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        let cell  = tableView.cellForRow(at: indexPath)
        
        if indexPath.row != (items.count - 2) {
            cell!.contentView.backgroundColor = .tertiary
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        
        let cell  = tableView.cellForRow(at: indexPath)
        cell!.contentView.backgroundColor = .clear
    }
}
