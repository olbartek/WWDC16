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
    
    // MARK: VC's Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
//    func createSnapShot() {
//        if let superVC =  as? UIViewController {
//            let snapshot = superVC.view.snapshotViewAfterScreenUpdates(false)
//            if let window = UIApplication.sharedApplication().keyWindow {
//                window.rootViewController?.view.addSubview(snapshot)
//            }
//        }
//    }

}
