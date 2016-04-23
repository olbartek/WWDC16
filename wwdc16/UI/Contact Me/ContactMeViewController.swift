//
//  ContactMeViewController.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 21.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

class ContactMeViewController: PresentedViewController {
    
    // MARK: Properties
    
    private struct Constants {
        static let ButtonSide: CGFloat = 50.0
        static let MovementAnimationDuration: CFTimeInterval = 0.3
        static func MovementAnimationKeyAtIndex(index: Int) -> String { return "movementAnimation\(index)" }
        static let SinglePulseAnimationDuration: CFTimeInterval = 0.5
        static let SigleRotationAnimationDuration: CFTimeInterval = 8
        static let LabelAlphaAnimationDuration: CFTimeInterval = 0.5
        static let ButtonOffsetFromViewCenter: CGFloat = 100.0
    }
    var currentEndPosition = CGPointZero
    var currentContactButton: ContactButton?
    var animationIndex = 0
    
    @IBOutlet var contactButtons: [ContactButton]!
    @IBOutlet weak var contactMeLabel: UILabel!
    
    // MARK: VC's Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .themeRedColor()
        prepareContactButtons()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideContactButtons(true)
        contactMeLabel.layer.opacity = 0.0
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        removeAllAnimations()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        buttonMovementAnimation()
    }
    
    // MARK: Preparation
    
    func prepareContactButtons() {
        for i in 0..<contactButtons.count {
            let contactButton = contactButtons[i]
            contactButton.type = ContactButtonType(rawValue: i)
            contactButton.addTarget(self, action: #selector(didPressContactButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    // MARK: Appearance
    
    func hideContactButtons(hide: Bool) {
        let alphaToSet: CGFloat = hide ? 0.0 : 1.0
        contactButtons.forEach { (button) in
            button.alpha = alphaToSet
        }
    }
    
    // MARK: Animations
    
    func buttonMovementAnimation() {
        
        let startPosition = view.center
        let initialEndPosition = CGPoint(x: view.center.x, y: view.center.y + Constants.ButtonOffsetFromViewCenter)
        let initialAngle = 2 * CGFloat(M_PI) / CGFloat(contactButtons.count)
        currentEndPosition = CGPointZero
        
        
        for (index, contactButton) in contactButtons.enumerate() {
            let angle = initialAngle * CGFloat(index)
            contactButton.startAngle = angle
            
            var rotationTransform = CGAffineTransformMakeTranslation(startPosition.x, startPosition.y)
            rotationTransform = CGAffineTransformRotate(rotationTransform, angle)
            rotationTransform = CGAffineTransformTranslate(rotationTransform,-startPosition.x, -startPosition.y)
            let endPosition = CGPointApplyAffineTransform(initialEndPosition, rotationTransform)
            
            currentEndPosition = endPosition
            currentContactButton = contactButton
            
            let alphaAnimation = CABasicAnimation(keyPath: "opacity")
            alphaAnimation.fromValue = 0.0
            alphaAnimation.toValue = 1.0
            
            let movementAnimation = CABasicAnimation(keyPath: "position")
            movementAnimation.fromValue = NSValue(CGPoint: startPosition)
            movementAnimation.toValue = NSValue(CGPoint: endPosition)
            
            let groupAnimation = CAAnimationGroup()
            groupAnimation.animations = [alphaAnimation, movementAnimation]
            groupAnimation.beginTime = CACurrentMediaTime() + Double(index) * Constants.MovementAnimationDuration
            groupAnimation.duration = Constants.MovementAnimationDuration
            groupAnimation.removedOnCompletion = true
            groupAnimation.fillMode = kCAFillModeBackwards
            if index == contactButtons.count - 1 {
                groupAnimation.delegate = self
            }
            
            contactButton.layer.position = endPosition
            contactButton.layer.opacity = 1.0
            contactButton.layer.addAnimation(groupAnimation, forKey: Constants.MovementAnimationKeyAtIndex(index))
            
        }
    }
    
    func buttonRotationAnimation() {
        
        for contactButton in contactButtons {
            let animationPath = UIBezierPath()
            animationPath.moveToPoint(contactButton.layer.position)
            let startAngle = CGFloat(M_PI_2) + contactButton.startAngle
            animationPath.addArcWithCenter(view.center, radius: Constants.ButtonOffsetFromViewCenter, startAngle: startAngle, endAngle: 2 * CGFloat(M_PI) + startAngle, clockwise: true)
            animationPath.closePath()
            let pathAnimation = CAKeyframeAnimation(keyPath: "position")
            pathAnimation.beginTime = CACurrentMediaTime() + Constants.LabelAlphaAnimationDuration
            pathAnimation.duration = Constants.SigleRotationAnimationDuration
            pathAnimation.path  = animationPath.CGPath
            pathAnimation.repeatCount = Float.infinity
            pathAnimation.calculationMode = kCAAnimationPaced
            //pathAnimation.additive = true
            //pathAnimation.rotationMode = kCAAnimationRotateAuto
            pathAnimation.fillMode = kCAFillModeBoth
            
            contactButton.layer.addAnimation(pathAnimation, forKey: "movingAnimation")
        }
        
    }
    
    func labelPulseAnimation() {
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.duration = Constants.LabelAlphaAnimationDuration
        alphaAnimation.fromValue = 0.0
        alphaAnimation.toValue = 1.0
        alphaAnimation.fillMode = kCAFillModeBackwards
        
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = Constants.SinglePulseAnimationDuration
        pulseAnimation.beginTime = CACurrentMediaTime() + alphaAnimation.duration
        pulseAnimation.repeatCount = Float.infinity
        pulseAnimation.autoreverses = true
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 0.7
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        contactMeLabel.layer.opacity = 1.0
        
        contactMeLabel.layer.addAnimation(alphaAnimation, forKey: "alphaAnimation")
        contactMeLabel.layer.addAnimation(pulseAnimation, forKey: "pulseAnimation")
    }
    
    func removeAllAnimations() {
        contactMeLabel.layer.removeAllAnimations()
        contactButtons.forEach { (button) in
            button.layer.removeAllAnimations()
        }
    }
    
    // MARK: Animation delegate
    
    override func animationDidStart(anim: CAAnimation) {
        print("Movement Animation start")
        
    }

    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        labelPulseAnimation()
        buttonRotationAnimation()
        print("Movement Animation stopped")
    }
    
    // MARK: Actions
    
    @IBAction func didPressCloseButton() {
        dismissViewControllerWithoutAnimation()
    }
    
    func didPressContactButton(button: ContactButton) {
        guard let buttonType = button.type else { return }
        switch buttonType {
        case .Facebook:
            print("Facebook button")
        case .Linkedin:
            print("Linkedin button")
        case .Twitter:
            print("Twitter button")
        }
    }

}
