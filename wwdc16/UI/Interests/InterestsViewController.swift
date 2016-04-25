//
//  InterestsViewController.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit
import PhotosUI

class InterestsViewController: PresentedViewController {
    
    // MARK: Properties
    
    private struct Constants {
        static let TimerTimeInterval: NSTimeInterval = 1.5
        static let CloseButtonOffsetFromRightEdge: CGFloat = 20.0 + 50.0
        static let Headers = ["Snowboard", "Travelling", "Sillicon Valley"]
    }
    
    var headerViewAnimators = [BOTextAnimator]()
    let viewWidth = UIScreen.mainScreen().bounds.size.width
    var moveFirstViewTimer: NSTimer?
    
    @IBOutlet var livePhotoViews: [PHLivePhotoView]! {
        didSet {
            livePhotoViews.sortInPlace { (firstView, secondView) -> Bool in
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
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var closeButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewWidthConstraint: NSLayoutConstraint!
    
    // MARK: VC' Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .themeAzureColor()
        setupConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupMoveFirstViewTimer()
        changeCloseButtonColor()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        invalidateTimer()
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
    
    // MARK: Actions
    
    @IBAction func didPressCloseButton() {
        dismissViewControllerWithoutAnimation()
    }

}

// MARK: UIScrollView delegate

extension InterestsViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        changeCloseButtonColor()
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        changeCloseButtonColor()
    }
    
    func changeCloseButtonColor() {
        let pageIndex = Int(scrollView.contentOffset.x) / Int(viewWidth)
        if pageIndex == 0 {
            closeButton.setFillColor(.whiteColor())
        } else {
            closeButton.setFillColor(.themeMarineColor())
        }
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
