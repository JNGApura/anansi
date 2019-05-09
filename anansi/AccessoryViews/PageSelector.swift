//
//  PageSelector.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 12/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

protocol PageSelectorDelegate {
    func pageSelectorDidSelectItemAt(selector: PageSelector, index: Int)
}

class PageSelector: UIView {
    
    var tabList : [String] = [] {
        didSet {
            self.collectionView.reloadData()
            self.collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .bottom)
        }
    }
    
    var selectorDelegate: PageSelectorDelegate?
    
    let identifier = "selectorCell"
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(TabSelector.self, forCellWithReuseIdentifier: identifier)
        layout.scrollDirection = .horizontal
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .background
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PageSelector: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! TabSelector
        
        cell.tabIcon.image = UIImage(named: tabList[indexPath.item])?.withRenderingMode(.alwaysTemplate)
        cell.tabTitle.text = tabList[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let index = Int(indexPath.item)        
        selectorDelegate?.pageSelectorDidSelectItemAt(selector: self, index: index)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let hypotheticalSize = CGSize.init(width: 500.0, height: collectionView.bounds.height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let str = tabList[indexPath.item]
        
        let estimatedRect = NSString.init(string: str).boundingRect(with: hypotheticalSize, options: options, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: Const.bodyFontSize)], context: nil)
        
        return CGSize(width: estimatedRect.size.width + 12.0 + 42.0, height: collectionView.bounds.height - 12.0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 24.0, bottom: 0, right: 24.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
