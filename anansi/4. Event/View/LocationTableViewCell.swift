//
//  LocationTableViewCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 13/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit
import MapKit

class LocationTableViewCell: UITableViewCell {
    
    let regionRadius: CLLocationDistance = 500
    let ULisboaLocation = CLLocationCoordinate2DMake(Const.addressLatitude, Const.addressLongitude)
    lazy var ULisboaRegion = MKCoordinateRegion(center: ULisboaLocation, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
    
    weak var delegate: EventLocationCollectionViewCell?
    
    lazy var mapImage : UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.clipsToBounds = true
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = .primary
        ai.isHidden = false
        ai.startAnimating()
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    lazy var X : UIButton = {
        let b = UIButton()
        b.contentMode = .center
        b.setImage(UIImage(named: "X")?.withRenderingMode(.alwaysOriginal), for: .normal)
        b.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        b.addTarget(self, action: #selector(openDirectionsActionSheet), for: .touchUpInside)
        b.isHidden = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let addressLabel : UILabel = {
        let l = UILabel()
        l.text = Const.addressULisboa
        l.formatTextWithLineSpacing(lineSpacing: 8, lineHeightMultiple: 1, hyphenation: 0, alignment: .left)
        l.textColor = .secondary
        l.font = UIFont.systemFont(ofSize: Const.calloutFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let directionImage : UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "Directions")?.withRenderingMode(.alwaysOriginal)
        i.backgroundColor = .background
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    lazy var directionButton : UIButton = {
        let b = UIButton()
        b.backgroundColor = .clear
        b.addTarget(self, action: #selector(openDirectionsActionSheet), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    lazy var sponsoredTag : UIButton = {
        let b = UIButton()
        b.backgroundColor = .primary
        b.setTitle("SPONSORED", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: Const.captionFontSize)
        b.titleLabel?.textAlignment = .left
        b.setTitleColor(.background, for: .normal)
        b.layer.cornerRadius = 10.0
        b.layer.borderWidth = 1.0
        b.layer.borderColor = UIColor.primary.cgColor
        b.layer.masksToBounds = true
        b.isUserInteractionEnabled = false
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let kaptenLogo : UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "Kapten-Location")?.withRenderingMode(.alwaysOriginal)
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let kaptenCodeTitle : UILabel = {
        let l = UILabel()
        l.text = "Kapten takes you to TEDxULisboa!"
        l.formatTextWithLineSpacing(lineSpacing: 4, lineHeightMultiple: 1, hyphenation: 0, alignment: .left)
        l.textColor = .secondary
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let kaptenCodeDescription : UILabel = {
        let l = UILabel()
        l.text = "Get 50% discount in your first two rides when using our special code (max. 3€ discount per ride, new accounts only)."
        l.formatTextWithLineSpacing(lineSpacing: 8, lineHeightMultiple: 1, hyphenation: 0, alignment: .left)
        l.textColor = .secondary
        l.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    lazy var promoCodeButton : SpecialButton = {
        let b = SpecialButton()
        b.setTitle(Const.kaptenPromoCode, for: .normal)
        b.addTarget(self, action: #selector(copyPromoCode), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let promoCodeButtonTip : UILabel = {
        let l = UILabel()
        l.text = "Tap to copy your code"
        l.formatTextWithLineSpacing(lineSpacing: 8, lineHeightMultiple: 1, hyphenation: 0, alignment: .left)
        l.textColor = .secondary
        l.font = UIFont.systemFont(ofSize: Const.captionFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
         [mapImage, activityIndicator, X, addressLabel, directionImage, directionButton, sponsoredTag, kaptenLogo, kaptenCodeTitle, kaptenCodeDescription, promoCodeButton, promoCodeButtonTip].forEach { addSubview($0) }
         
         NSLayoutConstraint.activate([
         
             mapImage.centerXAnchor.constraint(equalTo: centerXAnchor),
             mapImage.widthAnchor.constraint(equalTo: widthAnchor),
             mapImage.topAnchor.constraint(equalTo: topAnchor),
             mapImage.heightAnchor.constraint(equalToConstant: 280.0),
             
             activityIndicator.centerXAnchor.constraint(equalTo: mapImage.centerXAnchor),
             activityIndicator.centerYAnchor.constraint(equalTo: mapImage.centerYAnchor),
             
             X.centerXAnchor.constraint(equalTo: mapImage.centerXAnchor, constant: Const.marginEight),
             X.centerYAnchor.constraint(equalTo: mapImage.centerYAnchor, constant: -Const.marginEight),
             X.widthAnchor.constraint(equalTo: X.heightAnchor),
             X.heightAnchor.constraint(equalToConstant: 32.0),
             
             addressLabel.topAnchor.constraint(equalTo: mapImage.bottomAnchor, constant: Const.marginEight * 2.0),
             addressLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
             addressLabel.trailingAnchor.constraint(equalTo: directionImage.trailingAnchor, constant: -Const.marginSafeArea),
             
             directionImage.centerYAnchor.constraint(equalTo: addressLabel.centerYAnchor),
             directionImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
             directionImage.widthAnchor.constraint(equalToConstant: 44.0),
             directionImage.heightAnchor.constraint(equalToConstant: 44.0),
             
             directionButton.topAnchor.constraint(equalTo: addressLabel.topAnchor),
             directionButton.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor),
             directionButton.trailingAnchor.constraint(equalTo: directionImage.trailingAnchor),
             directionButton.bottomAnchor.constraint(equalTo: addressLabel.bottomAnchor),
             
             sponsoredTag.topAnchor.constraint(equalTo: directionButton.bottomAnchor, constant: Const.marginSafeArea * 2.0),
             sponsoredTag.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
             sponsoredTag.heightAnchor.constraint(equalToConstant: 20.0),
             sponsoredTag.widthAnchor.constraint(equalToConstant: 80.0),
             
             kaptenLogo.topAnchor.constraint(equalTo: sponsoredTag.bottomAnchor, constant: Const.marginEight * 2.0),
             kaptenLogo.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
             kaptenLogo.heightAnchor.constraint(equalToConstant: 32.0),
             kaptenLogo.widthAnchor.constraint(equalToConstant: 128.0),
             
             kaptenCodeTitle.topAnchor.constraint(equalTo: kaptenLogo.bottomAnchor, constant: Const.marginEight * 2.0),
             kaptenCodeTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
             kaptenCodeTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
             
             kaptenCodeDescription.topAnchor.constraint(equalTo: kaptenCodeTitle.bottomAnchor, constant: Const.marginEight),
             kaptenCodeDescription.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
             kaptenCodeDescription.widthAnchor.constraint(equalTo: widthAnchor, constant: -Const.marginSafeArea * 2.0),
             kaptenCodeDescription.centerXAnchor.constraint(equalTo: centerXAnchor),
             
             promoCodeButton.topAnchor.constraint(equalTo: kaptenCodeDescription.bottomAnchor, constant: Const.marginEight * 2.0),
             promoCodeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
             promoCodeButton.widthAnchor.constraint(equalTo: widthAnchor, constant: -Const.marginSafeArea * 2.0),
             promoCodeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
             
             promoCodeButtonTip.topAnchor.constraint(equalTo: promoCodeButton.bottomAnchor, constant: Const.marginEight / 2.0),
             promoCodeButtonTip.centerXAnchor.constraint(equalTo: promoCodeButton.centerXAnchor),
        ])
        
        // Creates Map snapshot
        
        let options = MKMapSnapshotter.Options()
        options.region = ULisboaRegion
        options.scale = UIScreen.main.scale
        options.size = CGSize(width: frame.width, height: frame.width)
        options.showsBuildings = true
        options.showsPointsOfInterest = true
        
        let snapShotter = MKMapSnapshotter(options: options)
        
        snapShotter.start { [weak self] (snapshot, error) in
            
            guard let snapshot = snapshot, error == nil else {
                print(error.debugDescription)
                return
            }
            
            DispatchQueue.main.async {
                self?.mapImage.image = snapshot.image
                self?.X.isHidden = false
                
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Custom functions
    
    @objc func openDirectionsActionSheet() {
        
        delegate?.openActionSheet()
    }
    
    @objc func copyPromoCode() {
        
        let pasteboard = UIPasteboard.general
        pasteboard.string = promoCodeButton.titleLabel?.text
        
        delegate?.openAlertBoxConfirmation(with: pasteboard.string!)
    }
}
