//
//  ContactMeViewController.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 21.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

class ContactMeViewController: PresentedViewController, CAAnimationDelegate {
    
    // MARK: Properties
    
    fileprivate struct Constants {
        static let ImageSide: CGFloat = 75.0
        static let MovementAnimationDuration: CFTimeInterval = 0.3
        static func MovementAnimationKeyAtIndex(_ index: Int) -> String { return "movementAnimation\(index)" }
        static let SinglePulseAnimationDuration: CFTimeInterval = 0.5
        static let SigleRotationAnimationDuration: CFTimeInterval = 8
        static let LabelAlphaAnimationDuration: CFTimeInterval = 0.5
        static let ImageOffsetFromViewCenter: CGFloat = 100.0
        static let ConstactInfoLabelLeadingOffset: CGFloat = 80.0
        static let ConstactInfoLabelTrailingOffset: CGFloat = 8.0
        static let ContactInfoImageMinHeight: CGFloat = 0.0
        static let ContactInfoImageMaxHeight: CGFloat = 50.0
    }
    var currentEndPosition = CGPoint.zero
    var currentContactImage: ContactImage?
    var animationIndex = 0
    var contactInfoViewHidden = true
    var contactInfoViewAnimating = false
    var contactImagesRotationAnimationStarted = false
    
    @IBOutlet var contactImages: [ContactImage]!
    @IBOutlet weak var contactMeImage: UIImageView!
    @IBOutlet weak var contactInfoImage: ContactImage!
    @IBOutlet weak var contactInfoLabel: UILabel!
    @IBOutlet weak var contactInfoView: UIView!
    
    @IBOutlet weak var contactInfoImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contactInfoLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contactInfoLabelWidthConstraint: NSLayoutConstraint!
    
    // MARK: VC's Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .themePinkColor()
        prepareContactImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideContactImages(true)
        contactImagesRotationAnimationStarted = false
        contactMeImage.layer.opacity = 0.0
        prepareContactInfoView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeAllAnimations()
        hideContactInfoAndShowAnotherInfo(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contactImagesMovementAnimation()
    }
    
    // MARK: Preparation
    
    func prepareContactImages() {
        for i in 0..<contactImages.count {
            let contactImage = contactImages[i]
            contactImage.type = ContactImageType(rawValue: i)
            contactImage.isUserInteractionEnabled = true
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnView(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    func prepareContactInfoView() {
        contactInfoLabelWidthConstraint.constant = UIScreen.main.bounds.size.width - Constants.ConstactInfoLabelLeadingOffset - Constants.ConstactInfoLabelTrailingOffset
        contactInfoImageHeightConstraint.constant = 0.0
        contactInfoLabelLeadingConstraint.constant = -1.0 * contactInfoLabelWidthConstraint.constant
        contactInfoViewHidden = true
        view.layoutIfNeeded()
        view.setNeedsUpdateConstraints()
    }
    
    // MARK: Appearance
    
    func hideContactImages(_ hide: Bool) {
        let alphaToSet: CGFloat = hide ? 0.0 : 1.0
        contactImages.forEach { (button) in
            button.alpha = alphaToSet
        }
    }
    
    func imageFromType(_ type: ContactImageType) -> UIImage {
        switch type {
        case .facebook:
            return UIImage(named: "fb-logo")!
        case .linkedin:
            return UIImage(named: "linkedin-logo")!
        case .twitter:
            return UIImage(named: "twitter-logo")!
        }
    }
    
    func contactTextFromType(_ type: ContactImageType) -> String {
        switch type {
        case .facebook:
            return "fb.com/bartosz.olszanowski"
        case .linkedin:
            return "linkedin.com/in/olszanowski"
        case .twitter:
            return "twitter.com/olbartek"
        }
    }
    
    // MARK: Animations
    
    func contactImagesMovementAnimation() {
        
        let startPosition = view.center
        let initialEndPosition = CGPoint(x: view.center.x, y: view.center.y + Constants.ImageOffsetFromViewCenter)
        let initialAngle = 2 * CGFloat(M_PI) / CGFloat(contactImages.count)
        currentEndPosition = CGPoint.zero
        
        
        for (index, contactImage) in contactImages.enumerated() {
            let angle = initialAngle * CGFloat(index)
            contactImage.startAngle = angle
            
            var rotationTransform = CGAffineTransform(translationX: startPosition.x, y: startPosition.y)
            rotationTransform = rotationTransform.rotated(by: angle)
            rotationTransform = rotationTransform.translatedBy(x: -startPosition.x, y: -startPosition.y)
            let endPosition = initialEndPosition.applying(rotationTransform)
            
            currentEndPosition = endPosition
            currentContactImage = contactImage
            
            let alphaAnimation = CABasicAnimation(keyPath: "opacity")
            alphaAnimation.fromValue = 0.0
            alphaAnimation.toValue = 1.0
            
            let movementAnimation = CABasicAnimation(keyPath: "position")
            movementAnimation.fromValue = NSValue(cgPoint: startPosition)
            movementAnimation.toValue = NSValue(cgPoint: endPosition)
            
            let groupAnimation = CAAnimationGroup()
            groupAnimation.animations = [alphaAnimation, movementAnimation]
            groupAnimation.beginTime = CACurrentMediaTime() + Double(index) * Constants.MovementAnimationDuration
            groupAnimation.duration = Constants.MovementAnimationDuration
            groupAnimation.isRemovedOnCompletion = true
            groupAnimation.fillMode = kCAFillModeBackwards
            if index == contactImages.count - 1 {
                groupAnimation.delegate = self
            }
            
            contactImage.layer.position = endPosition
            contactImage.layer.opacity = 1.0
            contactImage.layer.add(groupAnimation, forKey: Constants.MovementAnimationKeyAtIndex(index))
            
        }
    }
    
    func contactImagesRotationAnimation() {
        
        for contactImage in contactImages {
            contactImage.layer.removeAllAnimations()
            let animationPath = UIBezierPath()
            animationPath.move(to: contactImage.layer.position)
            let startAngle = CGFloat(M_PI_2) + contactImage.startAngle
            animationPath.addArc(withCenter: view.center, radius: Constants.ImageOffsetFromViewCenter, startAngle: startAngle, endAngle: 2 * CGFloat(M_PI) + startAngle, clockwise: true)
            animationPath.close()
            let pathAnimation = CAKeyframeAnimation(keyPath: "position")
            pathAnimation.beginTime = CACurrentMediaTime() + Constants.LabelAlphaAnimationDuration
            pathAnimation.duration = Constants.SigleRotationAnimationDuration
            pathAnimation.path  = animationPath.cgPath
            pathAnimation.repeatCount = Float.infinity
            pathAnimation.calculationMode = kCAAnimationPaced
            pathAnimation.fillMode = kCAFillModeBackwards
            
            contactImage.layer.add(pathAnimation, forKey: "movingAnimation")
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
        
        contactMeImage.layer.add(alphaAnimation, forKey: "alphaAnimation")
        contactMeImage.layer.add(pulseAnimation, forKey: "pulseAnimation")
    }
    
    func removeAllAnimations() {
        contactMeImage.layer.removeAllAnimations()
        contactImages.forEach { (image) in
            image.layer.removeAllAnimations()
        }
    }
    
    func showContactInfoWithType(_ type: ContactImageType) {
        contactInfoViewAnimating = true
        contactInfoImage.image = imageFromType(type)
        contactInfoLabel.text = contactTextFromType(type)
        contactInfoImageHeightConstraint.constant = Constants.ContactInfoImageMaxHeight
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: {
            self.contactInfoView.layoutIfNeeded()
            }) { (finished) in
                self.contactInfoLabelLeadingConstraint.constant = 0
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: {
                    self.contactInfoView.layoutIfNeeded()
                    }, completion: { (finished) in
                        self.contactInfoViewAnimating = false
                        self.contactInfoViewHidden = false
                })
        }
    }
    
    func hideContactInfoAndShowAnotherInfo(_ showAnother: Bool, withType type: ContactImageType? = nil) {
        contactInfoViewAnimating = true
        contactInfoLabelLeadingConstraint.constant = -1.0 * contactInfoLabelWidthConstraint.constant
        UIView.animate(withDuration: 0.25, animations: {
            self.contactInfoView.layoutIfNeeded()
            }, completion: { (finished) in
                self.contactInfoImageHeightConstraint.constant = Constants.ContactInfoImageMinHeight
                UIView.animate(withDuration: 0.25, animations: {
                    self.contactInfoView.layoutIfNeeded()
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
        }) 
    }
    
    // MARK: Animation delegate
    
    func animationDidStart(_ anim: CAAnimation) {
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
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
    
    func didTapOnView(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: view)
        for contactImage in contactImages {
            if let presentationLayer = contactImage.layer.presentation(),
                let _ = presentationLayer.hitTest(touchPoint),
                let contactImageType = contactImage.type {
                didPressContactImageWithType(contactImageType)
                return
            }
        }
    }
    
    func didPressContactImageWithType(_ type: ContactImageType) {
        if !contactInfoViewAnimating {
            if contactInfoViewHidden {
                showContactInfoWithType(type)
            } else {
                hideContactInfoAndShowAnotherInfo(true, withType: type)
            }
        }
    }

}
