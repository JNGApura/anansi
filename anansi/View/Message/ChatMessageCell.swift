//
//  ChatMessageCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    // MARK: Custom initializers
    
    var message: Message?
    
    var chatLogController : ChatLogController?
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .primary
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    
    let timeDate : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.secondary.withAlphaComponent(0.6)
        l.textAlignment = .center
        l.backgroundColor = .background
        l.font = UIFont.boldSystemFont(ofSize: Const.footnoteFontSize)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    var timeDateHeightAnchor: NSLayoutConstraint? // To be able to modify the constraint externally
    
    let textView : UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: Const.bodyFontSize)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.isEditable = false
        return tv
    }()
    
    lazy var messageImageView : UIImageView = {
        let i = UIImageView()
        i.translatesAutoresizingMaskIntoConstraints = false
        i.layer.cornerRadius = 16
        i.layer.masksToBounds = true
        i.layer.borderWidth = 2
        i.contentMode = .scaleAspectFill
        i.isUserInteractionEnabled = true
        i.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return i
    }()
    
    let bubbleView: UIView = {
        let bv = UIView()
        bv.layer.borderWidth = 2
        bv.layer.borderColor = UIColor.red.cgColor
        bv.layer.cornerRadius = 16
        bv.layer.masksToBounds = true
        bv.translatesAutoresizingMaskIntoConstraints = false
        return bv
    }()
    
    // To be able to modify the constraints externally
    var bubbleViewWidthAnchor: NSLayoutConstraint?
    var bubbleViewHeightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    
    // MARK: Cell init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add subviews
        [timeDate, bubbleView, textView].forEach( {addSubview($0)} )
        [messageImageView, playButton, activityIndicatorView].forEach( {bubbleView.addSubview($0)} )
        
        // Add layout constraints to subviews
        setupLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Cleans up notifications
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK : Layout
    
    private func setupLayoutConstraints() {
        
        NSLayoutConstraint.activate([
            
            timeDate.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeDate.widthAnchor.constraint(equalTo: widthAnchor),
            
            bubbleView.topAnchor.constraint(equalTo: timeDate.bottomAnchor),
            bubbleView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            textView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: Const.marginEight),
            textView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            textView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -Const.marginEight),
            textView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor),
            
            messageImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
            messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor),
            messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor),
            
            playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 80),
            playButton.heightAnchor.constraint(equalToConstant: 80),
            
            activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 50),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        timeDateHeightAnchor = timeDate.heightAnchor.constraint(equalToConstant: Const.timeDateHeightChatCells)
        timeDateHeightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Const.marginEight * 2.0)
        bubbleViewLeftAnchor?.isActive = false
        
        bubbleViewRightAnchor = bubbleView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Const.marginEight * 2.0)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewHeightAnchor = bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor)
        bubbleViewHeightAnchor?.isActive = true
        
        bubbleViewWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 240)
        bubbleViewWidthAnchor?.isActive = true
        
    }
    
    // MARK: Custom functions
    
    // Performs zoom in when picture is tapped
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        
        // For videos, zoom tap animation is not initiated
        if message?.videoURL != nil {
            
            player?.pause()
            playerLayer?.removeFromSuperlayer()
            activityIndicatorView.stopAnimating()
            playButton.isHidden = false
            
            return
        }
        
        if let imageView = tapGesture.view as? UIImageView {
            self.chatLogController?.performZoomInForStartingImageView(imageView: imageView)
        }
    }
    
    // Handles video play
    @objc func handlePlay() {
        
        if let videoURLString = message?.videoURL, let url = URL(string: videoURLString) {
            
            player = AVPlayer(url: url)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
            
            // Sets notifications for resume playing after reaching the end or when the app enters foreground
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object:nil)
            //NotificationCenter.default.addObserver(self, selector: #selector(resumeVideo), name: .UIApplicationWillEnterForeground, object:nil)
            
        } else {
            
            // if couldnt contact firebase? perhaps change icon
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        activityIndicatorView.stopAnimating()
    }
    
    @objc func playerDidReachEnd(notification: NSNotification) {
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        activityIndicatorView.stopAnimating()
        playButton.isHidden = false
    }
}
