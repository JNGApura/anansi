//
//  InterestProfileTableCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 15/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

protocol ShowsInterestSelectorDelegate {
    func didTapToShowInterestSelector()
}

class InterestProfileTableCell: UITableViewCell {
    
    // Create question label
    let collectionCellIdentifier = "InterestCell"
    
    var delegate: ShowsInterestSelectorDelegate!
    
    var myInterests : [String]? {
        didSet{
            interestCollectionView.reloadData()
            interestCollectionViewHeightAnchor?.constant = interestCollectionView.collectionViewLayout.collectionViewContentSize.height
            
            if myInterests!.count < 7 {
                manageLabel.text = "Tap to pick more ➡️"
            } else {
                manageLabel.text = "Tap to change ➡️"
            }
        }
    }

    lazy var myInterestsLabel : UILabel = {
        let l = UILabel()
        l.text = "My interests"
        l.textColor = UIColor.secondary.withAlphaComponent(0.75)
        l.font = UIFont.systemFont(ofSize: Const.footnoteFontSize)
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    lazy var manageLabel : UILabel = {
        let l = UILabel()
        l.text = "Tap to pick more ➡️"
        l.textColor = .primary
        l.font = UIFont.boldSystemFont(ofSize: Const.captionFontSize)
        l.numberOfLines = 0
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    lazy var openInterestsPageButton : UIButton = {
        let b = UIButton()
        b.backgroundColor = .clear
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(tapForInterestSelector), for: .touchUpInside)
        return b
    }()
    
    lazy var interestCollectionView : UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: self.frame, collectionViewLayout: flowLayout)
        cv.register(InterestCell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isScrollEnabled = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        return cv
    }()
    var interestCollectionViewHeightAnchor: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let layout = UICollectionViewAlignedLayout()
        layout.layoutDirection = .left
        interestCollectionView.setCollectionViewLayout(layout, animated: true)
        
        addSubview(myInterestsLabel)
        addSubview(manageLabel)
        addSubview(openInterestsPageButton)
        addSubview(interestCollectionView)
        
        NSLayoutConstraint.activate([
            myInterestsLabel.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight),
            myInterestsLabel.heightAnchor.constraint(equalToConstant: 24.0),
            myInterestsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            myInterestsLabel.widthAnchor.constraint(equalToConstant: 76.0),
            
            manageLabel.leadingAnchor.constraint(equalTo: myInterestsLabel.trailingAnchor),
            manageLabel.heightAnchor.constraint(equalToConstant: 24.0),
            manageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            manageLabel.centerYAnchor.constraint(equalTo: myInterestsLabel.centerYAnchor, constant: 1.0),
            
            openInterestsPageButton.leadingAnchor.constraint(equalTo: manageLabel.leadingAnchor),
            openInterestsPageButton.heightAnchor.constraint(equalTo: manageLabel.heightAnchor),
            openInterestsPageButton.trailingAnchor.constraint(equalTo: manageLabel.trailingAnchor),
            openInterestsPageButton.centerYAnchor.constraint(equalTo: manageLabel.centerYAnchor),
            
            interestCollectionView.topAnchor.constraint(equalTo: myInterestsLabel.bottomAnchor, constant: Const.marginEight / 2.0),
            interestCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            interestCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            interestCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        interestCollectionViewHeightAnchor = interestCollectionView.heightAnchor.constraint(equalToConstant: 0.0)
        interestCollectionViewHeightAnchor?.isActive = true
        
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapForInterestSelector))
        //addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Custom functions
    
    func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: frame.width, height: 1000) // height arbitrarily high
        let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Const.calloutFontSize)], context: nil)
    }
    
    @objc func tapForInterestSelector() {
        delegate?.didTapToShowInterestSelector()
    }
}

// MARK: UICollectionViewDelegate

extension InterestProfileTableCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myInterests!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as! InterestCell
        
        cell.text = myInterests![indexPath.item]
        cell.select()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let string = myInterests![indexPath.item]
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
