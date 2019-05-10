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

protocol SendsUserBackProtocol {
    func sendsUserback(user: User)
}

class SettingsViewController: UIViewController {
    
    // Custom initializers
    private let identifier = "SettingsCell"
    
    private var items = [SettingsRow]()
    
    private var userEmail : String?
    
    var user: User? {
        didSet {
            if let email = user?.getValue(forField: .email) as? String {
                userEmail = email
            }
        }
    }
    
    let titleLabel : UILabel = {
        let l = UILabel()
        l.text = "Settings"
        l.textColor = .secondary
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        return l
    }()
    
    lazy var dismissButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Dismiss", for: .normal)
        b.setTitleColor(.primary, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        b.backgroundColor = .background
        b.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        return b
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
        t.rowHeight = UITableView.automaticDimension
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = .background
            navigationBar.isTranslucent = false
            
            navigationItem.titleView = titleLabel
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        }
    }
    
    // MARK: Custom functions
    
    private func openURLfromStringInWebViewer(string : String) {
        
        if let url = URL(string: string) {
            
            // Open link inside the app, instead of leaving the app. Needs import SafariServices
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true, completion: nil)
        }
    }
    
    private func presentController(identifier: String){
        
        if identifier == "feedback" {
            let controller = FeedbackPagesViewController() // PageViewController for "Give us feedback"
            controller.user = user
            self.navigationController?.pushViewController(controller, animated: true)
            
        } else if identifier == "basicInfo" {
            let controller = BasicInfoViewController() // PageViewController for editing basic information
            controller.user = user
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
            
        } else {
            let controller = AboutPageView(id: identifier) // About Pages
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func dismissAction() {
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Logout
    
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
                transition.type = CATransitionType.push
                transition.subtype = CATransitionSubtype.fromLeft
                transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeOut)
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
        cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.tertiary.withAlphaComponent(0.5))
        
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
        
        // Logout
        if item.action == "logout" {
            cell.itemTitle.textColor = .primary
            cell.itemIcon.tintColor = .primary
            cell.itemSubtitle.isHidden = false
            cell.itemArrow.isHidden = true
            
            if let email = userEmail {
                cell.itemSubtitle.text = "Signed in as \(String(describing: email))"
            } else {
                cell.itemSubtitle.text = ""
            }
        }
        
        // Made with love
        if indexPath.row == (items.count - 2) {
            cell.itemTitle.font = UIFont.systemFont(ofSize: Const.captionFontSize)
            cell.itemTitle.text = "Made with ❤️ in Lisbon\n\(Bundle.main.releaseVersionBuildPretty)"
            //cell.itemTitle.textAlignment = .center
            
            cell.itemIcon.isHidden = true
            cell.itemArrow.isHidden = true
            cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.background)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        
        if item.action == "link" {
            
            if item.url!.contains("ïnstagram") {
                
                if let url = URL(string: "instagram://user?username=tedxulisboa") {
                    
                    UIApplication.shared.open(url, options: [:]) { (result) in
                        if !result {
                            self.openURLfromStringInWebViewer(string: item.url!)
                        }
                    }
                }
            
            } else {
                openURLfromStringInWebViewer(string: item.url!)
            }
            
        } else if item.action == "view" {
            let url = item.url
            presentController(identifier: url!)
            
        } else if item.action == "logout" {
            handleLogout()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsViewController: SendsUserBackProtocol {
    
    func sendsUserback(user: User) {
        self.user = user
        print("updated user")
    }
}