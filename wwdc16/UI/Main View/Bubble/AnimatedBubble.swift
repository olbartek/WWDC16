//
//  AnimatedBubble.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 20.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

enum AnimatedBubbleType : Int {
    case Orange, Purple, Plum, Blue, Red
}

class AnimatedBubble: UIView {
    
    // MARK: Properties

    private(set) var type           : AnimatedBubbleType
    private(set) var animationPath  : UIBezierPath!
    private var referenceView       : UIView?
    private var initialRadius       : CGFloat
    
    var duration                    : CFTimeInterval
    var startAngle                  : CGFloat
    
    // MARK: Initialization
    
    init(type: AnimatedBubbleType, referenceView: UIView, startAngle: CGFloat, duration: CFTimeInterval) {
        self.type                   = type
        self.referenceView          = referenceView
        self.duration               = duration
        self.startAngle             = startAngle
        switch type {
        case .Orange:
            initialRadius = 7.5
        case .Purple:
            initialRadius = 6.5
        case .Plum:
            initialRadius = 6.0
        case .Blue:
            initialRadius = 5.5
        case .Red:
            initialRadius = 5.0
        }
        let frame = CGRect(x: 0, y: 0, width: initialRadius * 2, height: initialRadius * 2)
        super.init(frame: frame)
        self.animationPath          = generatePathAccordingToTypeAndStartAngle()
        self.layer.cornerRadius     = initialRadius
        self.layer.masksToBounds    = true
        
        setColorAccordingToType()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Animation
    func startBubbleAnimation() {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            UIView.transitionWithView(self, duration: 0.1, options: .TransitionCrossDissolve, animations: {
                self.transform = CGAffineTransformMakeScale(1.3, 1.3)
                }, completion: { (finished) in
                    self.referenceView = nil
                    self.removeFromSuperview()
            })
        }
        
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.duration = duration
        pathAnimation.path  = animationPath.CGPath
        pathAnimation.fillMode = kCAFillModeRemoved
        
        layer.addAnimation(pathAnimation, forKey: "movingAnimation")
        CATransaction.commit()
    }
    
    // MARK: Appearance
    
    private func setColorAccordingToType() {
        switch type {
        case .Orange:
            backgroundColor = .themeOrangeColor()
        case .Purple:
            backgroundColor = .themePurpleColor()
        case .Plum:
            backgroundColor = .themePlumColor()
        case .Blue:
            backgroundColor = .themeBlueColor()
        case .Red:
            backgroundColor = .themeRedColor()
        }
    }
    
    private func generatePathAccordingToTypeAndStartAngle() -> UIBezierPath {
        let pathRadius: CGFloat
        switch type {
        case .Orange:
            pathRadius = 106.0
        case .Purple:
            pathRadius = 86.0
        case .Plum:
            pathRadius = 64.0
        case .Blue:
            pathRadius = 46.0
        case .Red:
            pathRadius = 24.0
        }
        let path = UIBezierPath()
        let center = CGPoint(x: referenceView!.bounds.size.width / 2, y: referenceView!.bounds.size.height / 2)
        path.addArcWithCenter(center, radius: pathRadius, startAngle: startAngle, endAngle: 0.0, clockwise: true)
        return path
    }
    
}
