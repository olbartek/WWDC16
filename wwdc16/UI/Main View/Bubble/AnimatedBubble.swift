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
        static let MinRadius: CGFloat = 6.0
        static let MaxRadius: CGFloat = 15.0
        static let Scale: CGFloat = 1.3
        static let BorderWidth: CGFloat = 3.0
        static let PopAnimationDuration: NSTimeInterval = 0.1
    }

    private(set) var type           : AnimatedBubbleType
    private(set) var animationPath  : UIBezierPath!
    private var referenceView       : UIView?
    private var initialRadius       : CGFloat
    
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
            UIView.transitionWithView(self, duration: BubbleModel.PopAnimationDuration, options: .TransitionCrossDissolve, animations: {
                self.transform = CGAffineTransformMakeScale(BubbleModel.Scale, BubbleModel.Scale)
                }, completion: { (finished) in
                    self.referenceView = nil
                    self.removeFromSuperview()
            })
        }
        
        layer.position = endPathPoint
        
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.duration = duration
        pathAnimation.path  = animationPath.CGPath
        pathAnimation.fillMode = kCAFillModeBackwards
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        layer.addAnimation(pathAnimation, forKey: "movingAnimation")
        CATransaction.commit()
    }
    
    // MARK: Appearance
    
    private func setBorderColorAccordingToType() {
        switch type {
        case .Blue:
            layer.borderColor = UIColor.themeBlueColor().CGColor
        case .Marine:
            layer.borderColor = UIColor.themeMarineColor().CGColor
        case .Azure:
            layer.borderColor = UIColor.themeAzureColor().CGColor
        case .SkyBlue:
            layer.borderColor = UIColor.themeSkyBlueColor().CGColor
        case .Pink:
            layer.borderColor = UIColor.themePinkColor().CGColor
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
    
    private func signumXBasedOnPoint(p: CGPoint) -> CGFloat {
        if p.y > 0 {
            return 1.0
        } else {
            return -1.0
        }
    }
    
    private func generateBoundPoints() -> (startPoint: CGPoint, endPoint: CGPoint) {
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
        let refViewCenter = CGPoint(x: CGRectGetMidX(referenceView!.bounds), y: CGRectGetMidY(referenceView!.bounds))
        
        var rotationTransform = CGAffineTransformMakeTranslation(refViewCenter.x, refViewCenter.y)
        rotationTransform = CGAffineTransformRotate(rotationTransform, startAngle)
        rotationTransform = CGAffineTransformTranslate(rotationTransform,-refViewCenter.x, -refViewCenter.y)

        let startPoint  = CGPoint(x: refViewCenter.x + pathRadius, y: refViewCenter.y)
        let transformedStartPoint = CGPointApplyAffineTransform(startPoint, rotationTransform)
        self.center     = transformedStartPoint
        
        let signX       = signumXBasedOnPoint(CGPoint(x: transformedStartPoint.x - refViewCenter.x, y: transformedStartPoint.y - refViewCenter.y))
        let eX          = transformedStartPoint.x + signX * CGFloat.random(50.0, 150.0)
        let perpFunc    = perpendicularLinearFuncCrossingPoint(transformedStartPoint, andPointOnPerpendicularLine: refViewCenter)
        let eY          = perpFunc(x_in: eX)
        let transformedEndPoint    = CGPoint(x: eX, y: eY)
        return (transformedStartPoint, transformedEndPoint)
    }
    
    private func perpendicularLinearFuncCrossingPoint(crossingPoint: CGPoint, andPointOnPerpendicularLine pointOnPerpendicularLine: CGPoint) -> (x_in: CGFloat) -> CGFloat {
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
    
    private func generateBubbleBezierPath() -> UIBezierPath {
        
        let bubblePath  = UIBezierPath()
        let t: CGFloat  = CGFloat.random(50.0, (endPathPoint.x - startPathPoint.x) )
        let cp1         = CGPoint(x: startPathPoint.x - t, y: (startPathPoint.y + endPathPoint.y) / 2)
        let cp2         = CGPoint(x: startPathPoint.x + t, y: cp1.y)
        
        bubblePath.moveToPoint(startPathPoint)
        bubblePath.addCurveToPoint(endPathPoint, controlPoint1: cp1, controlPoint2: cp2)

        return bubblePath
    }
    
}
