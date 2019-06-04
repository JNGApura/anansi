//
//  InterestsViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 17/02/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

protocol InterestListDelegate {
    func interestListWasSaved(list: [String])
}

class InterestsViewController: UIViewController, UIScrollViewDelegate {
    
    // Custom initializers
    
    var delegate: InterestListDelegate?
    
    var selectedInterests : [String]! {
        didSet {
            countInterests = selectedInterests.count
            selectedInterestsLabel.text = "\(countInterests) / 7 "
        }
    }
    var countInterests : Int = 0
    
    lazy var topbar: TopBar = {
        let b = TopBar()
        b.setTitle(name: "Interests")
        b.backgroundColor = .background
        b.backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
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
    
    let screenTitle: UILabel = {
        let tl = UILabel()
        tl.text = "Tell other attendees what you're into"
        tl.font = UIFont.boldSystemFont(ofSize: Const.headlineFontSize)
        tl.textColor = .secondary
        tl.numberOfLines = 0
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.isUserInteractionEnabled = true
        tl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saveSelection)))
        return tl
    }()
    
    let screenDescription: UILabel = {
        let tl = UILabel()
        tl.text = "We’ll use them to match with others based on common interests."
        tl.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tl.textColor = .secondary
        tl.numberOfLines = 0
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    lazy var collectionView : UICollectionView = {
        let cv = UICollectionView(frame: contentView.frame, collectionViewLayout: UICollectionViewFlowLayout())
        cv.register(InterestCell.self, forCellWithReuseIdentifier: "InterestCell")
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isScrollEnabled = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .background
        return cv
    }()
    var interestCollectionViewHeightAnchor: NSLayoutConstraint?
    
    lazy var saveButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("Save interests", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        b.tintColor = .background
        b.layer.cornerRadius = 20
        b.clipsToBounds = true
        b.adjustsImageWhenDisabled = false
        b.addTarget(self, action: #selector(saveSelection), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    lazy var buttonBackground: UIView = {
        let b = UIView()
        b.backgroundColor = .background
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    lazy var selectedInterestsLabel: UILabel = {
        let l = UILabel()
        l.text = "\(countInterests) / 7 "
        l.font = UIFont.boldSystemFont(ofSize: Const.footnoteFontSize)
        l.textColor = .secondary
        l.layer.cornerRadius = 10.0
        l.clipsToBounds = true
        l.backgroundColor = .tertiary
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    lazy var barHeight : CGFloat = (navigationController?.navigationBar.frame.height)!
    let statusBarHeight : CGFloat = UIApplication.shared.statusBarFrame.height
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        // Sets left aligned layout for the collectionView
        let layout = UICollectionViewAlignedLayout()
        layout.layoutDirection = .left
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        // Sets up UI
        [topbar, selectedInterestsLabel, scrollView].forEach { view.addSubview($0) }
        scrollView.addSubview(contentView)
        [screenTitle, screenDescription, collectionView, buttonBackground, saveButton].forEach { contentView.addSubview($0) }
        
        // Needs to be in viewDidLoad
        interestCollectionViewHeightAnchor = collectionView.heightAnchor.constraint(equalToConstant: 0.0)
        interestCollectionViewHeightAnchor?.isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupNavigationBarItems()
        
        // Sets height = contentSize.height for the collectionView
        interestCollectionViewHeightAnchor?.constant = collectionView.contentSize.height
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        // Navigation Bar was hidden in viewDidAppear
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topbar.setStatusBarHeight(with: statusBarHeight)
        topbar.setNavigationBarHeight(with: barHeight)
        
        NSLayoutConstraint.activate([
            
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: topbar.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // Title and description
            screenTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Const.marginSafeArea),
            screenTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            screenTitle.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -(Const.marginSafeArea * 2.0)),
            
            screenDescription.topAnchor.constraint(equalTo: screenTitle.bottomAnchor, constant: Const.marginSafeArea),
            screenDescription.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            screenDescription.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -(Const.marginSafeArea * 2.0)),
            
            // Interest collectionview
            collectionView.topAnchor.constraint(equalTo: screenDescription.bottomAnchor, constant: Const.marginSafeArea),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Const.marginSafeArea),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Const.marginSafeArea),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            buttonBackground.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor),
            buttonBackground.topAnchor.constraint(equalTo: saveButton.topAnchor, constant: -Const.marginEight),
            buttonBackground.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonBackground.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Const.marginEight),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Const.marginSafeArea),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Const.marginSafeArea),
            saveButton.heightAnchor.constraint(equalToConstant: 40.0),
            
            topbar.topAnchor.constraint(equalTo: view.topAnchor),
            topbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topbar.heightAnchor.constraint(equalToConstant: barHeight + statusBarHeight),
            
            selectedInterestsLabel.centerYAnchor.constraint(equalTo: topbar.bottomAnchor, constant: -barHeight / 2.0),
            selectedInterestsLabel.trailingAnchor.constraint(equalTo: topbar.trailingAnchor, constant: -Const.marginEight * 2.0),
            selectedInterestsLabel.widthAnchor.constraint(equalToConstant: 48.0),
            selectedInterestsLabel.heightAnchor.constraint(equalToConstant: 20.0),
        ])
    }
    
    private func setupNavigationBarItems() {
        
        //navigationItem.titleView = nil
        //navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    // MARK: Custom functions
    
    @objc func backAction(_ sender: UIBarButtonItem) {
        
        if countInterests <= 7 {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func saveSelection() {
        
        self.delegate?.interestListWasSaved(list: selectedInterests!)
        
        saveButton.setImage(UIImage(named: "check-progress")!.withRenderingMode(.alwaysTemplate), for: .normal)
        saveButton.setTitle(" Interests saved!", for: .normal)
        saveButton.isEnabled = false
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
            
            self.saveButton.setImage(nil, for: .normal)
            self.saveButton.setTitle("Save interests", for: .normal)
            self.saveButton.isEnabled = true
        }
    }
    
    func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: view.frame.width, height: 1000) // height arbitrarily high
        let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes:
            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Const.calloutFontSize)], context: nil)
    }
    
}


// MARK: UICollectionViewDelegate

extension InterestsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Const.interests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestCell", for: indexPath) as! InterestCell

        cell.text = Const.interests[indexPath.item]
        
        if selectedInterests!.contains(cell.text!) {
            cell.select()
        } else {
            cell.unselect()
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! InterestCell
        
        if cell.isInterestSelected() {
            
            cell.unselect()
            countInterests -= 1
            let ind = selectedInterests.index(of: cell.titleLabel.text!)
            selectedInterests.remove(at: ind!)
            
        } else {
            
            cell.select()
            countInterests += 1
            selectedInterests.append(cell.titleLabel.text!)
        }
        
        selectedInterestsLabel.text = "\(countInterests) / 7 "
        
        // Check if countInterests > 7
        if countInterests > 7 {
            
            saveButton.isEnabled = false
            saveButton.alpha = 0.4
            saveButton.setTitle("Too many interests 😬", for: .normal)
            
        } else {
            
            saveButton.isEnabled = true
            saveButton.alpha = 1
            saveButton.setTitle("Save interests", for: .normal)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let string = Const.interests[indexPath.item]
        return CGSize(width: estimateFrameForText(text: string).width + 16, height: 28.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 58.0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
}
