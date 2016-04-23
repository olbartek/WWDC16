//
//  AnimatedBubble.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 20.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

enum AnimatedBubbleType : Int {
    case Blue, Marine, Azure, SkyBlue, Pink
}

class AnimatedBubble: UIView {
    
    // MARK: Properties
    
    private struct BubbleModel {
        static let MinRadius: CGFloat = 3.0
        static let MaxRadius: CGFloat = 10.0
        static let Scale: CGFloat = 1.3
    }

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
        initialRadius               = CGFloat.random(BubbleModel.MinRadius, BubbleModel.MaxRadius)
        let frame = CGRect(x: 0, y: 0, width: initialRadius * 2, height: initialRadius * 2)
        super.init(frame: frame)
        self.animationPath          = generateBubbleBezierPath()
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
                self.transform = CGAffineTransformMakeScale(BubbleModel.Scale, BubbleModel.Scale)
                }, completion: { (finished) in
                    self.referenceView = nil
                    self.removeFromSuperview()
            })
        }
        
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.duration = duration
        pathAnimation.path  = animationPath.CGPath
        pathAnimation.fillMode = kCAFillModeBackwards
        
        layer.addAnimation(pathAnimation, forKey: "movingAnimation")
        CATransaction.commit()
    }
    
    // MARK: Appearance
    
    private func setColorAccordingToType() {
        switch type {
        case .Blue:
            backgroundColor = .themeBlueColor()
        case .Marine:
            backgroundColor = .themeMarineColor()
        case .Azure:
            backgroundColor = .themeAzureColor()
        case .SkyBlue:
            backgroundColor = .themeSkyBlueColor()
        case .Pink:
            backgroundColor = .themePinkColor()
        }
    }
    
    private func generatePathAccordingToTypeAndStartAngle() -> UIBezierPath {
        let pathRadius: CGFloat
        switch type {
        case .Blue:
            pathRadius = 106.0
        case .Marine:
            pathRadius = 86.0
        case .Azure:
            pathRadius = 64.0
        case .SkyBlue:
            pathRadius = 46.0
        case .Pink:
            pathRadius = 24.0
        }
        let path = UIBezierPath()
        let center = CGPoint(x: referenceView!.bounds.size.width / 2, y: referenceView!.bounds.size.height / 2)
        path.addArcWithCenter(center, radius: pathRadius, startAngle: startAngle, endAngle: 0.0, clockwise: true)
        return path
    }
    
    private func generateBubbleBezierPath() -> UIBezierPath {
        let pathRadius: CGFloat
        switch type {
        case .Blue:
            pathRadius = 106.0
        case .Marine:
            pathRadius = 86.0
        case .Azure:
            pathRadius = 64.0
        case .SkyBlue:
            pathRadius = 46.0
        case .Pink:
            pathRadius = 24.0
        }
        let bubblePath = UIBezierPath()
        let center = CGPoint(x: referenceView!.bounds.size.width / 2, y: referenceView!.bounds.size.height / 2)
        
        let oX          = center.x + pathRadius
        let oY          = center.y
        let startPoint  = CGPoint(x: oX, y: oY)
        self.center     = startPoint
        let eX          = oX
        let eY          = oY + CGFloat.random(50.0, 300.0)
        let t: CGFloat  = CGFloat.random(20.0, 100.0)
        let cp1         = CGPoint(x: oX - t, y: (oY + eY) / 2)
        let cp2         = CGPoint(x: oX + t, y: cp1.y)
        
        bubblePath.moveToPoint(startPoint)
        bubblePath.addCurveToPoint(CGPoint(x: eX, y: eY), controlPoint1: cp1, controlPoint2: cp2)
        let bounds = CGPathGetBoundingBox(bubblePath.CGPath)
        let pathCenter = CGPoint(x:CGRectGetMidX(bounds), y:CGRectGetMidY(bounds))
        let toOrigin = CGAffineTransformMakeTranslation(-pathCenter.x, -pathCenter.y)
        //bubblePath.applyTransform(toOrigin)
        let rotationTransform = CGAffineTransformRotate(CGAffineTransformIdentity, 2*CGFloat(M_PI) - startAngle)
        bubblePath.applyTransform(rotationTransform)
        return bubblePath
    }
    
}
