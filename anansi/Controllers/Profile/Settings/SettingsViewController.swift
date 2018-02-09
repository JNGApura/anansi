//
//  SettingsViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 10/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import ReachabilitySwift
//import SafariServices

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Custom initializers
    private var tableView = UITableView()
    private var items = [SettingsRow]()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up navigation bar
        setupNavigationBarItems(title: "Settings")
        
        // Initialize tableView
        setupTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Adds table to view
        view.addSubview(tableView)
        
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
    
    private func setupNavigationBarItems(title: String) {
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = .background
            navigationBar.isTranslucent = false
            navigationItem.title = title
            
            // Set custom font for title and right button label
            navigationBar.titleTextAttributes = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: Const.bodyFontSize)]
            navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: Const.bodyFontSize)], for: .normal)}
    }
    
    private func setupTableView() {
        
        // Constants
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let navigationBarHeight = (self.navigationController?.navigationBar.frame.size.height)!
        
        tableView.separatorColor = .tertiary
        tableView.backgroundColor = .tertiary
        tableView.frame = CGRect(x: 0 ,y: 0 , width: screenWidth, height: screenHeight - statusBarHeight - navigationBarHeight);
    }
    
    // MARK: TableViewDataSource
    
    // Table only has one section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Sets number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // Set row height - all rows have 44.0, expect the last one
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == (items.count - 1) ? Const.settingsRowHeight*1.5 : Const.settingsRowHeight
    }
    
    // Customizes cell at specific index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        
        switch item.ofType {
        case .section:
            cell.textLabel?.text = item.value
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: Const.subheadFontSize)
            cell.backgroundColor = .tertiary
            cell.accessoryView = .none
            cell.selectionStyle = .none
            cell.isMultipleTouchEnabled = false
            cell.isUserInteractionEnabled = false
            
        case .normal:
            cell.textLabel?.text = item.value
            cell.backgroundColor = .background
            
            if !item.iconUrl!.isEmpty {
                if let image = UIImage(named: item.iconUrl!) {
                    cell.imageView!.image = image
                }
            } else {
                cell.imageView!.image = nil
            }
            
            switch item.action {
            case "toggle"?:
                let switchView = UISwitch(frame: .zero)
                switchView.setOn(false, animated: true)
                switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
                cell.accessoryView = switchView
                cell.selectionStyle = .none
                cell.isMultipleTouchEnabled = false
                cell.textLabel?.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
                //cell.isUserInteractionEnabled = false
                
            case "popup"?:
                cell.accessoryView = .none
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: Const.subheadFontSize)
                cell.textLabel?.textColor = .primary

            default:
                cell.accessoryView = .none
                cell.textLabel?.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
            }
        }
        
        if indexPath.row == (items.count - 1) {
            cell.textLabel?.font = UIFont.systemFont(ofSize: Const.captionFontSize)
            cell.textLabel?.text = "Made with ❤️ in Lisbon\n\(Bundle.main.releaseVersionBuildPretty)"
            cell.textLabel?.formatTextWithLineSpacing(lineSpacing: 8.0, alignment: .center)
            cell.textLabel?.numberOfLines = 0;
            cell.textLabel?.lineBreakMode = .byWordWrapping;
        }
        return cell
    }
    
    // Sets action for row at specific index
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        
        // Action is "link", then the URL should be opened
        if item.action == "link" {
            openURLfromString(string: item.url!)
        
        // Action is "view", then view controller should be pushed
        } else if item.action == "view" {
            let url = item.url
            presentController(identifier: url!)
        } else if item.action == "popup" {
            handleLogout()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: User Interaction
    
    // Switch action
    @objc func switchChanged(_ sender : UISwitch!){
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        // TO DO: add notification enable/disable mode
    }
    
    // MARK: Custom functions
    
    // Open URL from a String
    private func openURLfromString(string : String) {
        
        let url = URL(string: string)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
        // Open link inside the app, instead of leaving the app. Needs import SafariServices
        /*let vc = SFSafariViewController(url: url)
         present(vc, animated: true, completion: nil)*/
    }
    
    // Presents view controller from string (did a few tweaks here and there)
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
        
        // Presents an alert to the user informing the network is unreachable
        if !ReachabilityManager.shared.reachability.isReachable {
            
            let alertController = UIAlertController(title: "No internet connection", message: "It seems you are not connected to the internet. Please enable Wifi or Cellular data, and try again.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Got it!", style: .default, handler: nil)
            alertController.addAction(ok)
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
