//
//  PartnerCommunityCollectionViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import Kingfisher

protocol ShowPartnerPageDelegate: class {
    func showPartnerPageController(partner: Partner)
}

class PartnerCommunityCollectionViewController: UICollectionViewCell {

    // Custom Initializers
    
    let identifier = "PartnerTableCell"
    
    var delegate: ShowPartnerPageDelegate?
    
    var sections = [String]()
    var partnersInEachSection = [String : [Partner]]() {
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
        tv.separatorStyle = .none
        tv.sectionHeaderHeight = 56.0
        tv.estimatedSectionHeaderHeight = 56.0
        tv.rowHeight = 96.0
        tv.estimatedRowHeight = UITableView.automaticDimension
        return tv
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        fetchPartners {
            
            self.addSubview(self.tableView)
            NSLayoutConstraint.activate([
                self.tableView.topAnchor.constraint(equalTo: self.topAnchor),
                self.tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                self.tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                self.tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ])
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Network
    
    func fetchPartners(onSuccess: @escaping () -> Void) {
        
        NetworkManager.shared.fetchPartners { (dictionary, partnerID) in
            
            let partner = Partner()
            partner.set(dictionary: dictionary, id: partnerID)
            
            // Sorts partners by their type of partnership
            if let type = partner.getValue(forField: .type) as? String {
                
                if !self.sections.contains(type) {
                    
                    self.sections.append(type)
                    self.partnersInEachSection[type] = [partner]
                    
                    // sorting
                    self.sections.sort { (lhs, rhs) -> Bool in
                        (Const.typePartners.index(of: lhs) ?? 0) < (Const.typePartners.index(of: rhs) ?? 0)
                    }
                                        
                } else {
                    
                    self.partnersInEachSection[type]?.append(partner)
                }
            }
            
            onSuccess()
        }
    }
}

// MARK: - UITableViewDelegate

extension PartnerCommunityCollectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let type = sections[section]
        return (partnersInEachSection[type]?.count)!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let v = UIView()
        v.backgroundColor = .background
        
        let i = UIImageView(image: UIImage(named: "Star")?.withRenderingMode(.alwaysTemplate))
        i.contentMode = .scaleAspectFit
        i.tintColor = Const.typeColor[sections[section]]
        i.translatesAutoresizingMaskIntoConstraints = false
        
        let t = UILabel()
        t.text = sections[section].uppercased()
        t.textColor = Const.typeColor[sections[section]]
        t.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        t.translatesAutoresizingMaskIntoConstraints = false
        
        let l = UIView()
        l.backgroundColor = .tertiary
        l.translatesAutoresizingMaskIntoConstraints = false
        
        v.addSubview(i)
        v.addSubview(t)
        v.addSubview(l)

        v.addConstraint(NSLayoutConstraint(item: i, attribute: .leading, relatedBy: .equal, toItem: v, attribute: .leading, multiplier: 1.0, constant: 24.0))
        v.addConstraint(NSLayoutConstraint(item: t, attribute: .leading, relatedBy: .equal, toItem: i, attribute: .trailing, multiplier: 1.0, constant: 8.0))
        v.addConstraint(NSLayoutConstraint(item: i, attribute: .centerY, relatedBy: .equal, toItem: t, attribute: .centerY, multiplier: 1.0, constant: -2.0))
        v.addConstraint(NSLayoutConstraint(item: i, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24.0))
        v.addConstraint(NSLayoutConstraint(item: t, attribute: .trailing, relatedBy: .equal, toItem: l, attribute: .leading, multiplier: 1.0, constant: -16.0))
        v.addConstraint(NSLayoutConstraint(item: t, attribute: .top, relatedBy: .equal, toItem: v, attribute: .top, multiplier: 1.0, constant: 6.0))
        v.addConstraint(NSLayoutConstraint(item: t, attribute: .bottom, relatedBy: .equal, toItem: v, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .trailing, relatedBy: .equal, toItem: v, attribute: .trailing, multiplier: 1.0, constant: -24.0))
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0))
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .centerY, relatedBy: .equal, toItem: t, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        return v
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CommunityTableCell
        
        let type = sections[indexPath.section]
        if let partner = (partnersInEachSection[type]?[indexPath.row]) {
        
            if let name = partner.getValue(forField: .name) as? String { cell.name.text = name }
            if let field = partner.getValue(forField: .field) as? String { cell.field.text = field }
            if let location = partner.getValue(forField: .location) as? String { cell.location.text = location }
            if let profileImageURL = partner.getValue(forField: .profileImageURL) as? String { cell.profileImageURL = profileImageURL }
        }
        
        cell.selectedBackgroundView = createViewWithBackgroundColor(UIColor.tertiary.withAlphaComponent(0.5))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let type = sections[indexPath.section]
        let partner = (partnersInEachSection[type]?[indexPath.row])!
        delegate?.showPartnerPageController(partner: partner)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
