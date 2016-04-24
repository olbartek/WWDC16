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
        static let ImageSide: CGFloat = 75.0
        static let MovementAnimationDuration: CFTimeInterval = 0.3
        static func MovementAnimationKeyAtIndex(index: Int) -> String { return "movementAnimation\(index)" }
        static let SinglePulseAnimationDuration: CFTimeInterval = 0.5
        static let SigleRotationAnimationDuration: CFTimeInterval = 8
        static let LabelAlphaAnimationDuration: CFTimeInterval = 0.5
        static let ImageOffsetFromViewCenter: CGFloat = 100.0
    }
    var currentEndPosition = CGPointZero
    var currentContactImage: ContactImage?
    var animationIndex = 0
    
    @IBOutlet var contactImages: [ContactImage]!
    @IBOutlet weak var contactMeImage: UIImageView!
    
    // MARK: VC's Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .themePinkColor()
        prepareContactImages()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideContactImages(true)
        contactMeImage.layer.opacity = 0.0
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        removeAllAnimations()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        contactImagesMovementAnimation()
    }
    
    // MARK: Preparation
    
    func prepareContactImages() {
        for i in 0..<contactImages.count {
            let contactImage = contactImages[i]
            contactImage.type = ContactImageType(rawValue: i)
            contactImage.userInteractionEnabled = true
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnView(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Appearance
    
    func hideContactImages(hide: Bool) {
        let alphaToSet: CGFloat = hide ? 0.0 : 1.0
        contactImages.forEach { (button) in
            button.alpha = alphaToSet
        }
    }
    
    // MARK: Animations
    
    func contactImagesMovementAnimation() {
        
        let startPosition = view.center
        let initialEndPosition = CGPoint(x: view.center.x, y: view.center.y + Constants.ImageOffsetFromViewCenter)
        let initialAngle = 2 * CGFloat(M_PI) / CGFloat(contactImages.count)
        currentEndPosition = CGPointZero
        
        
        for (index, contactImage) in contactImages.enumerate() {
            let angle = initialAngle * CGFloat(index)
            contactImage.startAngle = angle
            
            var rotationTransform = CGAffineTransformMakeTranslation(startPosition.x, startPosition.y)
            rotationTransform = CGAffineTransformRotate(rotationTransform, angle)
            rotationTransform = CGAffineTransformTranslate(rotationTransform,-startPosition.x, -startPosition.y)
            let endPosition = CGPointApplyAffineTransform(initialEndPosition, rotationTransform)
            
            currentEndPosition = endPosition
            currentContactImage = contactImage
            
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
            if index == contactImages.count - 1 {
                groupAnimation.delegate = self
            }
            
            contactImage.layer.position = endPosition
            contactImage.layer.opacity = 1.0
            contactImage.layer.addAnimation(groupAnimation, forKey: Constants.MovementAnimationKeyAtIndex(index))
            
        }
    }
    
    func contactImagesRotationAnimation() {
        
        for contactImage in contactImages {
            let animationPath = UIBezierPath()
            animationPath.moveToPoint(contactImage.layer.position)
            let startAngle = CGFloat(M_PI_2) + contactImage.startAngle
            animationPath.addArcWithCenter(view.center, radius: Constants.ImageOffsetFromViewCenter, startAngle: startAngle, endAngle: 2 * CGFloat(M_PI) + startAngle, clockwise: true)
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
            
            contactImage.layer.addAnimation(pathAnimation, forKey: "movingAnimation")
        }
        
    }
    
    func contactMeImagePulseAnimation() {
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
        
        contactMeImage.layer.opacity = 1.0
        
        contactMeImage.layer.addAnimation(alphaAnimation, forKey: "alphaAnimation")
        contactMeImage.layer.addAnimation(pulseAnimation, forKey: "pulseAnimation")
    }
    
    func removeAllAnimations() {
        contactMeImage.layer.removeAllAnimations()
        contactImages.forEach { (image) in
            image.layer.removeAllAnimations()
        }
    }
    
    // MARK: Animation delegate
    
    override func animationDidStart(anim: CAAnimation) {
        print("Movement Animation start")
        
    }

    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        contactMeImagePulseAnimation()
        contactImagesRotationAnimation()
        print("Movement Animation stopped")
    }
    
    // MARK: Actions
    
    @IBAction func didPressCloseButton() {
        dismissViewControllerWithoutAnimation()
    }
    
    func didTapOnView(gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.locationInView(view)
        for contactImage in contactImages {
            if let presentationLayer = contactImage.layer.presentationLayer() as? CALayer, let _ = presentationLayer.hitTest(touchPoint), contactImageType = contactImage.type {
                didPressContactImageWithType(contactImageType)
            }
        }
    }
    
    func didPressContactImageWithType(type: ContactImageType) {
        switch type {
        case .Facebook:
            print("Facebook button")
        case .Linkedin:
            print("Linkedin button")
        case .Twitter:
            print("Twitter button")
        }
    }

}
