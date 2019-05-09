//
//  PageControl.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 20/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class PageControlWithBars: UIStackView {
    
    var numberOfPages : Int = 0 {
        didSet {
            layoutIndicators()
        }
    }

    var currentPage : Int = 0 {
        didSet {
            setCurrentPageIndicator(currentPage)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        axis = .horizontal
        distribution = .equalSpacing
        alignment = .center
        
        layoutIndicators()
    }
    
    private func layoutIndicators() {
        
        for i in 0..<numberOfPages {
            
            let bar = UIView()
            bar.layer.cornerRadius = 2.0
            bar.clipsToBounds = true
            bar.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                bar.widthAnchor.constraint(equalToConstant: Const.marginSafeArea * 2.0),
                bar.heightAnchor.constraint(equalToConstant: Const.marginEight / 2.0)
            ])
            
            addArrangedSubview(bar)
            
            if i == currentPage {
                bar.backgroundColor = .primary
            } else {
                bar.backgroundColor = .tertiary
            }
        }
    }
    
    func setCurrentPageIndicator(_ page: Int) {
        
        for i in 0..<arrangedSubviews.count {
            
            let bar = arrangedSubviews[i]
            
            if i == page {
                
                UIView.animate(withDuration: 0.3, animations: {
                    bar.backgroundColor = .primary
                })
                
            } else {
                
                UIView.animate(withDuration: 0.3, animations: {
                    bar.backgroundColor = .tertiary
                })
            }
        }
    }
    
    func setCumulativePageIndicator(_ page: Int) {
        
        for i in 0..<arrangedSubviews.count {
            
            let bar = arrangedSubviews[i]
            
            if i <= page {

                UIView.animate(withDuration: 0.3, animations: {
                    bar.backgroundColor = .primary
                })
                
            } else {
                
                UIView.animate(withDuration: 0.3, animations: {
                    bar.backgroundColor = .tertiary
                })
            }
        }
    }
}
