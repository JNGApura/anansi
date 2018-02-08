//
//  OnboardingViewController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 17/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class OnboardingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    // Custom initializers
    private let multiplier : CGFloat = 0.4
    
    private let pages = [
        OnboardingPage(title: "Welcome!", description: "Be a part of our chain(ge) (re)action and actively contribute to the dissemination of bold and disruptive ideas."),
        OnboardingPage(title: "Connect", description: "Find your friends and get involved in authentic discussions with other attendees and partners."),
        OnboardingPage(title: "Keep up-to-date", description: "Check out what’s coming up next in our event schedule and speaker lineup."),
    ]
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let bv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        bv.register(OnboardingPageCell.self, forCellWithReuseIdentifier: "OnboardingCellID")
        bv.backgroundColor = .background
        bv.isPagingEnabled = true
        bv.showsHorizontalScrollIndicator = false
        bv.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        bv.translatesAutoresizingMaskIntoConstraints = false
        return bv
    }()
    
    private lazy var avPlayerController: AVPlayerViewController = {
        let avp = AVPlayerViewController()
        avp.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        avp.showsPlaybackControls = false
        avp.view.isUserInteractionEnabled = false
        return avp
    }()
    
    private let nextButton : TertiaryButton = {
        let button = TertiaryButton()
        button.setTitle("Next", for: .normal)
        button.tintColor = .secondary
        button.semanticContentAttribute = .forceRightToLeft
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cellControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.numberOfPages = pages.count
        pc.currentPageIndicatorTintColor = .primary
        pc.pageIndicatorTintColor = UIColor.primary.withAlphaComponent(0.2)
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    private let bottomControlStackView : UIStackView = {
        let sv = UIStackView()
        sv.distribution = .equalSpacing
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let soundButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "muted").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .background
        button.addTarget(self, action: #selector(playsound), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Adds collectionView to view
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let filepath: String = Bundle.main.path(forResource: "intro-video", ofType: "mp4") {
            
            // Adds player to AVPlayerViewController
            let videoSafeWidth = view.safeAreaLayoutGuide.layoutFrame.width
            let videoSafeHeight = view.safeAreaLayoutGuide.layoutFrame.size.height * (1 - multiplier) + Const.marginAnchorsToContent * 2 + 4.0
            
            avPlayerController.player = AVPlayer(url: URL.init(fileURLWithPath: filepath))
            avPlayerController.view.frame = CGRect(x: 0.0, y: 0.0, width: videoSafeWidth, height: videoSafeHeight)
            
            // Adds AVPlayerController to view
            self.addChildViewController(avPlayerController)
            view.addSubview(avPlayerController.view)
            
            // Plays video
            avPlayerController.player?.isMuted = true
            avPlayerController.player?.play()
            
            // Sets notifications for resume playing after reaching the end or when the app enters foreground
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object:nil)
            NotificationCenter.default.addObserver(self, selector: #selector(resumeVideo), name: .UIApplicationWillEnterForeground, object:nil)
            
        } else {
            
            debugPrint("intro-video.mp4 not found")
            // perhaps add image instead - check later.
            return
        }
        
        // Add bottomControlsStackView to view
        bottomControlStackView.addArrangedSubview(cellControl)
        bottomControlStackView.addArrangedSubview(nextButton)
        view.addSubview(bottomControlStackView)
        
        // Place sound control button
        view.addSubview(soundButton)
        
        // Sets up the layout constraints
        setupLayoutConstraints()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        self.avPlayerController.player?.pause()
        self.avPlayerController.player = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    private func setupLayoutConstraints() {
        
        NSLayoutConstraint.activate([
        
            soundButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.0),
            soundButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
            soundButton.widthAnchor.constraint(equalToConstant: 36.0),
            soundButton.heightAnchor.constraint(equalToConstant: 36.0),
            
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            collectionView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: multiplier),
            
            bottomControlStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Const.marginAnchorsToContent),
            bottomControlStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomControlStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Const.marginAnchorsToContent),
            bottomControlStackView.heightAnchor.constraint(equalToConstant: Const.marginAnchorsToContent * 2.5),
        ])
    }
    
    // MARK: Custom functions
    
    @objc func playerDidReachEnd(notification: NSNotification) {
        self.avPlayerController.player?.seek(to: kCMTimeZero)
        self.avPlayerController.player?.play()
    }
    
    @objc func resumeVideo(notification: NSNotification) {
        self.avPlayerController.player?.play()
    }
    
    @objc private func handleNext() {
        
        let nextIndex = min(cellControl.currentPage + 1, pages.count - 1)
        let indexPath = IndexPath(item: nextIndex, section: 0)
        cellControl.currentPage = nextIndex
                
        if cellControl.currentPage == pages.count - 1 {
            nextButton.setTitle("Got it!  ", for: .normal)
            nextButton.setImage(#imageLiteral(resourceName: "next").withRenderingMode(.alwaysTemplate), for: .normal)
            nextButton.addTarget(self, action: #selector(openTabViewController), for: .touchUpInside)
        }
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc private func openTabViewController() {
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        
        let controller = LandingController()//TabBarController()
        present(controller, animated: true, completion: nil)
    }
    
    @objc private func playsound() {
        
        soundButton.setImage(#imageLiteral(resourceName: "sound").withRenderingMode(.alwaysTemplate), for: .normal)
        soundButton.addTarget(self, action: #selector(mutesound), for: .touchUpInside)
        avPlayerController.player?.isMuted = false
    }
    
    @objc private func mutesound() {
        
        soundButton.setImage(#imageLiteral(resourceName: "muted").withRenderingMode(.alwaysTemplate), for: .normal)
        soundButton.addTarget(self, action: #selector(playsound), for: .touchUpInside)
        avPlayerController.player?.isMuted = true
    }
    
    // MARK: CollectionView delegate functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCellID", for: indexPath) as! OnboardingPageCell
        cell.page = pages[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let x = targetContentOffset.pointee.x
        cellControl.currentPage = Int(x / view.frame.width)
        
        if cellControl.currentPage != pages.count - 1 {
            nextButton.setTitle("Next", for: .normal)
            nextButton.setImage(nil, for: .normal)
            nextButton.removeTarget(self, action: #selector(openTabViewController), for: .touchUpInside)
        } else {
            nextButton.setTitle("Got it!  ", for: .normal)
            nextButton.setImage(#imageLiteral(resourceName: "next").withRenderingMode(.alwaysTemplate), for: .normal)
            nextButton.addTarget(self, action: #selector(openTabViewController), for: .touchUpInside)
        }
    }
}
