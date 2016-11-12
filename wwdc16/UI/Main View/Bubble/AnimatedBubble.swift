//
//  AnimatedBubble.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 20.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

enum AnimatedBubbleType : Int {
    case blue, marine, azure, skyBlue, pink
}

class AnimatedBubble: UIView {
    
    // MARK: Properties
    
    fileprivate struct BubbleModel {
        static let MinRadius: CGFloat = 6.0
        static let MaxRadius: CGFloat = 15.0
        static let Scale: CGFloat = 1.3
        static let BorderWidth: CGFloat = 3.0
        static let PopAnimationDuration: TimeInterval = 0.1
    }

    fileprivate(set) var type           : AnimatedBubbleType
    fileprivate(set) var animationPath  : UIBezierPath!
    fileprivate var referenceView       : UIView?
    fileprivate var initialRadius       : CGFloat
    
    var duration                    : CFTimeInterval
    var startAngle                  : CGFloat
    var startPathPoint              : CGPoint!
    var endPathPoint                : CGPoint!
    
    // MARK: Initialization
    
    init(type: AnimatedBubbleType, referenceView: UIView, startAngle: CGFloat, duration: CFTimeInterval) {
        self.type                   = type
        self.referenceView          = referenceView
        self.duration               = duration
        self.startAngle             = startAngle
        initialRadius               = CGFloat.random(BubbleModel.MinRadius, BubbleModel.MaxRadius)
        let frame = CGRect(x: 0, y: 0, width: initialRadius * 2, height: initialRadius * 2)
        super.init(frame: frame)
        let (startPt, endPt)        = generateBoundPoints()
        self.startPathPoint         = startPt
        self.endPathPoint           = endPt
        self.animationPath          = generateBubbleBezierPath()
        self.layer.cornerRadius     = initialRadius
        self.layer.borderWidth      = BubbleModel.BorderWidth
        self.layer.masksToBounds    = true
        
        setBorderColorAccordingToType()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Animation
    func startBubbleAnimation() {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            UIView.transition(with: self, duration: BubbleModel.PopAnimationDuration, options: .transitionCrossDissolve, animations: {
                self.transform = CGAffineTransform(scaleX: BubbleModel.Scale, y: BubbleModel.Scale)
                }, completion: { (finished) in
                    self.referenceView = nil
                    self.removeFromSuperview()
            })
        }
        
        layer.position = endPathPoint
        
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.duration = duration
        pathAnimation.path  = animationPath.cgPath
        pathAnimation.fillMode = kCAFillModeBackwards
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        layer.add(pathAnimation, forKey: "movingAnimation")
        CATransaction.commit()
    }
    
    // MARK: Appearance
    
    fileprivate func setBorderColorAccordingToType() {
        switch type {
        case .blue:
            layer.borderColor = UIColor.themeBlueColor().cgColor
        case .marine:
            layer.borderColor = UIColor.themeMarineColor().cgColor
        case .azure:
            layer.borderColor = UIColor.themeAzureColor().cgColor
        case .skyBlue:
            layer.borderColor = UIColor.themeSkyBlueColor().cgColor
        case .pink:
            layer.borderColor = UIColor.themePinkColor().cgColor
        }
    }
    
    fileprivate func generatePathAccordingToTypeAndStartAngle() -> UIBezierPath {
        let pathRadius: CGFloat
        switch type {
        case .blue:
            pathRadius = 106.0
        case .marine:
            pathRadius = 86.0
        case .azure:
            pathRadius = 64.0
        case .skyBlue:
            pathRadius = 46.0
        case .pink:
            pathRadius = 24.0
        }
        let path = UIBezierPath()
        let center = CGPoint(x: referenceView!.bounds.size.width / 2, y: referenceView!.bounds.size.height / 2)
        path.addArc(withCenter: center, radius: pathRadius, startAngle: startAngle, endAngle: 0.0, clockwise: true)
        return path
    }
    
    fileprivate func signumXBasedOnPoint(_ p: CGPoint) -> CGFloat {
        if p.y > 0 {
            return 1.0
        } else {
            return -1.0
        }
    }
    
    fileprivate func generateBoundPoints() -> (startPoint: CGPoint, endPoint: CGPoint) {
        let pathRadius: CGFloat
        switch type {
        case .blue:
            pathRadius = 106.0
        case .marine:
            pathRadius = 86.0
        case .azure:
            pathRadius = 64.0
        case .skyBlue:
            pathRadius = 46.0
        case .pink:
            pathRadius = 24.0
        }
        let refViewCenter = CGPoint(x: referenceView!.bounds.midX, y: referenceView!.bounds.midY)
        
        var rotationTransform = CGAffineTransform(translationX: refViewCenter.x, y: refViewCenter.y)
        rotationTransform = rotationTransform.rotated(by: startAngle)
        rotationTransform = rotationTransform.translatedBy(x: -refViewCenter.x, y: -refViewCenter.y)

        let startPoint  = CGPoint(x: refViewCenter.x + pathRadius, y: refViewCenter.y)
        let transformedStartPoint = startPoint.applying(rotationTransform)
        self.center     = transformedStartPoint
        
        let signX       = signumXBasedOnPoint(CGPoint(x: transformedStartPoint.x - refViewCenter.x, y: transformedStartPoint.y - refViewCenter.y))
        let eX          = transformedStartPoint.x + signX * CGFloat.random(50.0, 150.0)
        let perpFunc    = perpendicularLinearFuncCrossingPoint(transformedStartPoint, andPointOnPerpendicularLine: refViewCenter)
        let eY          = perpFunc(eX)
        let transformedEndPoint    = CGPoint(x: eX, y: eY)
        return (transformedStartPoint, transformedEndPoint)
    }
    
    fileprivate func perpendicularLinearFuncCrossingPoint(_ crossingPoint: CGPoint, andPointOnPerpendicularLine pointOnPerpendicularLine: CGPoint) -> (_ x_in: CGFloat) -> CGFloat {
        let x = pointOnPerpendicularLine.x
        let y = pointOnPerpendicularLine.y
        let crossX = crossingPoint.x
        let crossY = crossingPoint.y
        
        let a = (crossY - y) / (crossX - x)
        let a_perp = a != 0 ? -1 / a : 0.0
        let b_perp = crossY - a_perp * crossX
        
        let perpFunc = { (x_in: CGFloat) in
            return a_perp * x_in + b_perp
        }
        return perpFunc
    }
    
    fileprivate func generateBubbleBezierPath() -> UIBezierPath {
        
        let bubblePath  = UIBezierPath()
        let t: CGFloat  = CGFloat.random(50.0, (endPathPoint.x - startPathPoint.x) )
        let cp1         = CGPoint(x: startPathPoint.x - t, y: (startPathPoint.y + endPathPoint.y) / 2)
        let cp2         = CGPoint(x: startPathPoint.x + t, y: cp1.y)
        
        bubblePath.move(to: startPathPoint)
        bubblePath.addCurve(to: endPathPoint, controlPoint1: cp1, controlPoint2: cp2)

        return bubblePath
    }
    
}
