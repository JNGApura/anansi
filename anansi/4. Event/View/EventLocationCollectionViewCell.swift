//
//  EventLocationCollectionViewCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 13/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

protocol DirectionsButtonDelegate {
    func didTapForDirections(bool: Bool)
    func didCopyPromoCode(with promoCode: String)
}

class EventLocationCollectionViewCell: UICollectionViewCell {
    
    // Custom Initializers

    var delegate: DirectionsButtonDelegate?
    
    let identifier = "LocationTableCell"
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(LocationTableViewCell.self, forCellReuseIdentifier: identifier)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .background
        tv.alwaysBounceVertical = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.estimatedRowHeight = 700.0
        tv.rowHeight = 700.0
        tv.showsVerticalScrollIndicator = false
        tv.allowsSelection = false;
        return tv
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
    
    // MARK: Custom functions
    
    func openActionSheet() {
        
        delegate?.didTapForDirections(bool: true)
    }
    
    func openAlertBoxConfirmation(with promoCode: String) {
        
        delegate?.didCopyPromoCode(with: promoCode)
    }
    
}

// MARK: UITableViewDelegate

extension EventLocationCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! LocationTableViewCell
        cell.delegate = self
        return cell
    }
    
}
