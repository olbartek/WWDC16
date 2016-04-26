//
//  PresentedViewController.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 21.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

class PresentedViewController: UIViewController {
    
    // MARK: Properties
    
    var delegate            : MainViewControllerDelegate?
    var categoryCellCenter  = CGPointZero
    @IBOutlet weak var closeButton: CloseButton!
    
    // MARK: VC's Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //view.setNeedsLayout()
        //view.setNeedsDisplay()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        closeButton.removeCrossLayer()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        closeButton.drawCross()
        closeButton.animateCross()
    }
    
    // MARK: Dismiss animation
    
    func dismissViewControllerWithoutAnimation() {
        let snapshot = view.snapshotViewAfterScreenUpdates(false)
        if let presentingViewController = presentingViewController {
            presentingViewController.view.addSubview(snapshot)
            dismissViewControllerAnimated(false) {
                self.delegate?.presentedViewControllerWillDismissToCenterPoint(self.categoryCellCenter, withSnapShot: snapshot)
            }
        }
    }

}
