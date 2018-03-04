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
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(CommunityTableCell.self, forCellReuseIdentifier: identifier)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .background
        tv.alwaysBounceVertical = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.contentInset = UIEdgeInsets(top: 16.0, left: 0, bottom: 0, right: 0)
        tv.separatorStyle = .none
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
            self.partners.append(partner)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return partners.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CommunityTableCell
        
        let partner = partners[indexPath.row]
        cell.dictionary = ["profileImageURL": partner.profileImageURL as Any,
                           "name": partner.name as Any,
                           "field": partner.field as Any,
                           "location": partner.location as Any]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let partner = partners[indexPath.item]
        delegate?.showPartnerPageController(partner: partner)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
