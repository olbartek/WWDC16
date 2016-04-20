//
//  MainViewAnimator.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 20.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

class MainViewAnimator: NSObject {
    
    // MARK: Properties
    
    var referenceView   : UIView
    var barView         : UIView!
    var bubbleColors    : [UIColor] = [.themeOrangeColor(), .themePurpleColor(), .themePlumColor(), .themeBlueColor(), .themeRedColor()]
    
    var bubbleAnimation : CAAnimationGroup?
    var bubbleTimer     : NSTimer?
    var timerTicks      = 0
    
    // MARK: Initialization
    
    init(referenceView: UIView) {
        self.referenceView = referenceView
        super.init()
        setupAnimation()
    }
    
    // MARK: Animation Setup
    
    func setupAnimation() {
        let barSize                 = CGSize(width: 250, height: 10)
        barView                     = UIView(frame: CGRectZero)
        barView.backgroundColor     = .lightGrayColor()
        barView.layer.cornerRadius  = 5
        barView.layer.masksToBounds = true
        referenceView.addSubview(barView)
        
        barView.translatesAutoresizingMaskIntoConstraints = false
        barView
            .constrain(.CenterY, .Equal, barView.superview!, .CenterY)?
            .constrain(.CenterX, .Equal, barView.superview!, .CenterX)?
            .constrain(.Width, .Equal, constant: barSize.width)?
            .constrain(.Height, .Equal, constant: barSize.height)

        
        
        
    }
    
    // MARK: Bubble timer
    
    func createBubbleTimer() {
        timerTicks      = 0
        bubbleTimer     = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(createBubbles(_:)), userInfo: nil, repeats: true)
    }
    
    func invalidateBubbleTimer() {
        if let bubbleTimer = bubbleTimer {
            bubbleTimer.invalidate()
        }
        self.bubbleTimer = nil
    }
    
    func createBubbles(timer: NSTimer) {
        timerTicks += 1
        if let presentationLayer = barView.layer.presentationLayer() as? CALayer {
            let angle = atan2f(Float(presentationLayer.affineTransform().b), Float(presentationLayer.affineTransform().a))
            let wholeRangeAngle = angle == 0 ? Float(M_PI) : (angle > 0 ? angle : 2 * Float(M_PI) + angle)
            let degrees = wholeRangeAngle * 180.0 / Float(M_PI)
            print("\(degrees)")
            for i in 0..<5 {
                if let bubbleType = AnimatedBubbleType(rawValue: i) {
                    let newBubble = createBubbleWithType(bubbleType, startAngle: CGFloat(wholeRangeAngle), duration: 2 * Animation.Bubbles.RotateOneHalfDuration + Animation.Bubbles.DelayBetweenRotations - Double(timerTicks) * 0.1)
                    newBubble.startBubbleAnimation()
                }
            }
        }
        
    }
    
    // MARK: Animations
    
    func startAnimation() {
        let rotateFirstHalf         = CABasicAnimation(keyPath: "transform.rotation")
        rotateFirstHalf.fromValue   = 0.0
        rotateFirstHalf.toValue     = CGFloat(-M_PI)
        rotateFirstHalf.duration    = Animation.Bubbles.RotateOneHalfDuration
        
        
        let rotateSecondHalf        = CABasicAnimation(keyPath: "transform.rotation")
        rotateSecondHalf.fromValue  = -M_PI
        rotateSecondHalf.toValue    = CGFloat(-M_PI * 2.0)
        rotateSecondHalf.duration   = Animation.Bubbles.RotateOneHalfDuration
        rotateSecondHalf.beginTime  = rotateFirstHalf.beginTime + rotateFirstHalf.duration + Animation.Bubbles.DelayBetweenRotations
        
        bubbleAnimation             = CAAnimationGroup()
        guard let bubbleAnimation   = bubbleAnimation else { return }
        bubbleAnimation.animations  = [rotateFirstHalf, rotateSecondHalf]
        bubbleAnimation.duration    = rotateFirstHalf.duration + rotateSecondHalf.duration + Animation.Bubbles.DelayBetweenRotations
        bubbleAnimation.repeatCount = 1
        bubbleAnimation.delegate    = self
        
        barView.layer.addAnimation(bubbleAnimation, forKey: "barRotation")
        
        
        createBubbleTimer()
        
    }
    
    
    func createBubbleWithType(type: AnimatedBubbleType, startAngle: CGFloat, duration: CFTimeInterval) -> AnimatedBubble {
        let bubbleView = AnimatedBubble(type: type, referenceView: referenceView, startAngle: startAngle, duration: duration)
        referenceView.addSubview(bubbleView)
        return bubbleView
    }
    
    
    // MARK: Animation delegate
    
    override func animationDidStart(anim: CAAnimation) {
        if let bubbleAnim = bubbleAnimation where bubbleAnim == anim {
            
        }
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        invalidateBubbleTimer()
    }

}
