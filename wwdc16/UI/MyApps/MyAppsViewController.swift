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
    
    private struct Constants {
        static let CloseButtonOffsetFromRightEdge: CGFloat = 20.0 + 50.0
        static let TimerTimeInterval: NSTimeInterval = 1.5
        static let AppURLs = [
            "https://itunes.apple.com/us/app/clime-micro-sensor-that-automates/id1049012375?mt=8",
            "https://itunes.apple.com/us/app/acti/id1069891566?mt=8",
            "https://itunes.apple.com/us/app/greatkiddo/id1027545512?mt=8"
        ]
    }
    
    let viewWidth = UIScreen.mainScreen().bounds.size.width
    var moveFirstViewTimer: NSTimer?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var displayViews: [UIView]! {
        didSet {
            displayViews.sortInPlace { (firstView, secondView) -> Bool in
                return firstView.tag < secondView.tag
            }
        }
    }
    @IBOutlet var appImageViews: [UIImageView]!
    @IBOutlet weak var closeButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewWidthConstraint: NSLayoutConstraint!
    
    // MARK: VC's Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .themeMarineColor()
        setConstraints()
        configureSwipeGesture()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupMoveFirstViewTimer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        invalidateTimer()
    }
    
    // MARK: Appearance
    
    func setConstraints() {
        closeButtonLeadingConstraint.constant = view.bounds.size.width - Constants.CloseButtonOffsetFromRightEdge
        viewWidthConstraint.constant = viewWidth
    }
    
    // MARK: NSTimer
    
    func setupMoveFirstViewTimer() {
        moveFirstViewTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.TimerTimeInterval, target: self, selector: #selector(timerDidFinishCounting(_:)), userInfo: nil, repeats: false)
    }
    
    func timerDidFinishCounting(timer: NSTimer) {
        let pageIndex = Int(scrollView.contentOffset.x) / Int(viewWidth)
        if pageIndex == 0 {
            scrollView.setContentOffset(CGPoint(x: viewWidth, y: 0), animated: true)
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
            swipeGesture.direction = .Down
            singleView.addGestureRecognizer(swipeGesture)
        }
    }
    
    func didDetectSwipeDown(gesture: UISwipeGestureRecognizer) {
        let pageIndex = Int(scrollView.contentOffset.x) / Int(viewWidth)
        
        if pageIndex != 0 && pageIndex <= Constants.AppURLs.count {
            if let urlToOpen = NSURL(string: Constants.AppURLs[pageIndex - 1]) {
                UIApplication.sharedApplication().openURL(urlToOpen)
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func didPressCloseButton() {
        dismissViewControllerWithoutAnimation()
    }
}

extension MyAppsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        changeCloseButtonColor()
    }
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        changeCloseButtonColor()
    }
    
    func changeCloseButtonColor() {
        let pageIndex = Int(scrollView.contentOffset.x) / Int(viewWidth)
        if pageIndex == 0 {
        closeButton.bottomLeftTopRightCrossPartLayer?.fillColor = UIColor.whiteColor().CGColor
        closeButton.topLeftBottomRightCrossPartLayer?.fillColor = UIColor.whiteColor().CGColor
        } else {
        closeButton.bottomLeftTopRightCrossPartLayer?.fillColor = UIColor.themeMarineColor().CGColor
        closeButton.topLeftBottomRightCrossPartLayer?.fillColor = UIColor.themeMarineColor().CGColor
        }
    }
}
