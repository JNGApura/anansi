//
//  ProfileViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 08/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Custom initializers
    private let titleLabelView: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .background
        label.alpha = 0.0
        label.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        label.text = "You"
        return label
    }()
    
    lazy var scrollView : UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.backgroundColor = .background
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView : UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    lazy var headerView : HeaderWithProfileImage = {
        let hv = HeaderWithProfileImage()
        hv.setBackgroundColor(color: .primary)
        hv.setTitleName(name: "You")
        hv.setTitleColor(textColor: .background)
        hv.setBottomBorderColor(lineColor: .background)
        hv.profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        hv.translatesAutoresizingMaskIntoConstraints = false
        return hv
    }()
    
    let insideView : UIView = {
        let v = UIView()
        v.backgroundColor = .background
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up navigation bar
        setupNavigationBarItems()
        
        // Sets up UI
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        contentView.addSubview(insideView)
        
        let dummyView = UIView()
        dummyView.backgroundColor = .primary
        dummyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dummyView)
        
        NSLayoutConstraint.activate([
            
            // Activates scrollView constraints
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Activates contentView constraints
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // Activates headerView constraints
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
            headerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 132.0),
            
            // Huge hack so that the headerView blends "in" with the navigation bar -- should try to come up with another solution
            dummyView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: -view.frame.height + 171),
            dummyView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            dummyView.heightAnchor.constraint(equalTo: view.heightAnchor),

            // Activates insideView constraints
            insideView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            insideView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            insideView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            insideView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 100.0),
            insideView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        // Check if user is logged in
        checkIfUserIsLoggedIn()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = .primary
            navigationBar.isTranslucent = false
            
            // Sets title
            navigationItem.titleView = titleLabelView
            
            // Sets rightButtonItem
            let settingsButton: UIButton = {
                let button = UIButton(type: .system)
                button.setImage(#imageLiteral(resourceName: "settings").withRenderingMode(.alwaysTemplate), for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: Const.navButtonHeight, height: Const.navButtonHeight)
                button.tintColor = .background
                button.addTarget(self, action: #selector(navigateToSettingsViewController), for: .touchUpInside)
                return button
            }()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
        }
    }
    
    // MARK: Network
    
    private func checkIfUserIsLoggedIn() {
        
        NetworkManager.shared.isUserLoggedIn { (dictionary) in
            if let profileImageURL = dictionary["profileImageURL"] as? String {
                self.headerView.profileImage.loadImageUsingCacheWithUrlString(profileImageURL)
            }
            /*else {
                NetworkManager.shared.storesImageInDatabase(folder: "profile_images", image: #imageLiteral(resourceName: "profileImageTemplate"), onSuccess: { (imageURL) in
                    NetworkManager.shared.registerData(["profileImageURL": imageURL])
                })
            }*/
        }
    }
    
    // MARK: Custom functions
    
    @objc func navigateToSettingsViewController(_ sender: UIBarButtonItem){
        
        let settingsController = SettingsViewController()
        settingsController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissSettingsView))
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func dismissSettingsView(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        picker.navigationBar.isTranslucent = false
        
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: ScrollViewDidScroll function
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY : CGFloat = scrollView.contentOffset.y
        let titleOriginY : CGFloat = headerView.headerTitle.frame.origin.y
        let lineMaxY : CGFloat = headerView.headerBottomBorder.frame.maxY
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
    
    // MARK: ImagePickerController
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            self.headerView.profileImage.image = selectedImage
            
            NetworkManager.shared.storesImageInDatabase(folder: "profile_images", image: selectedImage, onSuccess: { (imageURL) in
                NetworkManager.shared.registerData(["profileImageURL": imageURL])
            })
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Image picker was canceled")
        dismiss(animated: true, completion: nil)
    }
}
