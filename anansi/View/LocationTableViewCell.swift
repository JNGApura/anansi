//
//  LocationTableViewCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 13/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit
import MapKit

class LocationTableViewCell: UITableViewCell, MKMapViewDelegate {
    
    var delegate: EventLocationCollectionViewCell?
    
    lazy var mapView : MKMapView = {
        let m = MKMapView()
        m.mapType = MKMapType.standard
        m.delegate = self
        m.translatesAutoresizingMaskIntoConstraints = false
        return m
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
        l.text = "Get 5€ off your first ride when you use our special code."
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
         [mapView, addressLabel, directionImage, directionButton, sponsoredTag, kaptenLogo, kaptenCodeTitle, kaptenCodeDescription, promoCodeButton, promoCodeButtonTip].forEach { addSubview($0) }
         
         NSLayoutConstraint.activate([
         
             mapView.centerXAnchor.constraint(equalTo: centerXAnchor),
             mapView.widthAnchor.constraint(equalTo: widthAnchor),
             mapView.topAnchor.constraint(equalTo: topAnchor),
             mapView.heightAnchor.constraint(equalToConstant: 280.0),
             
             addressLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: Const.marginEight * 2.0),
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
         
         // set location in ULisboa
         let ULisboaLocation = CLLocation(latitude: Const.addressLatitude, longitude: Const.addressLongitude)
         centerMapOnLocation(location: ULisboaLocation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: MKMapViewDelegate
    
    let regionRadius: CLLocationDistance = 500
    
    func centerMapOnLocation(location: CLLocation) {
        
        // Set region with 500m radius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: false)
        
        // Adds annotation with location (when tapped)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = "TEDxULisboa"
        annotation.subtitle = "Reitoria da Universidade de Lisboa"
        mapView.addAnnotation(annotation)
        
        if #available(iOS 9, *) {
            mapView.showsScale = true
            mapView.showsCompass = true
        }
        //mapView.selectAnnotation(mapView.annotations[0], animated: true)
    }
    
    // Adds custom pin with "X"
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let annotationIdentifier = "pin"
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "X")?.withRenderingMode(.alwaysOriginal)
            annotationView.centerOffset = CGPoint(x: annotationView.image!.size.width / 2, y: -annotationView.image!.size.height / 2)
        }
        return annotationView
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
