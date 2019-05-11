//
//  InterestsUserTableCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 22/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class InterestsUserTableCell: UITableViewCell {
    
    // Create question label
    var userInterests : [String]? {
        didSet {
            interestCollectionView.reloadData()
            interestCollectionViewHeightAnchor?.constant = interestCollectionView.collectionViewLayout.collectionViewContentSize.height
        }
    }
    var myInterests : [String]?
    
    lazy var interestCollectionView : UICollectionView = {
        let cv = UICollectionView(frame: self.frame, collectionViewLayout: UICollectionViewFlowLayout())
        cv.register(InterestCell.self, forCellWithReuseIdentifier: "InterestCell")
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isScrollEnabled = false
        cv.delegate = self
        cv.dataSource = self
        cv.allowsSelection = false
        cv.isUserInteractionEnabled = false
        cv.backgroundColor = .background
        return cv
    }()
    var interestCollectionViewHeightAnchor: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let layout = UICollectionViewAlignedLayout()
        layout.layoutDirection = .left
        interestCollectionView.setCollectionViewLayout(layout, animated: true)
        
        addSubview(interestCollectionView)
        
        NSLayoutConstraint.activate([
            interestCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight),
            interestCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            interestCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            interestCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        interestCollectionViewHeightAnchor = interestCollectionView.heightAnchor.constraint(equalToConstant: 0.0)
        interestCollectionViewHeightAnchor?.isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: frame.width, height: 1000) // height arbitrarily high
        let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Const.calloutFontSize)], context: nil)
    }
    
}

// MARK: UICollectionViewDelegate

extension InterestsUserTableCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userInterests!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestCell", for: indexPath) as! InterestCell
        
        cell.text = userInterests![indexPath.item]
        cell.unselect()
        
        if myInterests!.contains(userInterests![indexPath.item]) {
            cell.select()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let string = userInterests![indexPath.item]
        return CGSize(width: estimateFrameForText(text: string).width + 16, height: 28.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
}
