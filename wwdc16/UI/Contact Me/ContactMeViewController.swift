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
        static let ConstactInfoLabelLeadingOffset: CGFloat = 80.0
        static let ConstactInfoLabelTrailingOffset: CGFloat = 8.0
        static let ContactInfoImageMinHeight: CGFloat = 0.0
        static let ContactInfoImageMaxHeight: CGFloat = 50.0
    }
    var currentEndPosition = CGPointZero
    var currentContactImage: ContactImage?
    var animationIndex = 0
    var contactInfoViewHidden = true
    var contactInfoViewAnimating = false
    var contactImagesRotationAnimationStarted = false
    
    @IBOutlet var contactImages: [ContactImage]!
    @IBOutlet weak var contactMeImage: UIImageView!
    @IBOutlet weak var contactInfoImage: ContactImage!
    @IBOutlet weak var contactInfoLabel: UILabel!
    
    @IBOutlet weak var contactInfoImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contactInfoLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contactInfoLabelWidthConstraint: NSLayoutConstraint!
    
    // MARK: VC's Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .themePinkColor()
        prepareContactImages()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideContactImages(true)
        contactImagesRotationAnimationStarted = false
        contactMeImage.layer.opacity = 0.0
        prepareContactInfoView()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        removeAllAnimations()
        hideContactInfoAndShowAnotherInfo(false)
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
    
    func prepareContactInfoView() {
        contactInfoLabelWidthConstraint.constant = UIScreen.mainScreen().bounds.size.width - Constants.ConstactInfoLabelLeadingOffset - Constants.ConstactInfoLabelTrailingOffset
        contactInfoImageHeightConstraint.constant = 0.0
        contactInfoLabelLeadingConstraint.constant = -1.0 * contactInfoLabelWidthConstraint.constant
        contactInfoViewHidden = true
        view.layoutIfNeeded()
        view.setNeedsUpdateConstraints()
    }
    
    // MARK: Appearance
    
    func hideContactImages(hide: Bool) {
        let alphaToSet: CGFloat = hide ? 0.0 : 1.0
        contactImages.forEach { (button) in
            button.alpha = alphaToSet
        }
    }
    
    func imageFromType(type: ContactImageType) -> UIImage {
        switch type {
        case .Facebook:
            return UIImage(named: "fb-logo")!
        case .Linkedin:
            return UIImage(named: "linkedin-logo")!
        case .Twitter:
            return UIImage(named: "twitter-logo")!
        }
    }
    
    func contactTextFromType(type: ContactImageType) -> String {
        switch type {
        case .Facebook:
            return "fb.com/bartosz.olszanowski"
        case .Linkedin:
            return "linkedin.com/in/olszanowski"
        case .Twitter:
            return "twitter.com/olbartek"
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
            contactImage.layer.removeAllAnimations()
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
            pathAnimation.fillMode = kCAFillModeBackwards
            
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
    
    func showContactInfoWithType(type: ContactImageType) {
        contactInfoViewAnimating = true
        contactInfoImage.image = imageFromType(type)
        contactInfoLabel.text = contactTextFromType(type)
        contactInfoImageHeightConstraint.constant = Constants.ContactInfoImageMaxHeight
        UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            }) { (finished) in
                self.contactInfoLabelLeadingConstraint.constant = 0
                UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: { (finished) in
                        self.contactInfoViewAnimating = false
                        self.contactInfoViewHidden = false
                })
        }
    }
    
    func hideContactInfoAndShowAnotherInfo(showAnother: Bool, withType type: ContactImageType? = nil) {
        contactInfoViewAnimating = true
        contactInfoLabelLeadingConstraint.constant = -1.0 * contactInfoLabelWidthConstraint.constant
        UIView.animateWithDuration(0.25, animations: {
            self.view.layoutIfNeeded()
            }) { (finished) in
                self.contactInfoImageHeightConstraint.constant = Constants.ContactInfoImageMinHeight
                UIView.animateWithDuration(0.25, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: { [weak self](finished) in
                        guard let weakSelf = self else { return }
                        if showAnother {
                            if let type = type {
                                weakSelf.showContactInfoWithType(type)
                            }
                        } else {
                            weakSelf.contactInfoViewAnimating = false
                            weakSelf.contactInfoViewHidden = true
                        }
                })
        }
    }
    
    // MARK: Animation delegate
    
    override func animationDidStart(anim: CAAnimation) {
    }

    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if !contactImagesRotationAnimationStarted {
            contactMeImagePulseAnimation()
            contactImagesRotationAnimation()
            contactImagesRotationAnimationStarted = true
        }
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
                return
            }
        }
    }
    
    func didPressContactImageWithType(type: ContactImageType) {
        if !contactInfoViewAnimating {
            if contactInfoViewHidden {
                showContactInfoWithType(type)
            } else {
                hideContactInfoAndShowAnotherInfo(true, withType: type)
            }
        }
    }

}
