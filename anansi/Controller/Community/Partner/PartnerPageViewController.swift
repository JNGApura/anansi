//
//  PartnerPageViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class PartnerPageViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, ShowProfileDelegate {
    
    // Custom initializers
    var sections = [String]()
    var sectionDataToDisplay = [Int : [String]]()
    var iconForContactSection = [String]()
    var gradientColors = [UIColor]()
    
    var partner: Partner? {
        didSet {
            
            sections.removeAll()
            sectionDataToDisplay.removeAll()
            iconForContactSection.removeAll()
            
            if let profileImageURL = partner?.profileImageURL {
                
                headerView.profileImage.loadImageUsingCacheWithUrlString(profileImageURL)
            } else {
                
                headerView.profileImage.image = #imageLiteral(resourceName: "profileImageTemplate").withRenderingMode(.alwaysOriginal)
            }
            
            if let name = partner?.name {
                headerView.setTitleName(name: name)
            }
            
            if let field = partner?.field {
                headerView.setOccupation(field)
            }
            
            if let location = partner?.location {
                headerView.setLocation(location)
            }
            
            if let about = partner?.about {
                sections.append("About:")
                let index = sections.count - 1
                sectionDataToDisplay[index] = [about]
            }
            
            if (partner?.employees) != nil {
                sections.append("Get in touch with:")
                let index = sections.count - 1
                sectionDataToDisplay[index] = ["employees are presented here"]
            }
            
            if let website = partner?.website {
                if !sections.contains("Contact information:") {
                    sections.append("Contact information:")
                }
                
                let index = sections.count - 1
                
                if sectionDataToDisplay[index] == nil {
                    sectionDataToDisplay[index] = [website]
                } else {
                    sectionDataToDisplay[index]?.append(website)
                }
                
                iconForContactSection.append("website")
            }
            
            if let linkedin = partner?.linkedin {
                if !sections.contains("Contact information:") {
                    sections.append("Contact information:")
                }
                
                let index = sections.count - 1
                
                if sectionDataToDisplay[index] == nil {
                    sectionDataToDisplay[index] = [linkedin]
                } else {
                    sectionDataToDisplay[index]?.append(linkedin)
                }
                
                iconForContactSection.append("linkedin-black")
            }
            
            if let type = partner?.type {
                
                typeLabel.text = (type + " Partner").uppercased()
                
                partnerTypeView.layer.borderColor = Const.typeColor[type]!.cgColor
                typeLabel.textColor = Const.typeColor[type]
                bannerIcon.tintColor = Const.typeColor[type]
            }
        }
        
    }
    
    lazy var scrollView : UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.backgroundColor = .background
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView : UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // Cover
    let mask = UIImageView(image: #imageLiteral(resourceName: "Mesh-partners").withRenderingMode(.alwaysTemplate))
    
    lazy var backgroundImage: GradientView = {
        let v = GradientView()
        v.mask = mask
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
    
    // Partner type
    let partnerTypeView: UIView = {
        let v = UIView()
        v.layer.borderWidth = 2
        v.layer.cornerRadius = Const.marginEight / 2.0
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let centerView : UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var bannerIcon: UIImageView = {
        let i = UIImageView()
        i.image = #imageLiteral(resourceName: "banner").withRenderingMode(.alwaysTemplate)
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    lazy var typeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.boldSystemFont(ofSize: Const.subheadFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    // Table with profile data
    lazy var tableView : UIDynamicTableView = {
        let tv = UIDynamicTableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "ProfileCell")
        tv.register(EmployeeTableCell.self, forCellReuseIdentifier: "EmployeeTableCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = false
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.allowsSelection = true
        tv.sectionHeaderHeight = 56.0
        tv.estimatedSectionHeaderHeight = 56.0
        tv.estimatedRowHeight = 44.0
        tv.rowHeight = UITableViewAutomaticDimension
        return tv
    }()
    
    lazy var barHeight : CGFloat = (self.navigationController?.navigationBar.frame.height)!
    let statusBarHeight : CGFloat = UIApplication.shared.statusBarFrame.height
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarItems()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [backgroundImage, headerView, partnerTypeView, tableView].forEach { contentView.addSubview($0)}
        
        partnerTypeView.addSubview(centerView)
        [bannerIcon, typeLabel].forEach { centerView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            backgroundImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -(barHeight + statusBarHeight)),
            backgroundImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImage.heightAnchor.constraint(equalToConstant: 318.0),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 234.0),
            
            partnerTypeView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Const.marginEight),
            partnerTypeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Const.marginEight * 2.0),
            partnerTypeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Const.marginEight * 2.0),
            partnerTypeView.heightAnchor.constraint(equalToConstant: 44.0),
            
            centerView.centerYAnchor.constraint(equalTo: partnerTypeView.centerYAnchor),
            centerView.centerXAnchor.constraint(equalTo: partnerTypeView.centerXAnchor),
            centerView.heightAnchor.constraint(equalTo: partnerTypeView.heightAnchor),
            
            bannerIcon.centerYAnchor.constraint(equalTo: centerView.centerYAnchor),
            bannerIcon.leadingAnchor.constraint(equalTo: centerView.leadingAnchor),
            bannerIcon.widthAnchor.constraint(equalToConstant: 20.0),
            bannerIcon.heightAnchor.constraint(equalToConstant: 20.0),
            
            typeLabel.centerYAnchor.constraint(equalTo: centerView.centerYAnchor),
            typeLabel.leadingAnchor.constraint(equalTo: bannerIcon.trailingAnchor, constant: Const.marginEight * 1.5),
            typeLabel.trailingAnchor.constraint(equalTo: centerView.trailingAnchor),
            typeLabel.heightAnchor.constraint(equalToConstant: 20.0),
            
            tableView.topAnchor.constraint(equalTo: partnerTypeView.bottomAnchor, constant: Const.marginEight),
            tableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // I need dispatchQueue because I was getting EXC_BAD_ACCESS code (probably I was adding this when the view was not ready yet)
        DispatchQueue.main.async {
            
            // Sets gradients for backgroundImage and progressBarView
            self.backgroundImage.applyGradient(withColours: [.primary, .primary], gradientOrientation: .topLeftBottomRight)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isTranslucent = true // Sets Nav bar to translucent
        
        // Sets up call-to-action view
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Send +1 to Partner's # visualizations
        NetworkManager.shared.updatesVisualization(id: (self.partner?.id)!, node: "partners")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    func setupNavigationBarItems() {
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .background
        
        navigationItem.title = ""
        
        let backButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "back").withRenderingMode(.alwaysTemplate), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: Const.navButtonHeight, height: Const.navButtonHeight)
            button.tintColor = .primary
            button.backgroundColor = .background
            button.layer.cornerRadius = Const.navButtonHeight / 2.0
            button.layer.masksToBounds = true
            button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
            return button
        }()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    // MARK: Custom functions
    
    func estimateFrameForText(text: String, lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0, hyphenation: Float = 1.0, alignment: NSTextAlignment = .natural) -> CGRect {
        
        let size = CGSize(width: view.frame.width - Const.marginEight * 4.0, height: 10000) // height arbitrarily high
        let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.lineHeightMultiple = lineHeightMultiple
        style.hyphenationFactor = hyphenation
        style.alignment = alignment
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: Const.bodyFontSize), NSAttributedStringKey.paragraphStyle: style], context: nil)
    }
    
    func addReadMoreToLabel(str: String, maxLength: Int) -> NSAttributedString {
        var attributedString = NSMutableAttributedString()
        let index: String.Index = str.index(str.startIndex, offsetBy: maxLength)
        let editedText = String(str.prefix(upTo: index)) + "... "
        let readMoreAttributed = NSMutableAttributedString(string: "Read More", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: Const.bodyFontSize), NSAttributedStringKey.foregroundColor: UIColor.primary])
        
        attributedString = NSMutableAttributedString(string: editedText)
        attributedString.append(readMoreAttributed)
        
        return attributedString
    }
    
    private func openURLfromString(string : String) {
        
        let url = URL(string: string)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc func backAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    func showProfileController(user: User) {
        
        let profileController = ProfileViewController()
        profileController.user = user
        profileController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        
        navigationController?.pushViewController(profileController, animated: true)
    }
    
    // MARK: UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let v = UIView()
        v.backgroundColor = .clear
        
        let l = UILabel(frame: CGRect(x: Const.marginEight * 2.0, y: Const.marginEight * 3.0, width: tableView.frame.width - Const.marginEight * 4.0, height: 32.0))
        l.text = sections[section]
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        l.textColor = .secondary
        v.addSubview(l)
        
        return v
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sectionDataToDisplay[section]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        
        if sections[section] != "Get in touch with:" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
            
            cell.textLabel?.text = sectionDataToDisplay[section]?[indexPath.row]
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
            cell.textLabel?.textColor = .secondary
            
            if sections[section] == "About:" {
                
                cell.textLabel?.attributedText = addReadMoreToLabel(str: (cell.textLabel?.text)!, maxLength: 180)
                cell.textLabel?.formatTextWithLineSpacing(lineSpacing: 6, lineHeightMultiple: 1.05, hyphenation: 0.5, alignment: .left)
            }
            
            if sections[section] == "Contact information:" && (sectionDataToDisplay[section]?.count == iconForContactSection.count){
                cell.textLabel?.numberOfLines = 1
                cell.imageView!.image = UIImage(named: iconForContactSection[indexPath.row] as String)
            } else {
                cell.imageView!.image = nil
            }
                        
            return cell
        } else {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeTableCell", for: indexPath) as? EmployeeTableCell {
                
                let employeeList = (partner?.employees)!
                
                cell.delegate = self
                cell.usersIDList = employeeList
                cell.employeeTableViewHeightAnchor?.constant = 72 * CGFloat(employeeList.count)
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = indexPath.section
        
        if sections[section] == "About:" {
            
            // Open new about controller
            let aboutController = PartnerAboutController()
            aboutController.about = (partner?.about)!
            aboutController.titleLabelView.text = (partner?.name)!
            
            self.navigationController?.pushViewController(aboutController, animated: true)
        
        } else if sections[section] == "Contact information:" {
            
            let row = indexPath.row
            openURLfromString(string: "https://\(sectionDataToDisplay[section]![row])")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Only allows selection of certain cells
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        let section = indexPath.section
        if sections[section] == "About:" || sections[section] == "Contact information:" {
            return indexPath
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        let section = indexPath.section
        if sections[section] == "About:" || sections[section] == "Contact information:" {
            return true
        }
        
        return false
    }
    
    // MARK: ScrollViewDidScroll function
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let topDistance = barHeight + statusBarHeight
        let offsetY : CGFloat = scrollView.contentOffset.y
        
        // Zooms out image when scrolled down
        if  offsetY + topDistance < 0 {
            let zoomRatio = (-(offsetY + topDistance) * 0.0065) + 1.0
            backgroundImage.transform = CGAffineTransform(scaleX: zoomRatio, y: zoomRatio)
            
        } else {
            backgroundImage.transform = CGAffineTransform.identity
        }
        backgroundImage.layoutIfNeeded()
    }
}
