//
//  UIImageView+.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 02/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

// Load image using cache
let imageCache = NSCache<AnyObject, AnyObject>()
extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(_ urlString: String) {
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error ?? "")
                return
            }
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            }
        }).resume()
    }
}

import Kingfisher

extension UIImageView {
    
    func setImage(with urlString: String){
        
        guard let url = URL.init(string: urlString) else {
            self.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
            return
        }
        
        let resource = ImageResource(downloadURL: url, cacheKey: urlString)
        var kf = self.kf
        kf.indicatorType = .activity
        (kf.indicator?.view as? UIActivityIndicatorView)?.color = .primary
        
        self.kf.setImage(with: resource, placeholder: nil, options: [.transition(.fade(0.2))], progressBlock: { (receivedSize, totalSize) in
            
            let percentage = (Float(receivedSize) / Float(totalSize)) * 100.0
            print("Downloading progress: \(percentage)%")
            
        }) { result in
            
            switch result {
            case .success(_):
                break // All good, nothing to do
                
            case .failure(let error):
                
                print(error)
                
                // Tries one more time
                self.kf.setImage(with: resource, placeholder: nil, options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: { (result) in
                    
                    switch result {
                    case .success(_):
                        break
                    case .failure(_):
                        self.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
                    }
                })
            }
        }
    }
}
