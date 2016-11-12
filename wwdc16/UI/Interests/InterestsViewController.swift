//
//  InterestsViewController.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit
import PhotosUI
import Photos
import MobileCoreServices

class InterestsViewController: PresentedViewController {
    
    // MARK: Properties
    
    fileprivate struct Constants {
        static let TimerTimeInterval: TimeInterval = 1.5
        static let CloseButtonOffsetFromRightEdge: CGFloat = 20.0 + 50.0
        static let Headers = ["Snowboard", "Travelling", "Electronics"]
        static let PhotoImages = ["snowboard.jpg", "travelling.jpg", "electronics.jpg"]
        static let SinglePulseAnimationDuration: CFTimeInterval = 0.3
    }
    
    var headerViewAnimators = [BOTextAnimator]()
    let viewWidth = UIScreen.main.bounds.size.width
    var moveFirstViewTimer: Timer?
    var currentTappedLivePhotoViewIndex: Int?
    
    @IBOutlet var livePhotoViews: [PHLivePhotoView]! {
        didSet {
            livePhotoViews.sort { (firstView, secondView) -> Bool in
                return firstView.tag < secondView.tag
            }
            livePhotoViews.forEach { (livePhotoView) in
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnView(_:)))
                tapGestureRecognizer.numberOfTapsRequired = 2
                livePhotoView.addGestureRecognizer(tapGestureRecognizer)
            }
        }
    }
    @IBOutlet var livePhotoImageViews: [UIImageView]! {
        didSet {
            livePhotoImageViews.sort { (firstView, secondView) -> Bool in
                return firstView.tag < secondView.tag
            }
        }
    }
    @IBOutlet var headerViews: [UIView]! {
        didSet {
            headerViews.sort { (firstView, secondView) -> Bool in
                return firstView.tag < secondView.tag
            }
        }
    }
    
    @IBOutlet var descriptionLabels: [UILabel]! {
        didSet {
            descriptionLabels.sort { (firstLabel, secondLabel) -> Bool in
                return firstLabel.tag < secondLabel.tag
            }
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var introImage: UIImageView!
    
    @IBOutlet weak var closeButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewWidthConstraint: NSLayoutConstraint!
    
    // MARK: VC' Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .themeAzureColor()
        setupConstraints()
        loadPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMoveFirstViewTimer()
        addIntroImageAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        invalidateTimer()
        removeIntroImageAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTextAnimators()
        let index = Int(scrollView.contentOffset.x) / Int(viewWidth) - 1
        if index >= 0 {
            headerViewAnimators[index].updatePathStrokeWithValue(1.0)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearTextAnimators()
    }
    
    // MARK: Appearance
    
    func setupConstraints() {
        closeButtonLeadingConstraint.constant = view.bounds.size.width - Constants.CloseButtonOffsetFromRightEdge
        viewWidthConstraint.constant = viewWidth
    }
    
    func setupTextAnimators() {
        for (index, headerView) in headerViews.enumerated() {
            let textAnimator = BOTextAnimator(referenceView: headerView)
            textAnimator.textToAnimate = Constants.Headers[index]
            textAnimator.prepareForAnimation()
            headerViewAnimators.append(textAnimator)
        }
    }
    
    func clearTextAnimators() {
        headerViewAnimators.removeAll()
    }
    
    // MARK: Gesture Recognizers
    
    func didTapOnView(_ gesture: UITapGestureRecognizer) {
        if let currentLivePhotoView = gesture.view as? PHLivePhotoView, let index = livePhotoViews.index(of: currentLivePhotoView) {
         currentTappedLivePhotoViewIndex = index
            configureAndShowPhotoActionSheet()
        }
    }
    
    // MARK: Animations
    
    func addIntroImageAnimation() {
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = Constants.SinglePulseAnimationDuration
        pulseAnimation.autoreverses = true
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 0.7
        pulseAnimation.timingFunction = timingFunction
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [pulseAnimation]
        animGroup.duration = Constants.SinglePulseAnimationDuration + 0.5
        animGroup.repeatCount = Float.infinity
        
        introImage.layer.add(animGroup, forKey: "pulseAnimation")
    }
    
    func removeIntroImageAnimation() {
        introImage.layer.removeAllAnimations()
    }
    
    // MARK: Photos
    
    func loadPhotos() {
        for (index, photoImageView) in livePhotoImageViews.enumerated() {
            photoImageView.image = UIImage(named: Constants.PhotoImages[index])
        }
    }
    
    func hintLivePhotoAtIndex(_ index: Int) {
        let livePhotoView = livePhotoViews[index]
        livePhotoView.startPlayback(with: .hint)
    }
    
    func hintLivePhoto() {
        let pageIndex = Int(scrollView.contentOffset.x) / Int(viewWidth) - 1
        if pageIndex >= 0 {
            hintLivePhotoAtIndex(pageIndex)
        }
    }
    
    // MARK: Photo Controller
    
    func configureAndShowPhotoActionSheet() {
        let actionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let chooseFromLibraryAction = UIAlertAction(title: "Choose from Library", style: .default) { (action) -> Void in
            self.showPhotoLibraryController()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        actionMenu.addAction(chooseFromLibraryAction)
        actionMenu.addAction(cancelAction)
        present(actionMenu, animated: true, completion: nil)
    }
    
    func showPhotoLibraryController() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        let mediaTypes = [String(kUTTypeImage), String(kUTTypeLivePhoto)]
        picker.mediaTypes = mediaTypes;
        
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: NSTimer
    
    func setupMoveFirstViewTimer() {
        moveFirstViewTimer = Timer.scheduledTimer(timeInterval: Constants.TimerTimeInterval, target: self, selector: #selector(timerDidFinishCounting(_:)), userInfo: nil, repeats: false)
    }
    
    func timerDidFinishCounting(_ timer: Timer) {
        let pageIndex = Int(scrollView.contentOffset.x) / Int(viewWidth)
        if pageIndex == 0 {
            scrollView.setContentOffset(CGPoint(x: viewWidth, y: 0), animated: true)
            IntroViewManager.presentIntroViewWithType(.myHobbies, onPresenter: self)
        }
    }
    
    func invalidateTimer() {
        if let timer = moveFirstViewTimer {
            timer.invalidate()
            self.moveFirstViewTimer = nil
        }
    }
    
    // MARK: Actions
    
    @IBAction func didPressCloseButton() {
        dismissViewControllerWithoutAnimation()
    }

}

// MARK: UIScrollView delegate

extension InterestsViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        hintLivePhoto()
        updateTextAnimators()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        hintLivePhoto()
        updateTextAnimators()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateTextAnimators()
    }
    
    func updateTextAnimators() {
        let contentOffsetX = scrollView.contentOffset.x - viewWidth
        for (index, headerViewAnimator) in headerViewAnimators.enumerated() {
            let startOffsetX = viewWidth * (CGFloat(index) - 0.5)
            let endOffsetX = startOffsetX + 0.5 * viewWidth
            if contentOffsetX >= startOffsetX && contentOffsetX <= endOffsetX {
                let strokeValue = (contentOffsetX - startOffsetX) / (0.5 * viewWidth)
                headerViewAnimator.updatePathStrokeWithValue(strokeValue)
            }
        }
    }
}

// MARK: UIImagePicker delegate 

extension InterestsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let tappedIndex = currentTappedLivePhotoViewIndex else { return }
        if let photo = info[UIImagePickerControllerLivePhoto] as? PHLivePhoto {
            livePhotoViews[tappedIndex].livePhoto = photo
        } else {
            if let _ = info[UIImagePickerControllerOriginalImage] as? UIImage {
                livePhotoViews[tappedIndex].livePhoto = nil
            }
        }
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            livePhotoImageViews[tappedIndex].image = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
