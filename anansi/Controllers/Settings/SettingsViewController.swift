//
//  SettingsViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 10/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
//import SafariServices

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    // Custom initializers
    private var tableView = UITableView()
    private var items = [TableRow]()
    private var about = [AboutPage]()
    
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
        
        // Fetches data (JSON) from database, via Network Manager, to Model
        NetworkManager.shared.loadSettingsData { [weak self] settings in
            DispatchQueue.main.async {
                self!.items = settings.structure
                self!.about = settings.about
                self!.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems(title: String) {
        
        let navigationBar = navigationController?.navigationBar
        navigationBar!.barTintColor = Color.background
        navigationBar!.isTranslucent = false
        navigationItem.title = title
        
        // Set custom font for title and right button label
        navigationBar!.titleTextAttributes = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17)]
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17)], for: .normal)
    }
    
    private func setupTableView() {
        
        // Constants
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let navigationBarHeight = (self.navigationController?.navigationBar.frame.size.height)!
        
        tableView.separatorColor = Color.tertiary
        tableView.backgroundColor = Color.tertiary
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
        return indexPath.row == (items.count - 1) ? 66.0 : 44.0
    }
    
    // Customizes cell at specific index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        
        switch item.ofType {
        case .section:
            cell.textLabel?.text = item.value
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            cell.backgroundColor = Color.tertiary
            cell.accessoryView = .none
            cell.selectionStyle = .none
            cell.isMultipleTouchEnabled = false
            cell.isUserInteractionEnabled = false
            
        case .normal:
            cell.textLabel?.text = item.value
            cell.backgroundColor = Color.background
            
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
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                //cell.isUserInteractionEnabled = false
                
            case "popup"?:
                cell.accessoryView = .none
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                cell.textLabel?.textColor = Color.primary

            default:
                cell.accessoryView = .none
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            }
        }
        
        if indexPath.row == (items.count - 1) {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 11)
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
        }
        
        // TO DO: add logout action
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: User Interaction
    
    // Switch action
    @objc func switchChanged(_ sender : UISwitch!){
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        // TO DO: add notification enable/disable mode
    }
    
    // Back action
    @objc func backAction() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Custom functions
    
    // Open URL from a String
    func openURLfromString(string : String) {
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
    func presentController(identifier: String){
        let controller : UIViewController
        
        if identifier == "feedback" {
            controller = FeedbackPagesViewController() // PageViewController for "Give us feedback"
        } else {
            
            // Chooses which section to send to AboutPages, based on item.id
            var aboutSection = [AboutPageSection]()
            for item in about {
                if item.id == identifier {
                    aboutSection = item.section!
                }
            }
            controller = AboutPages(section: aboutSection)
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
