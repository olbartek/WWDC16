//
//  MyAppsViewController.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

class MyAppsViewController: PresentedViewController {
    
    // MARK: Properties
    
    fileprivate struct Constants {
        static let CloseButtonOffsetFromRightEdge: CGFloat = 20.0 + 50.0
        static let TimerTimeInterval: TimeInterval = 1.5
        static let AppURLs = [
            "https://itunes.apple.com/us/app/clime-micro-sensor-that-automates/id1049012375?mt=8",
            "https://itunes.apple.com/us/app/acti/id1069891566?mt=8",
            "https://itunes.apple.com/us/app/greatkiddo/id1027545512?mt=8"
        ]
        static let ShakeAnimationDuration: CFTimeInterval = 0.2
    }
    
    let viewWidth = UIScreen.main.bounds.size.width
    var moveFirstViewTimer: Timer?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var displayViews: [UIView]! {
        didSet {
            displayViews.sort { (firstView, secondView) -> Bool in
                return firstView.tag < secondView.tag
            }
        }
    }
    @IBOutlet weak var introImage: UIImageView!
    @IBOutlet var firstAppImageViews: [UIImageView]!
    @IBOutlet var secondAppImageViews: [UIImageView]!
    @IBOutlet var thirdAppImageViews: [UIImageView]!
    @IBOutlet weak var closeButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewWidthConstraint: NSLayoutConstraint!
    
    // MARK: VC's Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .themeMarineColor()
        setConstraints()
        configureSwipeGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMoveFirstViewTimer()
        changeCloseButtonColor()
        addIntroImageAnimation()
        addAppImagesAnimationForPageIndex(getCurrentPageIndex())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        invalidateTimer()
        removeIntroImageAnimation()
        removeAppImagesAnimation()
    }
    
    // MARK: Appearance
    
    func setConstraints() {
        closeButtonLeadingConstraint.constant = view.bounds.size.width - Constants.CloseButtonOffsetFromRightEdge
        viewWidthConstraint.constant = viewWidth
    }
    
    func getCurrentPageIndex() -> Int {
        return Int(scrollView.contentOffset.x) / Int(viewWidth)
    }
    
    // MARK: Animations
    
    func addIntroImageAnimation() {
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        introImage.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let shakeAnimationRight = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnimationRight.fromValue = 0
        shakeAnimationRight.toValue = CGFloat(-M_PI_2 / 6)
        shakeAnimationRight.duration = Constants.ShakeAnimationDuration / 2
        shakeAnimationRight.autoreverses = true
        shakeAnimationRight.timingFunction = timingFunction
        
        let shakeAnimationLeft = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnimationLeft.fromValue = 0
        shakeAnimationLeft.toValue = CGFloat(M_PI_2 / 6)
        shakeAnimationLeft.beginTime = Constants.ShakeAnimationDuration / 2
        shakeAnimationLeft.duration = Constants.ShakeAnimationDuration / 2
        shakeAnimationLeft.autoreverses = true
        shakeAnimationLeft.timingFunction = timingFunction
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [shakeAnimationRight, shakeAnimationLeft]
        animGroup.duration = Constants.ShakeAnimationDuration + 1
        animGroup.repeatCount = Float.infinity
        
        introImage.layer.add(animGroup, forKey: "shakeAnimation")
    }
    
    func removeIntroImageAnimation() {
        introImage.layer.removeAllAnimations()
    }
    
    func addAppImagesAnimationForPageIndex(_ pageIndex: Int) {
        removeAppImagesAnimation()
        switch pageIndex {
        case 1:
            addGroupAnimationToFirstImage(firstAppImageViews.first!, secondImage: firstAppImageViews.last!)
        case 2:
            addGroupAnimationToFirstImage(secondAppImageViews.first!, secondImage: secondAppImageViews.last!)
        case 3:
            addGroupAnimationToFirstImage(thirdAppImageViews.first!, secondImage: thirdAppImageViews.last!)
        default:
            break
        }
    }
    
    func removeAppImagesAnimation() {
        firstAppImageViews.forEach { (imageView) in
            imageView.layer.removeAllAnimations()
        }
        secondAppImageViews.forEach { (imageView) in
            imageView.layer.removeAllAnimations()
        }
        thirdAppImageViews.forEach { (imageView) in
            imageView.layer.removeAllAnimations()
        }
    }
    
    func addGroupAnimationToFirstImage(_ firstImage: UIImageView, secondImage: UIImageView) {
        
        firstImage.layer.zPosition = -1
        secondImage.layer.zPosition = 1
        
        firstImage.layer.add(firstPhotoAnimation(), forKey: "shuffle")
        secondImage.layer.add(secondPhotoAnimation(), forKey: "shuffle")
        
    }
    
    func firstPhotoAnimation() -> CAAnimationGroup {
        let zPosition = CABasicAnimation(keyPath: "zPosition")
        zPosition.fromValue = -1
        zPosition.toValue = 1
        zPosition.duration = 1.2
        
        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotation.values = [0, 0.14, 0]
        rotation.duration = 1.2
        rotation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        
        let position = CAKeyframeAnimation(keyPath: "position")
        position.values = [NSValue(cgPoint: CGPoint.zero), NSValue(cgPoint: CGPoint(x: 100, y: -20)), NSValue(cgPoint: CGPoint.zero)]
        position.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        position.isAdditive = true
        position.duration = 1.2
        
        let zPosition2 = CABasicAnimation(keyPath: "zPosition")
        zPosition2.fromValue = 1
        zPosition2.toValue = -1
        zPosition2.beginTime = zPosition.duration
        zPosition2.duration = 1.2
        
        let rotation2 = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotation2.values = [0, 0.14, 0]
        rotation2.beginTime = rotation.duration
        rotation2.duration = 1.2
        rotation2.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        
        let position2 = CAKeyframeAnimation(keyPath: "position")
        position2.values = [NSValue(cgPoint: CGPoint.zero), NSValue(cgPoint: CGPoint(x: 100, y: -20)), NSValue(cgPoint: CGPoint.zero)]
        position2.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        position2.isAdditive = true
        position2.beginTime = position.duration
        position2.duration = 1.2
        
        let group = CAAnimationGroup()
        group.animations = [zPosition, rotation, position, zPosition2, rotation2, position2]
        group.duration = 6
        group.repeatCount = Float.infinity
        
        return group
    }
    
    func secondPhotoAnimation() -> CAAnimationGroup {
        let zPosition = CABasicAnimation(keyPath: "zPosition")
        zPosition.fromValue = 1
        zPosition.toValue = -1
        zPosition.duration = 1.2
        
        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotation.values = [0, -0.14, 0]
        rotation.duration = 1.2
        rotation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        
        let position = CAKeyframeAnimation(keyPath: "position")
        position.values = [NSValue(cgPoint: CGPoint.zero), NSValue(cgPoint: CGPoint(x: -100, y: 20)), NSValue(cgPoint: CGPoint.zero)]
        position.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        position.isAdditive = true
        position.duration = 1.2
        
        let zPosition2 = CABasicAnimation(keyPath: "zPosition")
        zPosition2.fromValue = -1
        zPosition2.toValue = 1
        zPosition2.beginTime = zPosition.duration
        zPosition2.duration = 1.2
        
        let rotation2 = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotation2.values = [0, -0.14, 0]
        rotation2.beginTime = rotation.duration
        rotation2.duration = 1.2
        rotation2.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        
        let position2 = CAKeyframeAnimation(keyPath: "position")
        position2.values = [NSValue(cgPoint: CGPoint.zero), NSValue(cgPoint: CGPoint(x: -100, y: 20)), NSValue(cgPoint: CGPoint.zero)]
        position2.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        position2.isAdditive = true
        position2.beginTime = position.duration
        position2.duration = 1.2
        
        let group = CAAnimationGroup()
        group.animations = [zPosition, rotation, position, zPosition2, rotation2, position2]
        group.duration = 6
        group.repeatCount = Float.infinity
        
        return group
    }
    
    // MARK: NSTimer
    
    func setupMoveFirstViewTimer() {
        moveFirstViewTimer = Timer.scheduledTimer(timeInterval: Constants.TimerTimeInterval, target: self, selector: #selector(timerDidFinishCounting(_:)), userInfo: nil, repeats: false)
    }
    
    func timerDidFinishCounting(_ timer: Timer) {
        let pageIndex = Int(scrollView.contentOffset.x) / Int(viewWidth)
        if pageIndex == 0 {
            scrollView.setContentOffset(CGPoint(x: viewWidth, y: 0), animated: true)
            IntroViewManager.presentIntroViewWithType(.myApps, onPresenter: self)
        }
    }
    
    func invalidateTimer() {
        if let timer = moveFirstViewTimer {
            timer.invalidate()
            self.moveFirstViewTimer = nil
        }
    }
    
    // MARK: Gesture recognizer
    
    func configureSwipeGesture() {
        for singleView in displayViews {
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didDetectSwipeDown(_:)))
            swipeGesture.direction = .down
            singleView.addGestureRecognizer(swipeGesture)
        }
    }
    
    func didDetectSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        let pageIndex = getCurrentPageIndex()
        
        if pageIndex != 0 && pageIndex <= Constants.AppURLs.count {
            if let urlToOpen = URL(string: Constants.AppURLs[pageIndex - 1]) {
                UIApplication.shared.openURL(urlToOpen)
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func didPressCloseButton() {
        dismissViewControllerWithoutAnimation()
    }
}

extension MyAppsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        changeCloseButtonColor()
        addAppImagesAnimationForPageIndex(getCurrentPageIndex())
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        changeCloseButtonColor()
        addAppImagesAnimationForPageIndex(getCurrentPageIndex())
    }
    
    func changeCloseButtonColor() {
        let pageIndex = Int(scrollView.contentOffset.x) / Int(viewWidth)
        if pageIndex == 0 {
            closeButton.setFillColor(.white)
        } else {
            closeButton.setFillColor(.themeMarineColor())
        }
    }
}
