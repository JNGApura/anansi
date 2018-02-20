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

class InterestsViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Custom initializers
    let collectionCellIdentifier = "InterestCell"
    
    var delegate: InterestListDelegate?
    
    var selectedInterests : [String]! {
        didSet {
            countInterests = selectedInterests.count
            selectedLabel.text = "\(countInterests) selected"
        }
    }
    var countInterests : Int = 0
    
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
        tl.textAlignment = .center
        tl.numberOfLines = 0
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.isUserInteractionEnabled = true
        tl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saveSelection)))
        return tl
    }()
    
    let screenDescription: UILabel = {
        let tl = UILabel()
        tl.text = "Tap on the interests to add to your list. Please select up to 6 interests."
        tl.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tl.textColor = .secondary
        tl.textAlignment = .center
        tl.numberOfLines = 0
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    lazy var collectionView : UICollectionView = {
        let cv = UICollectionView(frame: contentView.frame, collectionViewLayout: UICollectionViewFlowLayout())
        cv.register(InterestCell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isScrollEnabled = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .background
        return cv
    }()
    var interestCollectionViewHeightAnchor: NSLayoutConstraint?
    
    let backgroundStatsView : UIView = {
        let v = UIView()
        v.backgroundColor = .background
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    var backgroundStatsViewHeightAnchor: NSLayoutConstraint?
    
    let statsView : UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let selectedLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        l.textColor = .primary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let maxInterestsLabel: UILabel = {
        let l = UILabel()
        l.text = " / 6 interests"
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        l.textColor = .secondary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up navigation bar
        setupNavigationBarItems()
        
        // Sets left aligned layout for the collectionView
        let layout = UICollectionViewAlignedLayout()
        layout.layoutDirection = .left
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        // Sets up UI
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [screenTitle, screenDescription, collectionView, backgroundStatsView, statsView].forEach { contentView.addSubview($0) }
        [selectedLabel, maxInterestsLabel].forEach { statsView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -55.0),
            
            // Title and description
            screenTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Const.marginEight * 3.0),
            screenTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            screenTitle.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -Const.marginEight * 4.0),
            
            screenDescription.topAnchor.constraint(equalTo: screenTitle.bottomAnchor, constant: Const.marginEight * 1.5),
            screenDescription.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            screenDescription.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -Const.marginEight * 4.0),
            
            // Color row
            collectionView.topAnchor.constraint(equalTo: screenDescription.bottomAnchor, constant: Const.marginEight * 3.0),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Const.marginEight * 2.0),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Const.marginEight * 2.0),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Const.marginEight),
            
            // Stats view
            backgroundStatsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundStatsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundStatsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            statsView.centerXAnchor.constraint(equalTo: backgroundStatsView.centerXAnchor),
            statsView.topAnchor.constraint(equalTo: backgroundStatsView.topAnchor, constant: Const.marginEight * 2.0),
            statsView.widthAnchor.constraint(equalToConstant: 183.0),
            statsView.heightAnchor.constraint(equalToConstant: 23.0),
            
            selectedLabel.leadingAnchor.constraint(equalTo: statsView.leadingAnchor),
            selectedLabel.centerYAnchor.constraint(equalTo: statsView.centerYAnchor),
            
            maxInterestsLabel.leadingAnchor.constraint(equalTo: selectedLabel.trailingAnchor),
            maxInterestsLabel.centerYAnchor.constraint(equalTo: statsView.centerYAnchor),
        ])
        
        interestCollectionViewHeightAnchor = collectionView.heightAnchor.constraint(equalToConstant: 0.0)
        interestCollectionViewHeightAnchor?.isActive = true
        
        backgroundStatsViewHeightAnchor = backgroundStatsView.heightAnchor.constraint(equalToConstant: 55.0)
        backgroundStatsViewHeightAnchor?.isActive = true
        
        if Display.typeIsLike == .iphoneX {
            backgroundStatsViewHeightAnchor?.constant = 87.0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Sets height = contentSize.height for the collectionView
        interestCollectionViewHeightAnchor?.constant = collectionView.contentSize.height
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    private func setupNavigationBarItems() {
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.view.backgroundColor = .background
        
        let t = UILabel()
        t.text = "Interests"
        t.textColor = .secondary
        t.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        navigationItem.titleView = t
        
        let lb = UIButton(type: .system)
        lb.setImage(#imageLiteral(resourceName: "back").withRenderingMode(.alwaysTemplate), for: .normal)
        lb.frame = CGRect(x: 0, y: 0, width: Const.navButtonHeight, height: Const.navButtonHeight)
        lb.tintColor = .primary
        lb.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: lb)
        
        let rb = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(saveSelection))
        rb.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: Const.bodyFontSize)], for: .normal)
        rb.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: Const.bodyFontSize)], for: .disabled)
        rb.tintColor = .primary
        navigationItem.rightBarButtonItem = rb
    }

    // MARK: Custom functions
    
    @objc func backAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveSelection() {
        
        self.delegate?.interestListWasSaved(list: selectedInterests!)
        navigationController?.popViewController(animated: true)
    }
    
    func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: view.frame.width, height: 1000) // height arbitrarily high
        let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: Const.calloutFontSize)], context: nil)
    }
        
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Const.interests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as! InterestCell
        
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
        
        selectedLabel.text = "\(countInterests) selected"
        
        if countInterests > 6 {
            
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let string = Const.interests[indexPath.item]
        return CGSize(width: estimateFrameForText(text: string).width + 16, height: 28.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
}
