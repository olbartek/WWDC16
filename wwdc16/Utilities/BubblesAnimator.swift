//
//  MainViewAnimator.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 20.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

protocol BubblesAnimatorDelegate {
    func bubbleAnimationDidStart()
    func bubbleAnimationDidStop()
}

class BubblesAnimator: NSObject {
    
    private struct Constants {
        static let BubbleCreationInterval: NSTimeInterval = 0.2
        static let BarWidth: CGFloat = 270.0
        static let BarHeight: CGFloat = 10.0
        static let BarCornerRadius: CGFloat = 10.0
    }
    
    // MARK: Properties
    
    var referenceView   : UIView
    var barView         : UIView!
    var bubbleColors    : [UIColor] = [.themeBlueColor(), .themeMarineColor(), .themeAzureColor(), .themeSkyBlueColor(), .themePinkColor()]
    
    var barAnimation    : CAAnimationGroup?
    var bubbleTimer     : NSTimer?
    var timerTicks      = 0
    var delegate        : BubblesAnimatorDelegate?
    
    // MARK: Initialization
    
    init(referenceView: UIView) {
        self.referenceView = referenceView
        super.init()
        setupAnimation()
    }
    
    // MARK: Animation Setup
    
    func setupAnimation() {
        let barSize                 = CGSize(width: Constants.BarWidth, height: Constants.BarHeight)
        barView                     = UIView(frame: CGRectZero)
        barView.backgroundColor     = .lightGrayColor()
        barView.layer.cornerRadius  = Constants.BarCornerRadius
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
        bubbleTimer     = NSTimer.scheduledTimerWithTimeInterval(Constants.BubbleCreationInterval, target: self, selector: #selector(createBubbles(_:)), userInfo: nil, repeats: true)
        bubbleTimer?.fire()
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
            let wholeRangeAngle = (angle <= 0 ? angle + 2 * Float(M_PI): angle)
            let degrees = wholeRangeAngle * 180.0 / Float(M_PI)
            print("\(degrees)")
            for i in 0..<5 {
                if let bubbleType = AnimatedBubbleType(rawValue: i) {
                    let newBubble = createBubbleWithType(bubbleType, startAngle: CGFloat(wholeRangeAngle), maxDuration: 2 * Animation.Bubbles.RotateOneHalfDuration + Animation.Bubbles.DelayBetweenRotations - Double(timerTicks) * 0.1)
                    let newBubbleOpposite = createBubbleWithType(bubbleType, startAngle: CGFloat(wholeRangeAngle) - CGFloat(M_PI), maxDuration: 2 * Animation.Bubbles.RotateOneHalfDuration + Animation.Bubbles.DelayBetweenRotations )//- Double(timerTicks) * 0.1)
                    newBubble.startBubbleAnimation()
                    newBubbleOpposite.startBubbleAnimation()
                }
            }
        }
    }
    
    func createBubbleWithType(type: AnimatedBubbleType, startAngle: CGFloat, maxDuration: CFTimeInterval) -> AnimatedBubble {
        let bubbleView = AnimatedBubble(type: type, referenceView: referenceView, startAngle: startAngle, duration: maxDuration)
        referenceView.addSubview(bubbleView)
        return bubbleView
    }
    
    // MARK: Animations
    
    func startAnimation() {
        delegate?.bubbleAnimationDidStart()
        let rotateFirstHalf         = CABasicAnimation(keyPath: "transform.rotation")
        rotateFirstHalf.fromValue   = 0.0
        rotateFirstHalf.toValue     = CGFloat(-M_PI)
        rotateFirstHalf.duration    = Animation.Bubbles.RotateOneHalfDuration
        
        
        let rotateSecondHalf        = CABasicAnimation(keyPath: "transform.rotation")
        rotateSecondHalf.fromValue  = -M_PI
        rotateSecondHalf.toValue    = CGFloat(-M_PI * 2.0)
        rotateSecondHalf.duration   = Animation.Bubbles.RotateOneHalfDuration
        rotateSecondHalf.beginTime  = rotateFirstHalf.beginTime + rotateFirstHalf.duration + Animation.Bubbles.DelayBetweenRotations
        
        barAnimation                = CAAnimationGroup()
        guard let barAnimation      = barAnimation else { return }
        barAnimation.animations     = [rotateFirstHalf, rotateSecondHalf]
        barAnimation.duration       = rotateFirstHalf.duration + rotateSecondHalf.duration + Animation.Bubbles.DelayBetweenRotations + Animation.Bubbles.DelayAfterRotations
        barAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        barAnimation.delegate       = self
        
        barView.layer.addAnimation(barAnimation, forKey: "barRotation")
        
        createBubbleTimer()
    }
    
    
    // MARK: Animation delegate
    
    override func animationDidStart(anim: CAAnimation) {

    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        invalidateBubbleTimer()
        delegate?.bubbleAnimationDidStop()
    }

}
