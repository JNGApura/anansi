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
    
    var sections = [String]()
    var partnersInEachSection = [Int : [Partner]]() {
        didSet {
            tableView.reloadData()
        }
    }
    
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
        i.tintColor = Const.typeColor[sections[section]]
        i.frame = CGRect(x: 16.0, y: 16.0, width: 20.0, height: 20.0)
        
        let l = UILabel()
        l.text = sections[section].uppercased()
        l.textColor = Const.typeColor[sections[section]]
        l.font = UIFont.boldSystemFont(ofSize: Const.subheadFontSize)
        l.frame = CGRect(x: 16.0 + i.frame.width + 8.0, y: 16.0, width: 276.0, height: 20.0)
        
        [i, l].forEach { v.addSubview($0) }
        
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
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        let cell  = tableView.cellForRow(at: indexPath)
        cell!.contentView.backgroundColor = .tertiary
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        
        let cell  = tableView.cellForRow(at: indexPath)
        cell!.contentView.backgroundColor = .clear
    }

}
