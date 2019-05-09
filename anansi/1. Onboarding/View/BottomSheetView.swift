//
//  BottomSheetView.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 21/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class BottomSheetView: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Custom initializers
    
    let backgroundView : UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        v.isOpaque = false
        v.isUserInteractionEnabled = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let bottomSheet : UIView = {
        let v = UIView()
        v.backgroundColor = .background
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let sheetIcon: UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "Event")?.withRenderingMode(.alwaysTemplate)
        i.contentMode = .scaleAspectFill
        i.tintColor = .primary
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    private let sheetTitle: UILabel = {
        let l = UILabel()
        l.textColor = .primary
        l.numberOfLines = 0
        l.lineBreakMode = NSLineBreakMode.byWordWrapping
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let sheetDescription: UILabel = {
        let l = UILabel()
        l.textColor = .secondary
        l.numberOfLines = 0
        l.lineBreakMode = NSLineBreakMode.byWordWrapping
        l.font = UIFont.systemFont(ofSize: Const.calloutFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let border: UIView = {
        let v = UIView()
        v.backgroundColor = .secondary
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let button: UIButton = {
        let b = UIButton()
        b.setTitle("Got it!", for: .normal)
        b.setTitleColor(.primary, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return b
    }()
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [backgroundView, bottomSheet].forEach( {view.addSubview($0)} )
        
        [sheetIcon, sheetTitle, sheetDescription, border, button].forEach( {bottomSheet.addSubview($0)} )
        
        // In bottom-up order
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Const.marginEight * 2.0),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Const.marginEight * 3.0 - 1.0),
            button.widthAnchor.constraint(equalToConstant: 52.0),
            button.heightAnchor.constraint(equalToConstant: 22.0),
            
            border.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            border.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Const.marginEight * 6.0),
            border.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -Const.marginEight * 2.0),
            border.heightAnchor.constraint(equalToConstant: 1.5),
            
            sheetDescription.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -Const.marginEight * 1.5),
            sheetDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Const.marginEight * 3.0),
            sheetDescription.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Const.marginEight * 3.0),
            
            sheetTitle.bottomAnchor.constraint(equalTo: sheetDescription.topAnchor, constant: -Const.marginEight),
            sheetTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Const.marginEight * 3.0),
            sheetTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Const.marginEight * 3.0),
            sheetTitle.heightAnchor.constraint(equalToConstant: 26.0),
            
            sheetIcon.bottomAnchor.constraint(equalTo: sheetTitle.topAnchor, constant: -Const.marginEight * 1.5),
            sheetIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Const.marginEight * 3.0),
            sheetIcon.heightAnchor.constraint(equalToConstant: 28.0),
            sheetIcon.widthAnchor.constraint(equalToConstant: 28.0),
            
            bottomSheet.topAnchor.constraint(equalTo: sheetIcon.topAnchor, constant: -Const.marginEight * 2.5),
            bottomSheet.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            bottomSheet.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            bottomSheet.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundView.widthAnchor.constraint(equalTo: view.widthAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        bottomSheet.alpha = 0.0
        bottomSheet.transform = CGAffineTransform(translationX: 0, y: 200)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.bottomSheet.alpha = 1.0
            self.bottomSheet.transform = CGAffineTransform.identity
        })
    }
    
    override func viewWillLayoutSubviews() {
        
        // Need this here, so it can be assigned once rendered
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        bottomSheet.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleVerticalPan)))
    }
    
     // MARK: - Custom functions

    func setContent(title: String, description: String) {
        
        sheetTitle.text = title
        
        sheetDescription.text = description
        sheetDescription.formatTextWithLineSpacing(lineSpacing: 8, lineHeightMultiple: 1.1, hyphenation: 0.5, alignment: .left)
    }
    
    func setIcon(image: UIImage){
        
        sheetIcon.image = image
    }
    
    @objc func handleDismiss() {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            
            self.bottomSheet.alpha = 0.0
            self.bottomSheet.transform = CGAffineTransform(translationX: 0, y: 200)
        }) { (true) in
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleVerticalPan(recognizer: UIPanGestureRecognizer) {
        
        let gestureView = recognizer.view
        let point = recognizer.translation(in: gestureView)
        
        if recognizer.state == .changed {
            
            if point.y > 0 {
                bottomSheet.frame.origin.y += point.y
            }
        } else if recognizer.state == .ended || recognizer.state == .cancelled {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.bottomSheet.alpha = 0.0
            }) { (true) in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
