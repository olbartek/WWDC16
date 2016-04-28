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
    
    private struct Constants {
        static let TimerTimeInterval: NSTimeInterval = 1.5
        static let CloseButtonOffsetFromRightEdge: CGFloat = 20.0 + 50.0
        static let Headers = ["Snowboard", "Travelling", "Electronics"]
        static let PhotoImages = ["snowboard.jpg", "travelling.jpg", "electronics.jpg"]
        static let SinglePulseAnimationDuration: CFTimeInterval = 0.3
    }
    
    var headerViewAnimators = [BOTextAnimator]()
    let viewWidth = UIScreen.mainScreen().bounds.size.width
    var moveFirstViewTimer: NSTimer?
    var currentTappedLivePhotoViewIndex: Int?
    
    @IBOutlet var livePhotoViews: [PHLivePhotoView]! {
        didSet {
            livePhotoViews.sortInPlace { (firstView, secondView) -> Bool in
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
            livePhotoImageViews.sortInPlace { (firstView, secondView) -> Bool in
                return firstView.tag < secondView.tag
            }
        }
    }
    @IBOutlet var headerViews: [UIView]! {
        didSet {
            headerViews.sortInPlace { (firstView, secondView) -> Bool in
                return firstView.tag < secondView.tag
            }
        }
    }
    
    @IBOutlet var descriptionLabels: [UILabel]! {
        didSet {
            descriptionLabels.sortInPlace { (firstLabel, secondLabel) -> Bool in
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupMoveFirstViewTimer()
        addIntroImageAnimation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        invalidateTimer()
        removeIntroImageAnimation()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupTextAnimators()
        let index = Int(scrollView.contentOffset.x) / Int(viewWidth) - 1
        if index >= 0 {
            headerViewAnimators[index].updatePathStrokeWithValue(1.0)
        }
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        clearTextAnimators()
    }
    
    // MARK: Appearance
    
    func setupConstraints() {
        closeButtonLeadingConstraint.constant = view.bounds.size.width - Constants.CloseButtonOffsetFromRightEdge
        viewWidthConstraint.constant = viewWidth
    }
    
    func setupTextAnimators() {
        for (index, headerView) in headerViews.enumerate() {
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
    
    func didTapOnView(gesture: UITapGestureRecognizer) {
        if let currentLivePhotoView = gesture.view as? PHLivePhotoView, index = livePhotoViews.indexOf(currentLivePhotoView) {
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
        
        introImage.layer.addAnimation(animGroup, forKey: "pulseAnimation")
    }
    
    func removeIntroImageAnimation() {
        introImage.layer.removeAllAnimations()
    }
    
    // MARK: Photos
    
    func loadPhotos() {
        for (index, photoImageView) in livePhotoImageViews.enumerate() {
            photoImageView.image = UIImage(named: Constants.PhotoImages[index])
        }
    }
    
    func loadLivePhotos() {
        for (index, livePhotoView) in livePhotoViews.enumerate() {
            if let livePhoto = livePhotoForIndex(index) {
                livePhotoView.livePhoto = livePhoto
                 livePhotoView.startPlaybackWithStyle(.Hint)
            }
        }
    }
    
    func livePhotoForIndex(index: Int) -> PHLivePhoto? {
        let imageName: String?
        switch index {
        case 0:
            imageName = "snowboarding"
        case 1:
            imageName = "snowboarding"
        case 2:
            imageName = "snowboarding"
        default:
            imageName = nil
            break
        }
        if let imageName = imageName {
            let path    = NSBundle.mainBundle().pathForResource(imageName, ofType: "dat")
            let fileURL = NSURL(fileURLWithPath: path!)
            let data    = NSData(contentsOfURL: fileURL)
            if let livePhoto = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? PHLivePhoto {
                return livePhoto
            }
        }
        return nil
    }
    
    func hintLivePhotoAtIndex(index: Int) {
        let livePhotoView = livePhotoViews[index]
        livePhotoView.startPlaybackWithStyle(.Hint)
    }
    
    func hintLivePhoto() {
        let pageIndex = Int(scrollView.contentOffset.x) / Int(viewWidth) - 1
        if pageIndex >= 0 {
            hintLivePhotoAtIndex(pageIndex)
        }
    }
    
    // MARK: Photo Controller
    
    func configureAndShowPhotoActionSheet() {
        let actionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let chooseFromLibraryAction = UIAlertAction(title: "Choose from Library", style: .Default) { (action) -> Void in
            self.showPhotoLibraryController()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        actionMenu.addAction(chooseFromLibraryAction)
        actionMenu.addAction(cancelAction)
        presentViewController(actionMenu, animated: true, completion: nil)
    }
    
    func showPhotoLibraryController() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .PhotoLibrary
        let mediaTypes = [String(kUTTypeImage), String(kUTTypeLivePhoto)]
        picker.mediaTypes = mediaTypes;
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    // MARK: NSTimer
    
    func setupMoveFirstViewTimer() {
        moveFirstViewTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.TimerTimeInterval, target: self, selector: #selector(timerDidFinishCounting(_:)), userInfo: nil, repeats: false)
    }
    
    func timerDidFinishCounting(timer: NSTimer) {
        let pageIndex = Int(scrollView.contentOffset.x) / Int(viewWidth)
        if pageIndex == 0 {
            scrollView.setContentOffset(CGPoint(x: viewWidth, y: 0), animated: true)
            IntroViewManager.presentIntroViewWithType(.MyHobbies, onPresenter: self)
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
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        hintLivePhoto()
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        hintLivePhoto()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x - viewWidth
        for (index, headerViewAnimator) in headerViewAnimators.enumerate() {
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
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let tappedIndex = currentTappedLivePhotoViewIndex else { return }
        if let photo = info[UIImagePickerControllerLivePhoto] as? PHLivePhoto {
            livePhotoViews[tappedIndex].livePhoto = photo
        } else {
            notALivePhoto()
        }
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            livePhotoImageViews[tappedIndex].image = image
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func notALivePhoto() {
        print("Not a live photo")
    }
}
