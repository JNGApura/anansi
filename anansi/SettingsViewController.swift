//
//  SettingsViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 08/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
//import SafariServices

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Custom initializers
    var tableView: UITableView = UITableView()
    var data = ["Notifications","Allow notifications","Follow us on social media","Facebook","Instagram","Twitter","Linkedin","About","Give us feedback!","TEDxISTAlameda","Privacy policy","Terms & Conditions","","Log out",""]
    var sectionRows = [0,2,7,12]
    var socialMediaRows = [3,4,5,6]
    var socialMediaImages = ["facebook","instagram","twitter","linkedin"]
    
    
    // MARK: TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        cell.textLabel?.text = data[indexPath.row]
        
        // Creates the UI for the section rows
        if sectionRows.contains(indexPath.row) {
            cell.backgroundColor = UIColor.init(red: 235/255.0, green: 235/255.0, blue: 241/255.0, alpha: 1.0)
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            cell.selectionStyle = .none
            cell.isMultipleTouchEnabled = false
            cell.isUserInteractionEnabled = false
            
            // Creates the UI for the log out row
        } else if indexPath.row == 13 {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            cell.textLabel?.textColor = .red
            
            // Creates the UI for the last row
        } else if indexPath.row == 14 {
            cell.backgroundColor = UIColor.init(red: 235/255.0, green: 235/255.0, blue: 241/255.0, alpha: 1.0)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 11)
            cell.selectionStyle = .none
            cell.isMultipleTouchEnabled = false
            cell.isUserInteractionEnabled = false
            cell.textLabel?.text = "Made with ❤️ in Lisbon\n\(Bundle.main.releaseVersionBuildPretty)"
            cell.textLabel?.formatTextWithLineSpacing(lineSpacing: 8.0, alignment: .center)
            cell.textLabel?.numberOfLines = 0;
            cell.textLabel?.lineBreakMode = .byWordWrapping;
            
            // Creates the UI for all other rows
        } else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        }
        
        // Adds toggle switch to notification row
        if indexPath.row == 1 {
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(false, animated: true)
            switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
            cell.isMultipleTouchEnabled = false
            //cell.isUserInteractionEnabled = false
        }
        
        // Adds icon in social media rows
        if socialMediaRows.contains(indexPath.row){
            
            let imageName = socialMediaImages[indexPath.row - 3]
            let image = UIImage(named: imageName)
            var imageView = UIImageView(image: image!)
            imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0))
            imageView.layer.borderWidth = 1.0
            imageView.layer.masksToBounds = false
            imageView.layer.borderColor = UIColor.white.cgColor
            imageView.layer.cornerRadius = 22.0;
            imageView.clipsToBounds = true
            
            cell.imageView!.image = image
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return indexPath.row == 14 ? 66.0 : 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let socialMediaRows = [3,4,5,6]
        
        // Open social media URLs
        if socialMediaRows.contains(indexPath.row) {
            let url : URL!
            
            switch (indexPath.row - 3) {
            case 0:
                url = URL(string: "https://www.facebook.com/tedxistalameda")
            case 1:
                url = URL(string: "https://www.instagram.com/tedxistalameda")
            case 2:
                url = URL(string: "https://twitter.com/tedxistalameda")
            case 3:
                url = URL(string: "https://www.linkedin.com/company/10585070/")
            default:
                return;
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            
            // Open link inside the app, instead of leaving the app. Needs import SafariServices
            /*let vc = SFSafariViewController(url: url!)
             present(vc, animated: true, completion: nil)*/
            
        }/* else if (indexPath.row == 8) {
            
            if let controller = storyboard!.instantiateViewController(withIdentifier: "FeedbackPageViewController") as? FeedbackPageViewController {
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
        } else if (indexPath.row == 9) {
            
            if let controller = storyboard!.instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController {
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else if (indexPath.row == 10) {
            
            self.navigationController?.pushViewController(PrivacyPolicyViewController(), animated: true)
            
        } else if (indexPath.row == 11) {
            
            self.navigationController?.pushViewController(TermsConditionsViewController(), animated: true)
        }*/
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBar = navigationController?.navigationBar
        navigationBar!.barTintColor = .white
        navigationBar!.isTranslucent = false
        
        let attributesTitle = [
            NSAttributedStringKey.foregroundColor : UIColor.black,
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17),
            ]
        let attributesRightButton = [
            NSAttributedStringKey.foregroundColor : UIColor.red,
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17),
            ]
        navigationItem.title = "Settings"
        navigationController!.navigationBar.titleTextAttributes = attributesTitle
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(attributesRightButton, for: .normal)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 44.0
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.separatorColor = UIColor.init(red: 235/255.0, green: 235/255.0, blue: 241/255.0, alpha: 1.0)
        self.tableView.backgroundColor = UIColor.init(red: 235/255.0, green: 235/255.0, blue: 241/255.0, alpha: 1.0)
        
        self.view.addSubview(self.tableView)
        
        self.tableView.frame = CGRect(x: 0 ,y: 0 , width:self.view.frame.width, height: self.view.frame.height - self.tableView.rowHeight);
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: User Interaction
    @objc func switchChanged(_ sender : UISwitch!){
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
    }
    
    @objc func backAction() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
}
