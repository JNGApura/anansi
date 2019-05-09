//
//  ChallengeEventCollectionViewCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 13/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit
import CoreLocation

class EventChallengeCollectionViewCell: UICollectionViewCell {
        
    // Custom Initializers
    
    lazy var button : UIButton = {
        let b = UIButton()
        b.setTitle("Find your true north.", for: .normal)
        b.setTitleColor(.secondary, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        b.titleLabel?.textAlignment = .center
        b.backgroundColor = .background
        b.addTarget(self, action: #selector(showCompass), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let compassInner : UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "Compass-Inner")?.withRenderingMode(.alwaysOriginal)
        i.isHidden = true
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let compassOuter : UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "Compass-Outer")?.withRenderingMode(.alwaysOriginal)
        i.isHidden = true
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    var coordinates : UILabel = {
        let l = UILabel()
        l.text = ""
        l.formatTextWithLineSpacing(lineSpacing: 4, lineHeightMultiple: 1, hyphenation: 0, alignment: .left)
        l.textColor = .secondary
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.isHidden = true
        return l
    }()
    
    var headingAngles : UILabel = {
        let l = UILabel()
        l.text = ""
        l.formatTextWithLineSpacing(lineSpacing: 4, lineHeightMultiple: 1, hyphenation: 0, alignment: .left)
        l.textColor = .secondary
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.isHidden = true
        return l
    }()
    
    
    let locationManager = CLLocationManager()
    var locationCallback: ((CLLocation) -> ())? = nil
    
    var currentLocation: CLLocation!
    var trueNorth = CLLocation(latitude: 90, longitude: 0)
    var yourLocationBearing: CGFloat { return currentLocation?.bearingToLocationRadian(self.trueNorth) ?? 0 }
    
    var headingCallback: ((CLLocationDirection) -> ())? = nil
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(button)
        addSubview(compassInner)
        addSubview(compassOuter)
        addSubview(coordinates)
        addSubview(headingAngles)
        
        NSLayoutConstraint.activate([
            
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            compassInner.centerXAnchor.constraint(equalTo: centerXAnchor),
            compassInner.centerYAnchor.constraint(equalTo: centerYAnchor),

            compassOuter.centerXAnchor.constraint(equalTo: centerXAnchor),
            compassOuter.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            coordinates.topAnchor.constraint(equalTo: compassOuter.bottomAnchor, constant: Const.marginSafeArea),
            coordinates.widthAnchor.constraint(equalTo: widthAnchor),
            
            headingAngles.topAnchor.constraint(equalTo: coordinates.bottomAnchor, constant: Const.marginEight),
            headingAngles.widthAnchor.constraint(equalTo: widthAnchor),

        ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: CoreLocation
    
    func handleCompass() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        
        locationCallback = { location in
            self.currentLocation = location
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
                
                if (error != nil) {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                
                if (placemarks?.count)! > 0 {
                    
                    let pm = placemarks?[0]
                    self.displayLocationInfo(pm)
                    
                } else {
                    print("Problem with the data received from geocoder")
                }
            })
            
        }
        
        headingCallback = { newHeading in
            
            func computeNewAngle(with newAngle: CGFloat) -> CGFloat {
                let heading: CGFloat = {
                    let originalHeading = self.yourLocationBearing - newAngle.degreesToRadians
                    switch UIDevice.current.orientation {
                    case .faceDown: return -originalHeading
                    default: return originalHeading
                    }
                }()
                
                return CGFloat(self.orientationAdjustment().degreesToRadians + heading)
            }
            
            UIView.animate(withDuration: 0.5) {
                let angle = computeNewAngle(with: CGFloat(newHeading))
                let angleInDegrees = abs(angle.radiansToDegrees.rounded(.down))
                
                self.compassOuter.transform = CGAffineTransform(rotationAngle: angle)
                
                self.displayHeadingInfo(angleInDegrees)
            }
        }
    }
    
    
    // MARK: Custom functions
    
    @objc func showCompass() {
        
        button.isHidden = true
        
        compassInner.isHidden = false
        compassOuter.isHidden = false
        coordinates.isHidden = false
        headingAngles.isHidden = false
        
        handleCompass()
    }
    
    private func orientationAdjustment() -> CGFloat {
        
        let isFaceDown: Bool = {
            switch UIDevice.current.orientation {
            case .faceDown: return true
            default: return false
            }
        }()
        
        let adjAngle: CGFloat = {
            switch UIApplication.shared.statusBarOrientation {
            case .landscapeLeft:  return 90
            case .landscapeRight: return -90
            case .portrait, .unknown: return 0
            case .portraitUpsideDown: return isFaceDown ? 180 : -180
            }
        }()
        return adjAngle
    }
    
    func displayLocationInfo(_ placemark: CLPlacemark?) {
        
        if let containsPlacemark = placemark {
            
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            
            var latCardinal : String = ""
            var latDegrees = 0.0
            var latMinutes = 0.0
            var latSeconds = 0.0
            
            if let latitude = containsPlacemark.location?.coordinate.latitude {
                
                latCardinal = (latitude >= 0) ? "N" : "S"
                
                latDegrees = abs(Double(latitude)).rounded(.down)
                
                let minutes = abs(abs(Double(latitude)) - latDegrees)
                latMinutes = (minutes * 60).rounded(.down)
                
                let seconds = abs(minutes * 60 - latMinutes)
                latSeconds = (seconds * 60).rounded(.down)
                
            }
            
            var lonCardinal : String = ""
            var lonDegrees = 0.0
            var lonMinutes = 0.0
            var lonSeconds = 0.0
            
            if let longitude = containsPlacemark.location?.coordinate.longitude {
                
                lonCardinal = (longitude >= 0) ? "E" : "W"
                
                lonDegrees = abs(Double(longitude)).rounded(.down)
                
                let ominutes = abs(abs(Double(longitude)) - lonDegrees)
                lonMinutes = (ominutes * 60).rounded(.down)
                
                let oseconds = abs(ominutes * 60 - lonMinutes)
                lonSeconds = (oseconds * 60).rounded(.down)
                
            }
            
            coordinates.text = "\(String(format: "%.0f", latDegrees))º\(String(format: "%.0f", latMinutes))'\(String(format: "%.0f", latSeconds))\" \(latCardinal) \(String(format: "%.0f", lonDegrees))º\(String(format: "%.0f", lonMinutes))'\(String(format: "%.0f", lonSeconds))\" \(lonCardinal)"
        }
    }
        
    func displayHeadingInfo(_ angle: CGFloat) {
        
        let cardialDirection = (angle >= 337.5 || angle < 22.5) ? "N" :
                              ((angle >= 22.5 && angle < 67.5) ? "NE" :
                              ((angle >= 67.5 && angle < 112.5) ? "E" :
                              ((angle >= 112.5 && angle < 157.5) ? "SE" :
                              ((angle >= 157.5 && angle < 202.5) ? "S" :
                              ((angle >= 202.5 && angle < 247.5) ? "SW" :
                              ((angle >= 247.5 && angle < 292.5) ? "W" : "NW"))))))
        
        self.headingAngles.text = "\(String(format: "%.0f", angle))º \(cardialDirection)"
    }
    
}


// LocationDelegate

extension EventChallengeCollectionViewCell: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        locationCallback?(currentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        headingCallback?(newHeading.trueHeading)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("⚠️ Error while updating location " + error.localizedDescription)
    }
    
}
