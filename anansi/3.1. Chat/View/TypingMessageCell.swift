//
//  TypingMessageCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 01/06/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class TypingMessageCell: UITableViewCell {

    // MARK: Custom initializers
    
    public private(set) var isAnimating: Bool = false
    
    var indexPath: IndexPath!
    
    let bubble: UIView = {
        let bv = UIView()
        bv.layer.borderWidth = 2
        bv.layer.borderColor = UIColor.init(red: 245/255.0, green: 245/255.0, blue: 248/255.0, alpha: 1.0).cgColor //UIColor.tertiary.withAlphaComponent(0.5).cgColor
        bv.layer.cornerRadius = 20
        bv.layer.masksToBounds = true
        bv.clipsToBounds = true
        bv.backgroundColor = UIColor.init(red: 245/255.0, green: 245/255.0, blue: 248/255.0, alpha: 1.0)
        bv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bv.translatesAutoresizingMaskIntoConstraints = false
        return bv
    }()
    
    let cornerBubble: UIView = {
        let bv = UIView()
        bv.backgroundColor = UIColor.init(red: 245/255.0, green: 245/255.0, blue: 248/255.0, alpha: 1.0)
        bv.layer.cornerRadius = 7.0
        bv.clipsToBounds = true
        bv.translatesAutoresizingMaskIntoConstraints = false
        return bv
    }()
    
    let tinyBubble: UIView = {
        let bv = UIView()
        bv.backgroundColor = UIColor.init(red: 245/255.0, green: 245/255.0, blue: 248/255.0, alpha: 1.0)
        bv.layer.cornerRadius = 4.0
        bv.clipsToBounds = true
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
    
    // MARK: Cell init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        // Add subviews
        for dot in dots {
            
            dot.layer.cornerRadius = 4.0
            dot.clipsToBounds = true
            dot.backgroundColor = .lightGray
            dot.translatesAutoresizingMaskIntoConstraints = false
    
            dot.widthAnchor.constraint(equalTo: dot.heightAnchor).isActive = true
            dot.widthAnchor.constraint(equalToConstant: 8.0).isActive = true
            
            typingIndicator.addArrangedSubview(dot)
            typingIndicator.setCustomSpacing(4.0, after: dot)
        }

        [tinyBubble, cornerBubble, bubble, typingIndicator].forEach { addSubview($0) }
        
        // Add layout constraints to subviews
        NSLayoutConstraint.activate([
            
            tinyBubble.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.0),
            tinyBubble.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight + 5.0),
            tinyBubble.heightAnchor.constraint(equalTo: tinyBubble.widthAnchor),
            tinyBubble.widthAnchor.constraint(equalToConstant: 8.0),
            
            cornerBubble.leadingAnchor.constraint(equalTo: tinyBubble.trailingAnchor, constant: -Const.marginEight / 4.0),
            cornerBubble.bottomAnchor.constraint(equalTo: tinyBubble.topAnchor, constant: Const.marginEight / 4.0),
            cornerBubble.heightAnchor.constraint(equalTo: cornerBubble.widthAnchor),
            cornerBubble.widthAnchor.constraint(equalToConstant: 14.0),

            bubble.topAnchor.constraint(equalTo: topAnchor, constant: 3.0),
            bubble.leadingAnchor.constraint(equalTo: cornerBubble.centerXAnchor, constant: -Const.marginEight / 2.0),
            bubble.bottomAnchor.constraint(equalTo: cornerBubble.centerYAnchor, constant: 6.0),
            bubble.widthAnchor.constraint(equalToConstant: 64.0),
            bubble.heightAnchor.constraint(equalToConstant: 40.0),
            
            typingIndicator.centerXAnchor.constraint(equalTo: bubble.centerXAnchor),
            typingIndicator.centerYAnchor.constraint(equalTo: bubble.centerYAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Custom functions
    
    func config() {
        
        if !isAnimating {
            startAnimating()
            
        } else {
            stopAnimating()
            startAnimating()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        config()
    }
    
    // MARK: - Animation API
    
    /// The `CABasicAnimation` applied when `isFadeEnabled` is TRUE
    open var opacityAnimationLayer: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0.5
        animation.duration = 0.66
        animation.repeatCount = .infinity
        animation.autoreverses = true
        return animation
    }
    
    /// Sets the state of the `TypingIndicator` to animating and applies animation layers
    open func startAnimating() {
        defer { isAnimating = true }
        guard !isAnimating else { return }
        var delay: TimeInterval = 0
        for dot in typingIndicator.subviews {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let `self` = self else { return }
                dot.layer.add(self.opacityAnimationLayer, forKey: "opacity")
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
