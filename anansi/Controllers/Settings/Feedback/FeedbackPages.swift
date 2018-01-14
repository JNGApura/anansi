//
//  FeedbackPages.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 12/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class FeedbackPages: UIViewController {

    // Custom initializers
    let indentifier : Int
    weak var square: UIView!
    
    // Initializer
    init(identifier: Int) {
        self.indentifier = identifier
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets contstants
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let screenHeight = screensize.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let navigationBarHeight = (self.navigationController?.navigationBar.frame.size.height)!
        
        // Get the superview's layout
        let margins = view.layoutMarginsGuide

        // If identifier = 1, then we ask what the user thinks of the app
        if indentifier == 1 {
            
            let imageView = UIImageView(image: #imageLiteral(resourceName: "happy"))
            view.addSubview(imageView)
            
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                //imageView.widthAnchor.constraint(equalToConstant: 100)
                ])
            
            //imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            //imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -44.0).isActive = true
            //imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            //imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            /*let feedbackView: UIView = UIView(frame: CGRect(x: 0, y: screenHeight / 3 - 44.0, width: screenWidth, height: 188.0))
            feedbackView.backgroundColor = .white
            feedbackView.isOpaque = true
            view.addSubview(feedbackView)
            
            let feedbackQuestion: UILabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 64.0))
            let txtStringOne = "We'd love to know\nwhat you think of our app?"
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 16
            style.minimumLineHeight = 16
            let attributes = [NSAttributedStringKey.paragraphStyle: style,
                              NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 22),
                              NSAttributedStringKey.foregroundColor: UIColor.black
            ]
            
            feedbackQuestion.attributedText = NSAttributedString(string: txtStringOne,
                                                                 attributes: attributes)
            feedbackQuestion.numberOfLines = 0
            feedbackQuestion.lineBreakMode = NSLineBreakMode.byWordWrapping
            feedbackQuestion.textAlignment = .center
            feedbackQuestion.sizeToFit()
            feedbackQuestion.frame = CGRect(x: 0.0, y: 0, width: screenWidth, height: feedbackQuestion.frame.size.height)
            feedbackQuestion.backgroundColor = .clear
            feedbackView.addSubview(feedbackQuestion)
            
            let iconSpace: UIView = UIView(frame: CGRect(x: 0.0, y: feedbackQuestion.frame.height + 44.0, width: screenWidth, height: 80.0))
            feedbackView.addSubview(iconSpace)
            
            let happyButton: UIButton = UIButton(frame: CGRect(x: feedbackView.frame.size.width - 72.0 - 80.0, y: 0.0, width: 80.0, height: 80.0))
            happyButton.setImage(#imageLiteral(resourceName: "happy").withRenderingMode(.alwaysTemplate), for: .normal)
            happyButton.clipsToBounds = true
            happyButton.layer.cornerRadius = 40.0
            happyButton.translatesAutoresizingMaskIntoConstraints = true
            happyButton.addTarget(self, action: #selector(buttonHappyClicked), for: .touchUpInside)
            happyButton.backgroundColor = .white
            happyButton.tintColor = .black
            iconSpace.addSubview(happyButton)
            
            let unhappyButton: UIButton = UIButton(frame: CGRect(x: 72.0, y: 0.0, width: 80.0, height: 80.0))
            unhappyButton.setImage(#imageLiteral(resourceName: "unhappy").withRenderingMode(.alwaysTemplate), for: .normal)
            unhappyButton.clipsToBounds = true
            unhappyButton.layer.cornerRadius = 40.0
            unhappyButton.translatesAutoresizingMaskIntoConstraints = true
            unhappyButton.addTarget(self, action: #selector(buttonUnhappyClicked), for: .touchUpInside)
            unhappyButton.backgroundColor = .white
            unhappyButton.tintColor = .black
            iconSpace.addSubview(unhappyButton)*/
            
        // Else, the user has selected a flow (happy vs unhappy)
        } else {
            
        }

        self.view.backgroundColor = .white
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func buttonHappyClicked() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "happyButton"), object: self)
        
        // TO DO: why of storing this in the back-end somehow
        print("happy button clicked")
    }
    
    @objc func buttonUnhappyClicked() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "unhappyButton"), object: self)
        
        // TO DO: why of storing this in the back-end somehow
        print("unhappy button clicked")
    }

}
