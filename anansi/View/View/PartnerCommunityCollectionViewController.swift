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
    
    var partnerSections = [String]()
    var partnersInEachSection = [String : [Partner]]() {
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
        tv.separatorStyle = .none
        tv.sectionHeaderHeight = 56.0
        tv.estimatedSectionHeaderHeight = 56.0
        tv.rowHeight = 96.0
        tv.estimatedRowHeight = UITableView.automaticDimension
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    /// Spinner shown during load
    let spinner : UIActivityIndicatorView = {
        let s = UIActivityIndicatorView()
        s.color = .primary
        s.startAnimating()
        s.hidesWhenStopped = true
        return s
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.tableView)
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.topAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDelegate

extension PartnerCommunityCollectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if partnerSections.count == 0 {
            tableView.backgroundView = spinner
        } else {
            tableView.backgroundView = nil
            spinner.stopAnimating()
        }
        return partnerSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return partnerSections[section]
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let type = partnerSections[section]
        return (partnersInEachSection[type]?.count)!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let v = UIView()
        v.backgroundColor = .background
        
        let i = UIImageView(image: UIImage(named: "Partners")?.withRenderingMode(.alwaysTemplate))
        i.contentMode = .scaleAspectFit
        i.tintColor = Const.typeColor[partnerSections[section]]
        i.translatesAutoresizingMaskIntoConstraints = false
        
        let t = UILabel()
        t.text = partnerSections[section].uppercased()
        t.textColor = Const.typeColor[partnerSections[section]]
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
        cell.imageView?.kf.cancelDownloadTask() // cancel download task, if there's any
        
        let type = partnerSections[indexPath.section]
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
        
        let type = partnerSections[indexPath.section]
        let partner = (partnersInEachSection[type]?[indexPath.row])!
        delegate?.showPartnerPageController(partner: partner)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        cell?.imageView?.kf.cancelDownloadTask()
    }
}
