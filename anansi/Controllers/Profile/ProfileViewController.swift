//
//  ProfileViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 08/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Custom initializers
    let user = User()
    
    lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "profileImage").withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = 50.0
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
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

        // Check if user is logged in
        checkIfUserIsLoggedIn()
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
    
    private func checkIfUserIsLoggedIn() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                if let profileImageURL = dictionary["profileImageURL"] as? String {
                    self.profileImage.loadImageUsingCacheWithUrlString(urlString: profileImageURL) }
                else {
                    self.profileImage.image = #imageLiteral(resourceName: "profileImage").withRenderingMode(.alwaysOriginal)
                }
            }
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            self.profileImage.image = selectedImage
            
            guard let uid = Auth.auth().currentUser?.uid else { return }

            // Stores profileImage into Firebase Storage
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            
            if let profileImage = self.profileImage.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                        let values = ["profileImageURL": profileImageURL]
                        
                        // Register profileImage's URL (from Firebase Storage) into database
                        let databaseReference = Database.database().reference()
                        let usersReference = databaseReference.child("users").child(uid)
                        usersReference.updateChildValues(values, withCompletionBlock: { (error, usersReference) in
                            if error != nil {
                                print(error!.localizedDescription)
                                return
                            }
                        })
                    }
                    
                })
            }
        }

        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
}
