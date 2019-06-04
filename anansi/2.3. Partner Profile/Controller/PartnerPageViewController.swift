//
//  PartnerPageViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import SafariServices

class PartnerPageViewController: UIViewController {
    
    // Custom initializers
    var cameFromCommunity: Bool = false

    var sections = [String]()
    
    var sectionDataToDisplay = [Int : [String]]()
    
    var iconForContactSection = [String]()
    
    var partner: Partner? {
        didSet {
            
            sections.removeAll()
            sectionDataToDisplay.removeAll()
            iconForContactSection.removeAll()
            
            if let picURL = partner?.getValue(forField: .profileImageURL) as? String {
                
                headerView.profileImage.setImage(with: picURL)
            } else {
                
                headerView.profileImage.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
            }
            
            if let name = partner?.getValue(forField: .name) as? String {
                topbar.setTitle(name: name)
                topbar.titleLabel.alpha = 0.0
                
                headerView.setTitleName(name: name)
            }
            
            if let field = partner?.getValue(forField: .field) as? String  {
                headerView.setOccupation(field)
            }
            
            if let location = partner?.getValue(forField: .location) as? String  {
                headerView.setLocation(location)
            }
            
            if let about = partner?.getValue(forField: .about) as? String  {
                sections.append((partner?.label(forField: .about))!)
                let index = sections.count - 1
                sectionDataToDisplay[index] = [about]
            }
            
            if (partner?.getValue(forField: .employees) as? [String]) != nil {
                sections.append((partner?.label(forField: .employees))!)
                let index = sections.count - 1
                sectionDataToDisplay[index] = ["employees are presented here"]
            }
            
            if let website = partner?.getValue(forField: .website) as? String {
                if !sections.contains("Contact information") { sections.append("Contact information") }

                let index = sections.count - 1
                
                if sectionDataToDisplay[index] == nil {
                    sectionDataToDisplay[index] = [website]
                } else {
                    sectionDataToDisplay[index]?.append(website)
                }
                
                iconForContactSection.append("website")
            }
            
            if let linkedin = partner?.getValue(forField: .linkedin) as? String {
                if !sections.contains("Contact information") { sections.append("Contact information") }
                
                let index = sections.count - 1
                
                if sectionDataToDisplay[index] == nil {
                    sectionDataToDisplay[index] = [linkedin]
                } else {
                    sectionDataToDisplay[index]?.append(linkedin)
                }
                
                iconForContactSection.append("linkedin")
            }
            
            if let type = partner?.getValue(forField: .type) as? String {
                
                partnerCard.setTitle((" " + type + Const.mapPartner[type]! + " Partner").uppercased(), for: .normal)
                partnerCard.backgroundColor = Const.typeColor[type]
            }
            
            tableView.reloadData()
            tableView.layoutIfNeeded()
        }
    }
    
    // NavBar
    
    lazy var topbar: TopBar = {
        let b = TopBar()
        b.setTitle(name: "")
        b.backgroundColor = .clear
        b.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // View
    
    lazy var scrollView : UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.backgroundColor = .background
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView : UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // Cover
    
    lazy var backgroundImage: GradientView = {
        let v = GradientView()
        v.mask = UIImageView(image: UIImage(named: "cover-partners")?.withRenderingMode(.alwaysTemplate))
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // Header
    lazy var headerView : ProfileHeader = {
        let hv = ProfileHeader()
        hv.setTitleColor(textColor: .secondary)
        hv.setBottomBorderColor(lineColor: .primary)
        hv.translatesAutoresizingMaskIntoConstraints = false
        return hv
    }()
    
    // Partner card
    lazy var partnerCard : UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named: "Partners")?.withRenderingMode(.alwaysTemplate), for: .normal)
        b.setTitle("Partner", for: .normal)
        b.setTitleColor(.background, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        b.imageView?.tintColor = .background
        b.contentHorizontalAlignment = .center
        b.layer.cornerRadius = Const.marginEight / 2.0
        b.layer.masksToBounds = true
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isEnabled = false
        b.adjustsImageWhenDisabled = false
        return b
    }()
    
    // Table with profile data
    lazy var tableView : UIDynamicTableView = {
        let tv = UIDynamicTableView()
        tv.register(DescriptionTableViewCell.self, forCellReuseIdentifier: "AboutCell")
        tv.register(EmployeeTableCell.self, forCellReuseIdentifier: "EmployeeCell")
        tv.register(ContactInfoTableViewCell.self, forCellReuseIdentifier: "ContactCell")
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.allowsSelection = true
        tv.sectionHeaderHeight = 56.0
        tv.estimatedSectionHeaderHeight = 56.0
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 600.0
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    lazy var barHeight : CGFloat = (self.navigationController?.navigationBar.frame.height)!
    let statusBarHeight : CGFloat = UIApplication.shared.statusBarFrame.height
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the UI
        [scrollView, topbar].forEach { view.addSubview($0) }
        scrollView.addSubview(contentView)
        [backgroundImage, headerView, partnerCard, tableView].forEach { contentView.addSubview($0)}
        
        NSLayoutConstraint.activate([
            
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            backgroundImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -statusBarHeight),
            backgroundImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImage.heightAnchor.constraint(equalToConstant: 374.0),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: statusBarHeight),
            headerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 214.0),
            
            // Partner card
        
            partnerCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Const.marginSafeArea),
            partnerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Const.marginSafeArea),
            partnerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Const.marginSafeArea),
            partnerCard.heightAnchor.constraint(equalToConstant: 40.0),
            
            // Tableview
            
            tableView.topAnchor.constraint(equalTo: partnerCard.bottomAnchor, constant: Const.marginEight),
            tableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
        
        super.viewWillAppear(animated)
        
        setupNavigationBarItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupNavigationBarItems()
        
        // Logs partner visualizations
        if let id = partner?.getValue(forField: .id) as? String {
            NetworkManager.shared.logEvent(name: "partner_\(String(describing: id))_tap", parameters: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        // Navigation Bar was hidden in viewDidAppear
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topbar.setLargerBackButton()
        topbar.setStatusBarHeight(with: statusBarHeight)
        topbar.setNavigationBarHeight(with: barHeight)
        
        NSLayoutConstraint.activate([
            
            // Navbar
            
            topbar.topAnchor.constraint(equalTo: view.topAnchor),
            topbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topbar.heightAnchor.constraint(equalToConstant: barHeight + statusBarHeight),
            
        ])
        
        // I need dispatchQueue because I was getting EXC_BAD_ACCESS code (probably I was adding this when the view was not ready yet)
        DispatchQueue.main.async {
            
            // Sets gradients for backgroundImage and progressBarView
            if let type = self.partner?.getValue(forField: .type) as? String {
                self.backgroundImage.applyGradient(withColours: [Const.typeColor[type] ?? .primary, Const.typeColor[type] ?? .primary], gradientOrientation: .vertical)
            } else {
                self.backgroundImage.applyGradient(withColours: [.primary, .primary], gradientOrientation: .vertical)
            }
        }
        
        tableView.reloadData()
    }
    
    private func setupNavigationBarItems() {
        
        //navigationItem.titleView = nil
        //navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: Custom functions
    
    private func openURLfromStringInWebViewer(string : String) {
        
        if let url = URL(string: string) {
                
            // Open link inside the app, instead of leaving the app. Needs import SafariServices
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func back() {

        navigationController?.popViewController(animated: true)
    }
}

// MARK: UITableViewDelegate

extension PartnerPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let v : UIView =  {
            let v = UIView()
            v.backgroundColor = .clear
            return v
        }()
        
        let l : UILabel = {
            let l = UILabel()
            l.text = sections[section]
            l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
            l.textColor = .secondary
            l.translatesAutoresizingMaskIntoConstraints = false
            return l
        }()
        
        v.addSubview(l)
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .leading, relatedBy: .equal, toItem: v, attribute: .leading, multiplier: 1.0, constant: 24.0))
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .trailing, relatedBy: .equal, toItem: v, attribute: .trailing, multiplier: 1.0, constant: -24.0))
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .top, relatedBy: .equal, toItem: v, attribute: .top, multiplier: 1.0, constant: 24.0))
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .bottom, relatedBy: .equal, toItem: v, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        return v
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sectionDataToDisplay[section]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        
        if sections[section] == "Get in touch with" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath) as! EmployeeTableCell
            let employeeList = (partner?.getValue(forField: .employees) as? [String])!
            
            cell.delegate = self
            cell.usersIDList = employeeList
            cell.employeeTableViewHeightAnchor?.constant = 72 * CGFloat(employeeList.count)
            
            cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.tertiary.withAlphaComponent(0.5))
            return cell
        
        } else if sections[section] == "Contact information" && (sectionDataToDisplay[section]?.count == iconForContactSection.count) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactInfoTableViewCell
            
            cell.itemTitle.text = sectionDataToDisplay[section]?[indexPath.row]
            cell.itemIcon.image = UIImage(named: iconForContactSection[indexPath.row] as String)?.withRenderingMode(.alwaysTemplate)
            
            cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.tertiary.withAlphaComponent(0.5))
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath) as! DescriptionTableViewCell
            
            cell.itemDescription.text = sectionDataToDisplay[section]?[indexPath.row]
            cell.itemDescription.formatTextWithLineSpacing(lineSpacing: 6, lineHeightMultiple: 1.05, hyphenation: 0.5, alignment: .left)
            
            cell.selectedBackgroundView = createViewWithBackgroundColor(.background)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = indexPath.section
        let row = indexPath.row
        let URLstring = sectionDataToDisplay[section]![row]
        
        if sections[section] == "Contact information" {
            
            if URLstring.contains("linkedin.com/") {
                
                let companyID = URLstring[URLstring.range(of: "linkedin.com/company/")!.upperBound...]
                if let url = URL(string: "linkedin://company/\(companyID)") {
                    
                    UIApplication.shared.open(url, options: [:]) { (result) in
                        if !result {
                            self.openURLfromStringInWebViewer(string: "https://\(URLstring)")
                        }
                    }
                    return
                }
                
            } else {
                openURLfromStringInWebViewer(string: "https://\(URLstring)")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Only allows selection of certain cells
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        let section = indexPath.section
        if sections[section] == "Contact information" {
            return indexPath
        }
        
        return nil
    }
}

// MARK: - ScrollViewDidScroll

extension PartnerPageViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let topDistance : CGFloat = statusBarHeight //+ barHeight
        let offsetY : CGFloat = scrollView.contentOffset.y
        
        // Zooms out image when scrolled down
        if  offsetY + topDistance < 0 {
            let zoomRatio = (-(offsetY + topDistance) * 0.0065) + 1.0
            backgroundImage.transform = CGAffineTransform(scaleX: zoomRatio, y: zoomRatio)
            
            topbar.statusbar.alpha = 0.0
            topbar.navigationbar.alpha = 0.0
            topbar.titleLabel.alpha = 0.0
            
        } else {
            
            let delta = headerView.profileImage.frame.maxY == 0.0 ? 1.0 : (headerView.profileImage.frame.maxY - (offsetY + topDistance)) / headerView.profileImage.frame.maxY
            
            topbar.statusbar.alpha = delta <= 1.0 ? 1.0 - delta : 1.0
            topbar.navigationbar.alpha = delta <= 1.0 ? 1.0 - delta : 1.0
            topbar.titleLabel.alpha = delta <= 1.0 ? 1.0 - delta : 1.0
            
            backgroundImage.transform = CGAffineTransform.identity
        }
        
        backgroundImage.layoutIfNeeded()
    }
}

// MARK: - ShowProfileDelegate

extension PartnerPageViewController: ShowUserProfileDelegate {
    
    func showUserProfileController(user: User) {
        
        let userProfile = UserPageViewController()
        userProfile.user = user
        
        navigationController?.pushViewController(userProfile, animated: true)
    }
}
