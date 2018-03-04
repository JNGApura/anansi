//
//  PartnerCommunityCollectionViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

protocol ShowPartnerPageDelegate: class {
    func showPartnerPageController(partner: Partner)
}

class PartnerCommunityCollectionViewController: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {

    // Custom Initializers
    
    let identifier = "PartnerTableCell"
    
    var delegate: ShowPartnerPageDelegate?
    
    var partners : [Partner] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var sections = [String]()
    var partnersInEachSection = [Int : [Partner]]()
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.register(CommunityTableCell.self, forCellReuseIdentifier: identifier)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .background
        tv.alwaysBounceVertical = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        //tv.contentInset = UIEdgeInsets(top: 16.0, left: 0, bottom: 0, right: 0)
        tv.separatorStyle = .none
        tv.sectionHeaderHeight = 36.0
        tv.estimatedSectionHeaderHeight = 36.0
        tv.rowHeight = 96
        tv.estimatedRowHeight = 96
        return tv
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        fetchPartners()
        
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Network
    
    func fetchPartners() {
        
        NetworkManager.shared.fetchPartners { (dictionary, partnerID) in
            let partner = Partner(dictionary: dictionary, id: partnerID)
            
            // Sorts partners by their type of partnership
            if let type = partner.type {
                
                if !self.sections.contains(type) {
                    
                    self.sections.append(type)
                    self.partnersInEachSection[self.sections.count - 1] = [partner]
                } else {
                    
                    self.partnersInEachSection[self.sections.count - 1]?.append(partner)
                }
            }
            
            self.partners.append(partner)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (partnersInEachSection[section]?.count)!
    }
    
    /*func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        header.textLabel?.textColor = .secondary
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: Const.subheadFontSize)
        header.textLabel?.frame = header.frame
    }*/
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let v = UIView()
        v.backgroundColor = .clear
        
        let i = UIImageView(image: #imageLiteral(resourceName: "banner").withRenderingMode(.alwaysTemplate))
        i.frame = CGRect(x: 16.0, y: 16.0, width: 20.0, height: 20.0)
        
        let l = UILabel()
        l.text = sections[section].uppercased()
        l.font = UIFont.boldSystemFont(ofSize: Const.subheadFontSize)
        l.frame = CGRect(x: 16.0 + i.frame.width + 8.0, y: 16.0, width: 276.0, height: 20.0)
        
        [i, l].forEach { v.addSubview($0) }
        
        switch sections[section] {
        case "Institutional":
            l.textColor = UIColor.init(red: 0/255.0, green: 161/255.0, blue: 224/255.0, alpha: 1.0)
            i.tintColor = UIColor.init(red: 0/255.0, green: 161/255.0, blue: 224/255.0, alpha: 1.0)
        
        case "Main":
            l.textColor = .primary
            i.tintColor = .primary
        
        case "Strategy":
            l.textColor = .secondary //UIColor.init(red: 156/255.0, green: 113/255.0, blue: 194/255.0, alpha: 1.0)
            i.tintColor = .secondary //UIColor.init(red: 156/255.0, green: 113/255.0, blue: 194/255.0, alpha: 1.0)
        
        case "Gold":
            l.textColor = UIColor.init(red: 245/255.0, green: 220/255.0, blue: 55/255.0, alpha: 1.0)
            i.tintColor = UIColor.init(red: 245/255.0, green: 220/255.0, blue: 55/255.0, alpha: 1.0)
        
        case "Silver":
            l.textColor = UIColor.init(red: 211/255.0, green: 215/255.0, blue: 222/255.0, alpha: 1.0)
            i.tintColor = UIColor.init(red: 211/255.0, green: 215/255.0, blue: 222/255.0, alpha: 1.0)
        
        case "Bronze":
            l.textColor = UIColor.init(red: 137/255.0, green: 56/255.0, blue: 19/255.0, alpha: 1.0)
            i.tintColor = UIColor.init(red: 137/255.0, green: 56/255.0, blue: 19/255.0, alpha: 1.0)
            
        case "Food & Beverage":
            l.textColor = UIColor.init(red: 113/255.0, green: 176/255.0, blue: 65/255.0, alpha: 1.0)
            i.tintColor = UIColor.init(red: 113/255.0, green: 176/255.0, blue: 65/255.0, alpha: 1.0)
            
        default:
            l.textColor = .secondary
            i.tintColor = .secondary
        }
        
        return v
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CommunityTableCell
        
        let partner = (partnersInEachSection[indexPath.section]?[indexPath.row])!
        cell.dictionary = ["profileImageURL": partner.profileImageURL as Any,
                           "name": partner.name as Any,
                           "field": partner.field as Any,
                           "location": partner.location as Any]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let partner = (partnersInEachSection[indexPath.section]?[indexPath.row])!
        delegate?.showPartnerPageController(partner: partner)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
