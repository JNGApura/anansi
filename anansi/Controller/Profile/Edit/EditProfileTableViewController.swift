//
//  EditProfileTableViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 11/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

protocol UserSaveDelegate {
    func userWasSaved(user: User)
}

class EditProfileTableViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate, InterestListDelegate {
    
    // Custom initializers
    let cellIdentifier = "QuestionCell"
    let collectionCellIdentifier = "GradientCell"
        
    let sections = ["About you:", "Favourite TED talk:", "Contact information:"]
    let mapData: [Int : [String]] = [0 : ["name", "occupation", "location", "bio"], 1 : ["TEDtitle", "TEDspeaker"], 2 : ["sharedEmail", "website", "linkedin"]]
    let sectionDataToDisplay: [Int : [String]] = [0 : ["First and last name", "Occupation", "Location", "Short biography"], 1 : ["Title", "Speaker"], 2 : ["Email", "Website", "LinkedIn"]]
    
    var user : User?
    var tempUser : User?
    //var delegate: UserSaveDelegate?
    
    // These three b-thingy variables help keep track of requisits for the questionCell input textfields
    var bName = true        // "name" textfield should not be empty
    var bOccupation = true  // "occupation" textfield should not be empty
    var bLocation = true    // "location" textfield should not be empty
    var characterCountForBio : Int? = 0
    
    lazy var scrollView : UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.backgroundColor = .background
        sv.isUserInteractionEnabled = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView : UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    var profileImage: UIImageView = {
        let i = UIImageView()
        i.layer.cornerRadius = Const.profileImageHeight / 2
        i.clipsToBounds = true
        i.contentMode = .scaleAspectFill
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let editButton: UIButton = {
        let i = UIButton()
        i.setImage(#imageLiteral(resourceName: "editProfileImage").withRenderingMode(.alwaysOriginal), for: .normal)
        i.contentMode = .scaleAspectFill
        i.layer.cornerRadius = 18.0
        i.layer.masksToBounds = false
        i.layer.shadowColor = UIColor.black.cgColor
        i.layer.shadowOpacity = 0.2
        i.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        i.layer.shadowRadius = 4.0
        i.translatesAutoresizingMaskIntoConstraints = false
        i.addTarget(self, action: #selector(handleSelectProfileImageView), for: .touchUpInside)
        return i
    }()
    
    // Gradient / color selection row
    
    let gradientOptionView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let colorLabel: UILabel = {
        let l = UILabel()
        l.text = "Color:"
        l.textColor = .secondary
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    lazy var gradientCollectionView : UICollectionView = {
        let cv = UICollectionView(frame: self.gradientOptionView.frame, collectionViewLayout: UICollectionViewFlowLayout())
        cv.register(GradientCell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isScrollEnabled = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    lazy var currentGradient = user?.gradientColor
    
    // Interests selection row
    
    let interestSelectorView: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let interestLabel: UILabel = {
        let l = UILabel()
        l.text = "Pick your interests:"
        l.textColor = .secondary
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.isUserInteractionEnabled = false // needed so tap gets to parent view
        return l
    }()
    
    lazy var selectedCountLabel: UILabel = {
        let l = UILabel()
        l.textColor = .primary
        l.font = UIFont.systemFont(ofSize: Const.footnoteFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.isUserInteractionEnabled = false // needed so tap gets to parent view
        return l
    }()
    
    let interestIcon: UIImageView = {
        let i = UIImageView()
        i.image = #imageLiteral(resourceName: "next").withRenderingMode(.alwaysTemplate)
        i.tintColor = .primary
        i.translatesAutoresizingMaskIntoConstraints = false
        i.isUserInteractionEnabled = false // needed so tap gets to parent view
        return i
    }()
    var interestList = [String]()
    var interestListWasUpdated = false
    
    // Table with user's data
    
    lazy var tableView : UIDynamicTableView = {
        let tv = UIDynamicTableView()
        tv.register(QuestionCell.self, forCellReuseIdentifier: cellIdentifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = false
        tv.delegate = self
        tv.dataSource = self
        tv.sectionHeaderHeight = 48.0
        tv.estimatedSectionHeaderHeight = 48.0
        tv.estimatedRowHeight = 80.0
        tv.rowHeight = UITableViewAutomaticDimension
        tv.separatorStyle = .none
        tv.allowsSelection = false
        return tv
    }()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
                
        // Sets up navigation bar
        setupNavigationBarItems()
        
        // Sets up UI
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [profileImage, editButton, gradientOptionView, interestSelectorView, tableView].forEach { contentView.addSubview($0) }
        [colorLabel, gradientCollectionView].forEach { gradientOptionView.addSubview($0) }
        [interestLabel, selectedCountLabel, interestIcon].forEach { interestSelectorView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            profileImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Const.marginAnchorsToContent),
            profileImage.widthAnchor.constraint(equalToConstant: Const.profileImageHeight),
            profileImage.heightAnchor.constraint(equalToConstant: Const.profileImageHeight),
            
            editButton.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 4.0),
            editButton.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 4.0),
            editButton.widthAnchor.constraint(equalToConstant: 36.0),
            editButton.heightAnchor.constraint(equalToConstant: 36.0),
            
            // Color row
            gradientOptionView.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: Const.marginEight * 3.0),
            gradientOptionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            gradientOptionView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            gradientOptionView.heightAnchor.constraint(equalToConstant: 56.0),
            
            colorLabel.centerYAnchor.constraint(equalTo: gradientOptionView.centerYAnchor),
            colorLabel.heightAnchor.constraint(equalTo: gradientOptionView.heightAnchor),
            colorLabel.leadingAnchor.constraint(equalTo: gradientOptionView.leadingAnchor, constant: Const.marginEight * 2.0),
            
            gradientCollectionView.centerYAnchor.constraint(equalTo: gradientOptionView.centerYAnchor),
            gradientCollectionView.trailingAnchor.constraint(equalTo: gradientOptionView.trailingAnchor, constant: -Const.marginEight * 1.5),
            gradientCollectionView.widthAnchor.constraint(equalToConstant: 224.0),
            gradientCollectionView.heightAnchor.constraint(equalTo: gradientOptionView.heightAnchor),
            
            // Interests row
            interestSelectorView.topAnchor.constraint(equalTo: gradientOptionView.bottomAnchor, constant: Const.marginEight * 3.0),
            interestSelectorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            interestSelectorView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            interestSelectorView.heightAnchor.constraint(equalToConstant: 56.0),
            
            interestLabel.topAnchor.constraint(equalTo: interestSelectorView.topAnchor),
            interestLabel.leadingAnchor.constraint(equalTo: interestSelectorView.leadingAnchor, constant: Const.marginEight * 2.0),
            interestLabel.trailingAnchor.constraint(equalTo: interestIcon.leadingAnchor),
            interestLabel.heightAnchor.constraint(equalToConstant: 30.0),
            
            selectedCountLabel.topAnchor.constraint(equalTo: interestLabel.bottomAnchor),
            selectedCountLabel.leadingAnchor.constraint(equalTo: interestSelectorView.leadingAnchor, constant: Const.marginEight * 2.0),
            selectedCountLabel.trailingAnchor.constraint(equalTo: interestIcon.leadingAnchor),
            selectedCountLabel.heightAnchor.constraint(equalToConstant: 26.0),
            
            interestIcon.centerYAnchor.constraint(equalTo: interestSelectorView.centerYAnchor),
            interestIcon.trailingAnchor.constraint(equalTo: interestSelectorView.trailingAnchor, constant: -Const.marginEight * 1.5),
            interestIcon.widthAnchor.constraint(equalToConstant: 24.0),
            interestIcon.heightAnchor.constraint(equalToConstant: 24.0),
            
            // Table
            tableView.topAnchor.constraint(equalTo: interestSelectorView.bottomAnchor, constant: Const.marginEight),
            tableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Const.marginEight),
        ])
        
        // Caches profile picture, if exists
        if let profileImageURL = user?.profileImageURL {
            profileImage.loadImageUsingCacheWithUrlString(profileImageURL)
        } else {
            profileImage.image = #imageLiteral(resourceName: "profileImageTemplate").withRenderingMode(.alwaysOriginal)
        }
        
        // Creates temporary user, vessel to store temporary changes to current user (me)
        tempUser = user
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Updates interest list
        if  !interestListWasUpdated, let userInterests = user?.interests {
            interestList = userInterests
        }
        selectedCountLabel.text = "\(interestList.count) interests selected"
        
        // Keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Reloads table to set constraints properly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.reloadData()
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillLayoutSubviews() {
        
        // Need this here, so it can be assigned once rendered
        interestSelectorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleInterestView)))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.view.backgroundColor = .background
        
        let titleLabelView = UILabel()
        titleLabelView.text = "Edit your profile"
        titleLabelView.textColor = .secondary
        titleLabelView.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        navigationItem.titleView = titleLabelView
        
        let leftButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissView))
        leftButton.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: Const.bodyFontSize)], for: .normal)
        leftButton.tintColor = .primary
        navigationItem.leftBarButtonItem = leftButton
        
        let rightButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveNewData))
        rightButton.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: Const.bodyFontSize)], for: .normal)
        rightButton.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: Const.bodyFontSize)], for: .disabled)
        rightButton.tintColor = .primary
        navigationItem.rightBarButtonItem = rightButton
    }

    // MARK: Custom functions

    @objc func dismissView(){
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveNewData(){
        
        user = tempUser
        NetworkManager.shared.registerUserInDB(dictionary: (tempUser?.dictionary)!)
        
        if currentGradient != user?.gradientColor {
            
            NetworkManager.shared.registerUserInDB(dictionary: ["gradientColor" : currentGradient] as! [String : Int])
            user?.setGradientColor(with: currentGradient!)
        }
        
        if interestListWasUpdated {
            
            NetworkManager.shared.registerUserInDB(dictionary: ["interests" : interestList])
            user?.updateInterestList(with: interestList)
        }
                        
        dismiss(animated: true, completion: nil)
    }
    
    func interestListWasSaved(list: [String]) {

        interestList = list
        selectedCountLabel.text = "\(list.count) interests selected"
        interestListWasUpdated = true
    }
    
    @objc func handleInterestView() {
        
        let interestController = InterestsViewController()
        interestController.selectedInterests = interestList
        interestController.delegate = self
        
        navigationController?.pushViewController(interestController, animated: true)
    }
    
    // MARK: - Handle keyboard
    
    var layoutBool = true
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            
            if activeText != nil {
                
                let tag = activeText.tag
                let section = Int(tag / 4)
                let row = tag % 4
                
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as? QuestionCell
                
                let activeTextRelativeMaxY = cell!.frame.maxY + tableView.frame.origin.y - scrollView.contentOffset.y
                let screenHeight = view.frame.height
                var offset: CGFloat = 0
                
                if (screenHeight - activeTextRelativeMaxY) < keyboardHeight {
                    
                    // Quick fix of something I don't understand.
                    if section == 2 && layoutBool && Display.typeIsLike == .iphoneX {
                        offset = 32
                        layoutBool = false
                    }
                    
                    scrollView.frame.origin.y -= keyboardHeight - (screenHeight - activeTextRelativeMaxY - offset)
                    view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        UIView.animate(withDuration: 0.2) {
            self.scrollView.frame.origin.y = 0
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = .background
        
        let label = UILabel(frame: CGRect(x: Const.marginEight * 2.0, y: Const.marginEight * 2.0, width: tableView.frame.width - Const.marginEight * 4.0, height: 32.0))
        label.text = sections[section]
        label.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        label.textColor = .secondary
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sectionDataToDisplay[section]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! QuestionCell
        
        let section = indexPath.section
        let row = indexPath.row
        
        let questionToDisplay = sectionDataToDisplay[section]?[row]
        let questionToQuery = mapData[section]?[row]
        
        cell.textView.delegate = self
        cell.textView.tag = section * 4 + row
        
        cell.questionLabel.text = questionToDisplay
        cell.mappedProperty = questionToQuery
        
        if let dictionary = tempUser?.dictionary { // uses tempUser
            
            if let answer = dictionary[questionToQuery!] as? String {
                
                cell.textView.text = answer
                cell.questionLabel.alpha = 1.0
            } else {
                
                cell.textView.text = questionToDisplay
            }
            
            if questionToQuery == "bio" {
                
                if cell.textView.text == questionToDisplay {
                    
                    characterCountForBio = 0
                } else {
                    
                    characterCountForBio = cell.textView.text!.count
                }
                
                cell.characterLimit.isHidden = false
                cell.characterLimit.text = String(describing: characterCountForBio!) + "/180"
                
                let textHeight = cell.estimateFrameForText(text: cell.textView.text).height + 5
                cell.textViewHeightAnchor?.constant = textHeight
                bioTextHeight = textHeight
            }
        }
        
        return cell
    }
    
    // MARK: UITextViewDelegate
    var activeText: UITextView!
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {

        activeText = textView
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        let section = Int(textView.tag / 4)
        let row = textView.tag % 4
        let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as! QuestionCell
        
        if cell.textView.text == cell.questionLabel.text {
            
            textView.text = ""
            
            cell.questionLabel.alpha = 1.0
            cell.questionLabel.transform = CGAffineTransform(translationX: 0, y: 26.0)
            
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                cell.questionLabel.transform = CGAffineTransform.identity
            })
        }
        
        cell.borderLine.backgroundColor = .primary
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        let section = Int(textView.tag / 4)
        let row = textView.tag % 4
        let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as! QuestionCell
        
        cell.borderLine.backgroundColor = .secondary
        
        if textView.text == "" {
            
            tempUser?.remove(value: cell.textView.text, forKey: cell.mappedProperty!)
            
            cell.questionLabel.alpha = 0.0
            textView.transform = CGAffineTransform(translationX: 0, y: -26.0)
            textView.text = cell.questionLabel.text
            
            if cell.questionLabel.text == "First and last name" {
                
                cell.errorLabel.isHidden = false
                cell.errorLabel.text = "Please enter your name."
                cell.borderLine.backgroundColor = .primary
                bName = false
            }
            
            if cell.questionLabel.text == "Occupation" {
                
                cell.errorLabel.isHidden = false
                cell.errorLabel.text = "Please enter your occupation."
                cell.borderLine.backgroundColor = .primary
                bOccupation = false
            }
            
            if cell.questionLabel.text == "Location" {
                
                cell.errorLabel.isHidden = false
                cell.errorLabel.text = "Please enter your location."
                cell.borderLine.backgroundColor = .primary
                bLocation = false
            }
            
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                textView.transform = CGAffineTransform.identity
            })
            
        } else {
            
            if cell.questionLabel.text ==  "First and last name" { bName = true }
            if cell.questionLabel.text == "Occupation" { bOccupation = true }
            if cell.questionLabel.text == "Location" { bLocation = true }
            
            cell.errorLabel.isHidden = true
            cell.questionLabel.alpha = 1.0
            
            // Stores text in temporary user
            tempUser?.set(value: cell.textView.text, forKey: cell.mappedProperty!)
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = bName && bOccupation && bLocation
        
        activeText = nil
    }
    
    var bioTextHeight : CGFloat!
    
    func textViewDidChange(_ textView: UITextView) {
        
        let section = Int(textView.tag / 4)
        let row = textView.tag % 4
        let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as! QuestionCell
        
        if cell.mappedProperty == "bio", let text = cell.textView.text {
    
            let newTextHeight = cell.estimateFrameForText(text: text).height + 5
            
            if newTextHeight != bioTextHeight {
                
                cell.textViewHeightAnchor?.constant = newTextHeight
                
                UIView.setAnimationsEnabled(false)
                tableView.beginUpdates()
                tableView.endUpdates()
                UIView.setAnimationsEnabled(true)
                
                scrollView.frame.origin.y -= (newTextHeight - bioTextHeight)
            
                bioTextHeight = newTextHeight
            }
        }

    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let section = Int(textView.tag / 4)
        let row = textView.tag % 4
        let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as! QuestionCell
        
        let prospectiveText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let textLength = prospectiveText.count
        
        characterCountForBio = textLength
        cell.characterLimit.text = String(textLength) + "/180"
        
        return textLength <= 180 // maxLength: 180
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Const.colorGradient.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as! GradientCell
        
        let colorGradientOption = Const.colorGradient[indexPath.item]
        
        cell.colorOne = colorGradientOption![0]
        cell.colorTwo = colorGradientOption![1]
        
        if indexPath.item == currentGradient {
            cell.checkIcon.isHidden = false
        }
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / CGFloat(Const.colorGradient.count), height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentCell = collectionView.cellForItem(at: indexPath) as! GradientCell
        currentCell.checkIcon.isHidden = false
        currentGradient = indexPath.item
        
        let cells = collectionView.visibleCells as! [GradientCell]
        for cell in cells {
            
            if cell != currentCell {
                cell.checkIcon.isHidden = true
            }
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    // MARK: ImagePickerController
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        picker.navigationBar.isTranslucent = false
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImage.image = selectedImage
            
            NetworkManager.shared.storesImageInDatabase(folder: "profile_images", image: selectedImage, onSuccess: { (imageURL) in
                
                NetworkManager.shared.registerUserInDB(dictionary: ["profileImageURL": imageURL])
                
                self.user?.setProfileImageURL(with: imageURL)
            })
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //print("Image picker was canceled")
        dismiss(animated: true, completion: nil)
    }
    
}
