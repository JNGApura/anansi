//
//  ProfileViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 08/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIScrollViewDelegate {
    
    // Custom initializers
    
    private let profileImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "joao"))
        imageView.layer.cornerRadius = 50.0
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = Color.primary
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let titleLabelView: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Color.background
        label.alpha = 0.0
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = "You"
        return label
    }()
    
    private let header: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Color.primary
        view.isOpaque = true
        return view
    }()
    
    private let internalView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Color.background
        view.isOpaque = true
        return view
    }()
    
    private let internalStackView: UIStackView = {
        let isv = UIStackView()
        isv.translatesAutoresizingMaskIntoConstraints = false
        isv.axis = .vertical
        isv.distribution = .fillProportionally
        return isv
    }()
    
    private let headerTitle: UILabel = {
        let view = UILabel()
        view.text = "You"
        view.font = UIFont.boldSystemFont(ofSize: 26)
        view.textColor = Color.background
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerTitleBottomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = Color.background
        view.isOpaque = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let participantTypeBox: LabelWithInsets = {
        let view = LabelWithInsets()
        view.text = "Participant"
        view.textColor = Color.secondary
        view.font = UIFont.systemFont(ofSize: 16)
        view.layer.cornerRadius = 15.0
        view.layer.masksToBounds = true
        view.backgroundColor = Color.background
        view.isOpaque = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up navigation bar
        setupNavigationBarItems()
        
        // Sets scrollview for entire view
        scrollView.delegate = self
        view.addSubview(scrollView)
    }
    
    override func viewDidLayoutSubviews() {
        
        // Adds internalView and header to internalStackView
        internalStackView.addArrangedSubview(header)
        internalStackView.addArrangedSubview(internalView)
        scrollView.addSubview(internalStackView)
        
        // Adds headerTitle to header
        header.addSubview(headerTitle)
        
        // Adds headerTitleBottomBorder to header
        header.addSubview(headerTitleBottomBorder)
        
        // Adds participantTypeBox to header
        header.addSubview(participantTypeBox)

        // Adds imageView to header
        header.addSubview(profileImage)
        
        // Setups layout constraints
        setupLayoutConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = Color.primary
            navigationBar.isTranslucent = false
            
            // Sets title
            navigationItem.titleView = titleLabelView
            
            // Sets rightButtonItem
            let settingsButton: UIButton = {
                let button = UIButton(type: .system)
                button.setImage(#imageLiteral(resourceName: "settings").withRenderingMode(.alwaysTemplate), for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
                button.tintColor = Color.background
                button.addTarget(self, action: #selector(navigateToSettingsViewController), for: .touchUpInside)
                return button
            }()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
        }
    }
    
    private func setupLayoutConstraints() {
        
        NSLayoutConstraint.activate([
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            internalStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            internalStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            internalStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            internalStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            internalView.topAnchor.constraint(equalTo: internalStackView.topAnchor, constant: 132.0),
            header.heightAnchor.constraint(equalToConstant: 132.0),
            
            headerTitle.topAnchor.constraint(equalTo: header.topAnchor, constant: 16.0),
            headerTitle.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16.0),
            
            headerTitleBottomBorder.topAnchor.constraint(equalTo: headerTitle.bottomAnchor),
            headerTitleBottomBorder.leadingAnchor.constraint(equalTo: headerTitle.leadingAnchor),
            headerTitleBottomBorder.widthAnchor.constraint(equalToConstant: 40.0),
            headerTitleBottomBorder.heightAnchor.constraint(equalToConstant: 2.0),
            
            participantTypeBox.topAnchor.constraint(equalTo: header.topAnchor, constant: 80.0),
            participantTypeBox.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: -15.0),
            participantTypeBox.widthAnchor.constraint(equalToConstant: 135.0),
            participantTypeBox.heightAnchor.constraint(equalToConstant: 30.0),
            
            profileImage.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -16.0),
            profileImage.topAnchor.constraint(equalTo: header.topAnchor, constant: 16.0),
            profileImage.heightAnchor.constraint(equalToConstant: 100),
            profileImage.widthAnchor.constraint(equalTo: profileImage.heightAnchor)
        ])
    }
    
    // MARK: Custom functions
    
    @objc func navigateToSettingsViewController(_ sender: UIBarButtonItem){
        
        let settingsController = SettingsViewController()
        settingsController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissSettingsView))
        let navController = UINavigationController(rootViewController: settingsController)
        self.present(navController, animated: true, completion: nil)
 
    }
    
    @objc func dismissSettingsView(){
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: ScrollViewDidScroll function
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY : CGFloat = scrollView.contentOffset.y
        let titleOriginY : CGFloat = headerTitle.frame.origin.y
        let lineMaxY : CGFloat = headerTitleBottomBorder.frame.maxY
        let label = navigationItem.titleView as! UILabel
        
        if offsetY >= titleOriginY {
            if (offsetY - lineMaxY) < 0 {
                label.alpha = (offsetY - titleOriginY) / (lineMaxY - titleOriginY)
            } else {
                label.alpha = 1.0
            }
        } else {
            label.alpha = 0.0
        }
    }
}
