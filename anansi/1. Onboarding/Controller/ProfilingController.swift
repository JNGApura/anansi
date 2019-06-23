//
//  ProfilingController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 06/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ProfilingController: UIViewController, UIScrollViewDelegate, UIPageViewControllerDelegate {
    
    // Custom initializers    
    private let profilingPages = [
        ProfilingPage(title: "Thanks for signing in!",
                      description: "To connect with other attendees, you need to provide your real name:",
                      questionTitle: "What's your name?",
                      questionPlaceholder: "First and last name"),
        ProfilingPage(title: "Let others get to know you.",
                      description: "Tell other attendees what you do, whether you are a student or a professional.",
                      questionTitle: "What do you do?",
                      questionPlaceholder: "E.g. dream catcher"),
        ProfilingPage(title: "This will break the ice.",
                      description: "Let others know where you are from, or where you work from.",
                      questionTitle: "Where are you from?",
                      questionPlaceholder: "E.g. Atlantis"),
        ProfilingPage(title: "Last step! (optional)",
                      description: "Help others recognize you during the event. You can change this later in Settings.",
                      questionTitle: "profileImage",
                      questionPlaceholder: "profileImage"),
    ]
    
    private var currentPage = 0
    private var imageURL = ""
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.delegate = self
        v.backgroundColor = .background
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let labelPlaceholder: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        l.textColor = UIColor.secondary.withAlphaComponent(0.4)
        l.backgroundColor = .clear
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let nextButton : TertiaryButton = {
        let b = TertiaryButton()
        b.setTitle("Next ", for: .normal)
        b.setTitleColor(.secondary, for: .normal)
        b.setImage(UIImage(named: "next")?.withRenderingMode(.alwaysTemplate), for: .normal)
        b.imageView?.tintColor = .secondary
        b.alpha = 0.4
        b.isEnabled = false
        b.semanticContentAttribute = .forceRightToLeft
        b.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private lazy var pageControl: PageControl = {
        let pc = PageControl()
        pc.currentPage = currentPage
        pc.numberOfPages = profilingPages.count
        pc.spacing = 4.0
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    lazy var answerText: UITextView = {
        let tf = UITextView()
        tf.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tf.textColor = .secondary
        tf.backgroundColor = .clear
        tf.textContainerInset = UIEdgeInsets(top: 2.0, left: 0.0, bottom: -2.0, right: 0.0)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocorrectionType = .no
        tf.delegate = self
        return tf
    }()
    
    lazy var profileImage: UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "profileImageTemplate")!.withRenderingMode(.alwaysOriginal)
        i.tintColor = .secondary
        i.layer.cornerRadius = 42.0
        i.clipsToBounds = true
        i.contentMode = .scaleAspectFill
        i.isHidden = true
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
        i.isHidden = true
        i.translatesAutoresizingMaskIntoConstraints = false
        i.addTarget(self, action: #selector(chooseProfileImage), for: .touchUpInside)
        return i
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
    
    private let bottomControlView: UIView = {
        let v = UIView()
        v.backgroundColor = .background
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private var bottomControlBottomAnchor: NSLayoutConstraint?
    
    private lazy var pageController : UIPageViewController = {
        let pc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pc.setViewControllers([ProfilingPageView(page: profilingPages[currentPage])], direction: .forward, animated: false, completion: nil)
        pc.view.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        // Adds pageController to view as ChilViewController
        addChild(pageController)
        
        // Add other subviews
        bottomControlView.addSubview(nextButton)
        [scrollView, pageControl, bottomControlView].forEach { view.addSubview($0) }
        [pageController.view, answerText, labelPlaceholder, profileImage, activityIndicator, addPictureButton].forEach { scrollView.addSubview($0) }
        
        pageController.didMove(toParent: self)
        
        // Setting up answerTextField to update every time we go to a new page
        answerText.layer.zPosition = 1
        labelPlaceholder.text = profilingPages[currentPage].questionPlaceholder
        answerText.text = ""
        
        // Sets up the layout constraints
        NSLayoutConstraint.activate([
            
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            pageControl.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Const.marginSafeArea),
            pageControl.bottomAnchor.constraint(equalTo: pageController.view.topAnchor, constant: -Const.marginSafeArea),
            pageControl.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),

            pageController.view.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            pageController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -Const.marginSafeArea * 2.0),
            pageController.view.heightAnchor.constraint(equalToConstant: 212.0),
            
            answerText.bottomAnchor.constraint(equalTo: pageController.view.bottomAnchor, constant: -2.0),
            answerText.widthAnchor.constraint(equalTo: pageController.view.widthAnchor, constant: -8.0),
            answerText.centerXAnchor.constraint(equalTo: pageController.view.centerXAnchor),
            answerText.heightAnchor.constraint(equalToConstant: 26.0),
            
            labelPlaceholder.centerXAnchor.constraint(equalTo: answerText.centerXAnchor),
            labelPlaceholder.widthAnchor.constraint(equalTo: answerText.widthAnchor, constant: -10.0),
            labelPlaceholder.topAnchor.constraint(equalTo: answerText.topAnchor),
            labelPlaceholder.heightAnchor.constraint(equalToConstant: 26.0),
            
            profileImage.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            profileImage.bottomAnchor.constraint(equalTo: pageController.view.bottomAnchor, constant: Const.marginEight),
            profileImage.widthAnchor.constraint(equalToConstant: 84.0),
            profileImage.heightAnchor.constraint(equalToConstant: 84.0),
            
            activityIndicator.centerXAnchor.constraint(equalTo: profileImage.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            
            addPictureButton.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 4.0),
            addPictureButton.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 4.0),
            addPictureButton.widthAnchor.constraint(equalToConstant: 36.0),
            addPictureButton.heightAnchor.constraint(equalToConstant: 36.0),
            
            bottomControlView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomControlView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomControlView.heightAnchor.constraint(equalToConstant: Const.marginSafeArea * 2.5),
            
            nextButton.centerYAnchor.constraint(equalTo: bottomControlView.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: bottomControlView.trailingAnchor, constant: -Const.marginSafeArea),
            nextButton.heightAnchor.constraint(equalTo: bottomControlView.heightAnchor),
        ])
        
        bottomControlBottomAnchor = bottomControlView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        bottomControlBottomAnchor?.isActive = true
        
        // Creates keyboard-specific notification observers, so that we can track when the keyboard is presented or is hidden
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Requests notifications, if we haven't asked before
        PushNotificationManager.shared.registerForPushNotifications {
            PushNotificationManager.shared.updateFirestorePushTokenIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if currentPage != profilingPages.count - 1 {
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleFirstReponser), userInfo: nil, repeats: false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Remove keyboard notifications
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("Reclaimed memory for ProfilingController")
    }
    
    // MARK: Custom functions
    
    // Presents keyboard for answerTextField
    @objc func handleFirstReponser() {
        
        answerText.becomeFirstResponder()
    }
    
    // Handles next page
    @objc private func handleNext() {

        // Stores answers from profiling questions
        storeProfilingAnswer(currentPage)
        let nextPage = currentPage + 1
        
        // Next button is disabled to avoid double-tapping
        if nextPage != profilingPages.count - 1 {
            nextButton.isEnabled = false
            self.nextButton.alpha = 0.4
        }
        
        // cellControl is updated with newPage value
        pageControl.setCumulativePageIndicator(nextPage)
        
        // If currentPage is the last, then "Next" becomes "Done"
        if nextPage == profilingPages.count - 1 {
            
            nextButton.setTitle("Done ", for: .normal)
            nextButton.setImage(UIImage(named: "check-progress")?.withRenderingMode(.alwaysTemplate), for: .normal)
            nextButton.imageView?.tintColor = .primary
            nextButton.setTitleColor(.primary, for: .normal)
            nextButton.addTarget(self, action: #selector(pushTabBarController), for: .touchUpInside)
        }
        
        // If we still have profilingPages to present, then we fade-out answerTextField to be updated and we update the viewController in pageController
        if nextPage < profilingPages.count {
            
            // Fades out answerTextField
            UIView.animate(withDuration: 0.3, animations: {
                
                self.answerText.alpha = 0.0
            }, completion: { (true) in
                
                // Updates answerTextField with new values (while faded out)
                self.answerText.text = ""
                self.labelPlaceholder.text = self.profilingPages[nextPage].questionPlaceholder
            })
            
            // Presents next view controller
            pageController.setViewControllers([ProfilingPageView(page: profilingPages[nextPage])], direction: .forward, animated: true, completion: nil)
            
            // Fades in answerTextField
            if nextPage != profilingPages.count - 1 {
                
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    self?.answerText.alpha = 1.0
                    
                }, completion: { [weak self] (true) in
                    self?.labelPlaceholder.isHidden = false
                })
            } else {
                
                answerText.resignFirstResponder()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.profileImage.isHidden = false
                    self.addPictureButton.isHidden = false
                }
            }
            
            currentPage = nextPage
        }
    }
    
    // Stores answers in UserDefaults
    func storeProfilingAnswer(_ currentPage: Int) {

        let answer = answerText.text
        
        switch currentPage {
        case 0:
            userDefaults.updateObject(for: userInfoType.name.rawValue, with: answer)
            
        case 1:
            userDefaults.updateObject(for: userInfoType.occupation.rawValue, with: answer)
            
        case 2:
            userDefaults.updateObject(for: userInfoType.location.rawValue, with: answer)
            
            // Now we're done with the mandatory fields, let's create the user!
            createUser()
            
        case 3:
            userDefaults.updateObject(for: userInfoType.profileImageURL.rawValue, with: imageURL)
            
        default:
            print("Ups, something went wrong here!")
        }
    }
    
    // Sends user to ProfilingController with custom transition
    @objc func pushTabBarController() {
        
        // Hides keyboard
        self.answerText.resignFirstResponder()
        
        // Stores default booleans for the walkthrough / onboarding
        userDefaults.updateObject(for: userDefaults.isProfiled, with: true)
        
        userDefaults.updateObject(for: userDefaults.isCommunityOnboarded, with: false)
        userDefaults.updateObject(for: userDefaults.isConnectOnboarded, with: false)
        userDefaults.updateObject(for: userDefaults.isEventOnboarded, with: false)
        userDefaults.updateObject(for: userDefaults.isProfileOnboarded, with: false)
        
        // Sends user to TabBarController
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            let controller = TabBarController()
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func createUser() {
        
        let email = userDefaults.string(for: userInfoType.email.rawValue) ?? ""
        let ticket = userDefaults.string(for: userInfoType.ticket.rawValue) ?? ""
        let name = userDefaults.string(for: userInfoType.name.rawValue) ?? ""
        let occupation = userDefaults.string(for: userInfoType.occupation.rawValue) ?? ""
        let location = userDefaults.string(for: userInfoType.location.rawValue) ?? ""
        
        NetworkManager.shared.createUserInDB(email: email, ticket: ticket, name: name, occupation: occupation, location: location, onSuccess: nil)
        
        // Print user UID
        print(NetworkManager.shared.getUID()!)
    }
    
    // MARK : KEYBOARD-related functions
    
    @objc func keyboardWillHide() {
        
        bottomControlBottomAnchor?.constant = 0
        scrollView.transform = CGAffineTransform.identity
        view.layoutIfNeeded() // Forces the layout of the subtree animation block and then captures all of the frame changes
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            
            if Display.typeIsLike == .iphoneX {
                 bottomControlBottomAnchor?.constant = -keyboardHeight + 28
            } else {
                bottomControlBottomAnchor?.constant = -keyboardHeight
                view.layoutIfNeeded()
            }
            
            let answerTextRelativeMaxY = answerText.frame.maxY
            let bottomControlHeight = bottomControlView.frame.height
            let screenHeight = view.frame.height
            
            let offsetY = (screenHeight - answerTextRelativeMaxY - bottomControlHeight - 12)
            
            if offsetY < keyboardHeight {
                
                scrollView.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight - offsetY))
                view.layoutIfNeeded()
            }
        }
    }
}
    
// MARK : UITextViewDelegate functions

extension ProfilingController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let prospectiveText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let textLength = prospectiveText.count
        
        // Presents placeholder when length == 0
        if textLength > 0 {
            labelPlaceholder.isHidden = true
        } else {
            labelPlaceholder.isHidden = false
        }
        
        // Enables button when length > 2
        if textLength > 2 {
        
            nextButton.isEnabled = true
            nextButton.alpha = 1
        } else {
            
            nextButton.isEnabled = false
            nextButton.alpha = 0.4
        }
        
        return true
    }
}

// MARK: ImagePickerController

extension ProfilingController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
            
            let uid = NetworkManager.shared.getUID()

            profileImage.alpha = 0.5
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            NetworkManager.shared.removesImageFromStorage(folder: "profile_images") {

                NetworkManager.shared.storesImageInStorage(folder: "profile_images", image: image,
                    onSuccess: { [weak self] (imageURL) in
                    
                        self?.imageURL = imageURL
                        NetworkManager.shared.register(value: imageURL, for: userInfoType.profileImageURL.rawValue, in: uid!)
                        
                        self?.activityIndicator.isHidden = true
                        self?.activityIndicator.stopAnimating()
                        self?.profileImage.alpha = 1.0
                        
                        self?.profileImage.contentMode = .scaleAspectFill
                        self?.profileImage.image = image
                    
                    }, onFailure: { [weak self] in
                        
                        self?.activityIndicator.isHidden = true
                        self?.activityIndicator.stopAnimating()
                        self?.profileImage.alpha = 1.0
                        
                        self?.profileImage.contentMode = .scaleAspectFill
                        self?.profileImage.image = image
                })
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //print("Image picker was canceled")
        dismiss(animated: true, completion: nil)
    }
}
