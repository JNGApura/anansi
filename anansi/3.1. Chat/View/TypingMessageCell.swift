//
//  TypingMessageCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 01/06/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class TypingMessageCell: UICollectionViewCell {

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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
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

        [bubble, typingIndicator].forEach { addSubview($0) } //tinyBubble, cornerBubble,
        
        // Add layout constraints to subviews
        NSLayoutConstraint.activate([

            bubble.topAnchor.constraint(equalTo: topAnchor, constant: 3.0),
            bubble.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginEight * 2.75),
            bubble.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3.0),
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
