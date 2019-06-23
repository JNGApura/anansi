//
//  UIImageView+.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 02/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func setImage(with urlString: String){
        
        guard let url = URL.init(string: urlString) else {
            image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
            return
        }
        
        let resource = ImageResource(downloadURL: url, cacheKey: urlString)
        kf.indicatorType = .activity
        (kf.indicator?.view as? UIActivityIndicatorView)?.color = .primary
        
        kf.setImage(with: resource, placeholder: nil, options: [.transition(.fade(0.2))], progressBlock: { (receivedSize, totalSize) in
            
            let percentage = (Float(receivedSize) / Float(totalSize)) * 100.0
            print("Downloading progress: \(percentage)%")
            
        }) { [weak self] result in
            
            switch result {
            case .success(_):
                break // All good, nothing to do
                
            case .failure(let error):
                
                print(error)
                
                // Tries one more time
                self?.kf.setImage(with: resource, placeholder: nil, options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: { (result) in
                    
                    switch result {
                    case .success(_):
                        break
                    case .failure(_):
                        self?.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
                    }
                })
            }
        }
    }    
}
