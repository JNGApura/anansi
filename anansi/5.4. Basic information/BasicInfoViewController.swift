//
//  BasicInfoViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 21/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class BasicInfoViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // Data
    var delegate: SettingsViewController?
    
    var user : User? {
        didSet {
            
            if let imageURL = user?.getValue(forField: .profileImageURL) as? String {
                profileImage.setImage(with: imageURL)
                
            } else {
                profileImage.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    let fields: [userInfoType] = [.name, .occupation, .location]
    
    // Custom initializers
    let titleLabel : UILabel = {
        let l = UILabel()
        l.text = "Basic information"
        l.textColor = .secondary
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        return l
    }()
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.delegate = self
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var profileImage: UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
        i.tintColor = .secondary
        i.layer.cornerRadius = 42.0
        i.clipsToBounds = true
        i.contentMode = .scaleAspectFill
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let addPictureButton: UIButton = {
        let i = UIButton()
        i.setImage(UIImage(named: "editProfileImage")!.withRenderingMode(.alwaysOriginal), for: .normal)
        i.contentMode = .scaleAspectFill
        i.layer.cornerRadius = 18.0
        i.layer.masksToBounds = false
        i.layer.shadowColor = UIColor.black.cgColor
        i.layer.shadowOpacity = 0.2
        i.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        i.layer.shadowRadius = 4.0
        i.translatesAutoresizingMaskIntoConstraints = false
        i.addTarget(self, action: #selector(chooseProfileImage), for: .touchUpInside)
        return i
    }()
    
    lazy var tableView : UITableView = {
        let tv = UITableView(frame: UIScreen.main.bounds, style: .plain)
        tv.register(TextFieldTableCell.self, forCellReuseIdentifier: "TextFieldCell")
        tv.isScrollEnabled = false
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.allowsSelection = true
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 84
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = .primary
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.isHidden = true
        ai.stopAnimating()
        return ai
    }()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        setupNavigationBarItems()
        
        hideKeyboardWhenTappedAround()
        
        // Add subviews to view
        view.addSubview(scrollView)
        [profileImage, activityIndicator, addPictureButton, tableView].forEach { scrollView.addSubview($0)}
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            profileImage.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            profileImage.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Const.marginSafeArea),
            profileImage.widthAnchor.constraint(equalToConstant: 84.0),
            profileImage.heightAnchor.constraint(equalToConstant: 84.0),
            
            activityIndicator.centerXAnchor.constraint(equalTo: profileImage.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),

            addPictureButton.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 4.0),
            addPictureButton.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 4.0),
            addPictureButton.widthAnchor.constraint(equalToConstant: 36.0),
            addPictureButton.heightAnchor.constraint(equalToConstant: 36.0),
            
            tableView.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 32.0),
            tableView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Sets up navigation bar
    func setupNavigationBarItems() {
        
        navigationController?.view.backgroundColor = .background
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.titleView = titleLabel
        
        let backButton: UIButton = {
            let b = UIButton(type: .system)
            b.setImage(UIImage(named: "back")!.withRenderingMode(.alwaysTemplate), for: .normal)
            b.frame = CGRect(x: 0, y: 0, width: 24.0, height: 24.0)
            b.tintColor = .primary
            b.translatesAutoresizingMaskIntoConstraints = false
            b.addTarget(self, action: #selector(backToSettings(_:)), for: .touchUpInside)
            return b
        }()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    // MARK: Custom functions
    
    @objc func backToSettings(_ sender: UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true) {
            self.delegate?.sendsUserback(user: self.user!)
        }
    }
    
    func alertFieldChangeIsForbidden(with title: String, and message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default , handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let field = fields[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldTableCell
        cell.delegate = self
        cell.configureWithField(field: field, andValue: (user?.getValue(forField: field) as? String)!, withLabel: (user?.label(forField: field))!, withPlaceholder: (user?.placeholder(forField: field))!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
    
// MARK: - TextFieldTableCellDelegate

extension BasicInfoViewController:  TextFieldTableCellDelegate {
    
    func field(field: userInfoType, changedValueTo value: String) {
        
        let uid = user?.getValue(forField: .id) as! String
        
        user?.setValue(value: value, for: field)
        NetworkManager.shared.register(value: value, for: field.rawValue, in: uid)
        
        tableView.reloadData()
    }
    
    func fieldDidBeginEditing(field: userInfoType) {
        // In case I need this for some reason
    }
    
    func fieldChangeForbidden(field: userInfoType) {
        
        var alertTitle : String = "This should have a title", alertMessage : String = "This should have a message"
        
        if field == .name {
            alertTitle = "Hey nameless you"
            alertMessage = "You can't have your name field empty 🚫 To connect with other attendees, you need to provide a real name."
            
        } else if field == .occupation {
            alertTitle = "What do you do?"
            alertMessage = "You can't have your occupation field empty 🚫 Tell other attendees what you do, even if it's not entirely true 🦄"
            
        } else if field == .location {
            alertTitle = "Ok, we get it..."
            alertMessage = "You don't want to share where you live, but you can't have your location field empty 🚫 We recommend using other location, e.g. where you work from, Atlantis, or some other place on earth."
        }
        
        alertFieldChangeIsForbidden(with: alertTitle, and: alertMessage)
    }
}

// MARK: ImagePickerController

extension BasicInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func chooseProfileImage() {
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        picker.navigationBar.isTranslucent = false
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let image = selectedImage {
            
            let uid = user?.getValue(forField: .id) as! String

            let folder = "profile_images"
            
            profileImage.alpha = 0.5
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            NetworkManager.shared.removesImageFromStorage(folder: folder) {
                
                NetworkManager.shared.storesImageInStorage(folder: folder, image: image) { (imageURL) in
                    
                    NetworkManager.shared.register(value: imageURL, for: "profileImageURL", in: uid)
                    
                    // The following is not necessary since I'm fetching everything when we're back to profile
                    // self.user?.setValue(value: imageURL, for: .profileImageURL)
                    
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.profileImage.alpha = 1.0
                    
                    self.profileImage.contentMode = .scaleAspectFill
                    self.profileImage.image = image
                    self.user?.setValue(value: imageURL, for: .profileImageURL)
                    self.user?.saveInDisk(value: imageURL, for: .profileImageURL)
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //print("Image picker was canceled")
        dismiss(animated: true, completion: nil)
    }
}
