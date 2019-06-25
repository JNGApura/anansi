//
//  ChatTableCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 25/01/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class ChatTableCell: UITableViewCell {
    
    // MARK: Custom initializers
    
    public private(set) var isAnimating: Bool = false
    
    let myID = NetworkManager.shared.getUID()
    
    //var message : Message?
    
    let profileImageView: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.translatesAutoresizingMaskIntoConstraints = false
        i.layer.cornerRadius = 60.0 / 2
        i.layer.masksToBounds = true
        i.clipsToBounds = true
        return i
    }()
    
    let readbadge: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.layer.cornerRadius = 14.0 / 2
        i.layer.masksToBounds = true
        i.clipsToBounds = true
        i.isHidden = true
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let name: UILabel = {
        let tl = UILabel()
        tl.text = ""
        tl.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        tl.textColor = .secondary
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let lastMessage: UILabel = {
        let tl = UILabel()
        tl.text = ""
        tl.textAlignment = .left
        tl.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        tl.textColor = UIColor.secondary.withAlphaComponent(0.4)
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let timeLabel: UILabel = {
        let l = UILabel()
        l.text = ""
        l.font = UIFont.systemFont(ofSize: Const.subheadFontSize)
        l.textColor = UIColor.secondary.withAlphaComponent(0.4)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let bottomStackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .leading
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let stackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .leading
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let separator: UIView = {
        let v = UIView()
        v.backgroundColor = .tertiary
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // isTyping indicator (UI)
    
    let bubble: UIView = {
        let bv = UIView()
        bv.layer.cornerRadius = 10
        bv.layer.masksToBounds = true
        bv.clipsToBounds = true
        bv.backgroundColor = .init(red: 245/255.0, green: 245/255.0, blue: 248/255.0, alpha: 1.0)
        bv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bv.translatesAutoresizingMaskIntoConstraints = false
        return bv
    }()
    
    let dots : [UIView] = [UIView(), UIView(), UIView()]
    
    lazy var typingIndicator: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        // Add typing subviews
        for dot in dots {
            
            dot.layer.cornerRadius = 3.0
            dot.clipsToBounds = true
            dot.backgroundColor = .lightGray
            dot.translatesAutoresizingMaskIntoConstraints = false
            
            dot.widthAnchor.constraint(equalTo: dot.heightAnchor).isActive = true
            dot.widthAnchor.constraint(equalToConstant: 6.0).isActive = true
            
            typingIndicator.addArrangedSubview(dot)
            typingIndicator.setCustomSpacing(4.0, after: dot)
        }
        
        bubble.addSubview(typingIndicator)
        [lastMessage, timeLabel].forEach { bottomStackView.addArrangedSubview($0) }
        [name, bottomStackView].forEach { stackView.addArrangedSubview($0) }
        stackView.setCustomSpacing(Const.marginEight / 4.0, after: name)
        
        [profileImageView, stackView, readbadge, bubble, separator].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.0),
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: Const.marginEight * 1.5),
            profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Const.marginEight * 1.5),
            profileImageView.widthAnchor.constraint(equalToConstant: 60.0),
            profileImageView.heightAnchor.constraint(equalToConstant: 60.0),
            
            name.heightAnchor.constraint(equalToConstant: 24.0),
            lastMessage.heightAnchor.constraint(equalToConstant: 20.0),
            timeLabel.heightAnchor.constraint(equalToConstant: 20.0),
            bottomStackView.heightAnchor.constraint(equalToConstant: 20.0),
            
            stackView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: Const.marginEight * 2.0),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -42.0),
            
            readbadge.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            readbadge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            readbadge.heightAnchor.constraint(equalToConstant: 14.0),
            readbadge.widthAnchor.constraint(equalToConstant: 14.0),
            
            bubble.topAnchor.constraint(equalTo: bottomStackView.topAnchor),
            bubble.leadingAnchor.constraint(equalTo: bottomStackView.leadingAnchor),
            bubble.heightAnchor.constraint(equalToConstant: 20.0),
            bubble.widthAnchor.constraint(equalToConstant: 48.0),
            
            typingIndicator.centerXAnchor.constraint(equalTo: bubble.centerXAnchor),
            typingIndicator.centerYAnchor.constraint(equalTo: bubble.centerYAnchor),
            
            separator.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
     }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset labels
        name.text = ""
        lastMessage.text = ""
        timeLabel.text = ""
        
        // Reset profileImageTemplate
        profileImageView.image = UIImage(named: "profileImageTemplate")?.withRenderingMode(.alwaysOriginal)
        
        // Hides readbadge
        readbadge.isHidden = true
        
        // Resets animation & hides typing bubble
        bubble.isHidden = true
        stopAnimating()
    }
    
    
    func configure(with message: Message, from user: User, and isTyping : Bool) {
        
        //self.message = message
        
        // Display message
        var displayMessage = String()
        
        // User name
        name.text = user.getValue(forField: .name) as? String
        
        // Sets user's profile image
        if let imageURL = (user.getValue(forField: .profileImageURL) as? String) {
            profileImageView.setImage(with: imageURL)
            
        } else {
            profileImageView.image = UIImage(named: "profileImageTemplate")?.withRenderingMode(.alwaysOriginal)
        }
        
        // Logic for unreads & reads
        if let isRead = message.getValue(forField: .isRead) as? Bool,
            let sender = message.getValue(forField: .sender) as? String {
            
            // If it's read and I'm the sender, show badge with user's profile image
            if isRead && sender == myID {
                
                readbadge.isHidden = false
                
                // Set user's profile image
                if let imageURL = (user.getValue(forField: .profileImageURL) as? String) {
                    readbadge.setImage(with: imageURL)
                    readbadge.backgroundColor = .clear
                    
                } else {
                    readbadge.image = UIImage(named: "profileImageTemplate")?.withRenderingMode(.alwaysOriginal)
                    readbadge.backgroundColor = .clear
                }
                
            } else if !isRead && sender != myID {
                readbadge.isHidden = false
                readbadge.image = nil
                readbadge.backgroundColor = .primary

            } else {
                readbadge.isHidden = true
                readbadge.image = nil               // reset
                readbadge.backgroundColor = .clear  // reset
            }
        }
    
        // Sets message box
        if isTyping {
            
            // Sets up UI
            bubble.isHidden = false
            lastMessage.isHidden = true
            timeLabel.isHidden = true
            
            // Starts isTyping animation
            if !isAnimating {
                startAnimating()
            } else {
                stopAnimating()
                startAnimating()
            }
            
        } else {
            
            // Sets up UI
            bubble.isHidden = true
            lastMessage.isHidden = false
            timeLabel.isHidden = false
            
            // Stops isTyping animation
            if isAnimating { stopAnimating() }

            // Sender
            if let sender = message.getValue(forField: .sender) as? String, sender == myID {
                displayMessage += "You: "
            }
            
            // Message
            if let message = message.getValue(forField: .text) as? String {
                
                if message == Const.stickerString {
                    displayMessage += "🧭"
                } else {
                    displayMessage += message
                }
            }
            lastMessage.text = displayMessage
            
            // Sets timestamp
            if let seconds = (message.getValue(forField: .timestamp) as? NSNumber)?.doubleValue {
                timeLabel.text = " · " + createDateIntervalString(from: NSDate(timeIntervalSince1970: seconds))
            }
        }
    }
    
    /*
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        //let myViewBackgroundColor = self.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        self.backgroundColor = UIColor.tertiary.withAlphaComponent(0.3)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        //let myViewBackgroundColor = self.backgroundColor
        super.setSelected(selected, animated: animated)
        self.backgroundColor = UIColor.tertiary.withAlphaComponent(0.3)
    }*/
    

    /*
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            self.backgroundColor = UIColor.tertiary.withAlphaComponent(0.3)
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundColor = .clear
            })
            //self.backgroundColor = .clear
            //UIView.animate(withDuration: 0.1, animations: {
                
            //})
        }
    }*/
    
    /*
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.backgroundColor = UIColor.tertiary.withAlphaComponent(0.3)
            self.selectedBackgroundView = createViewWithBackgroundColor(.clear)
            
            //self.backgroundColor = UIColor.tertiary.withAlphaComponent(0.3)
        } else {
            self.backgroundColor = .clear
            self.selectedBackgroundView = createViewWithBackgroundColor(.clear)
            //self.selectedBackgroundView = createViewWithBackgroundColor(.clear)
            //UIView.animate(withDuration: 0.1, animations: {
                
            //})
        }
    }*/
    
    /*
    override func setSelected(_ selected: Bool, animated: Bool) {
        self.backgroundColor = UIColor.tertiary.withAlphaComponent(0.3)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.backgroundColor = .background
    }*/
    
    
    // MARK: - Animation API
    
    open var opacityAnimationLayer: CABasicAnimation {
        let a = CABasicAnimation(keyPath: "opacity")
        a.fromValue = 1
        a.toValue = 0.5
        a.duration = 0.66
        a.repeatCount = .infinity
        a.autoreverses = true
        return a
    }
    
    /// Sets the state of the `TypingIndicator` to animating and applies animation layers
    open func startAnimating() {
        defer { isAnimating = true }
        guard !isAnimating else { return }
        
        var delay: TimeInterval = 0
        for dot in typingIndicator.subviews {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let strongSelf = self else { return }
                dot.layer.add(strongSelf.opacityAnimationLayer, forKey: "opacity")
            }
            delay += 0.33
        }
    }
    
    /// Sets the state of the `TypingIndicator` to not animating and removes animation layers
    open func stopAnimating() {
        defer { isAnimating = false }
        guard isAnimating else { return }
        
        typingIndicator.subviews.forEach {
            $0.layer.removeAnimation(forKey: "opacity")
        }
    }
}
