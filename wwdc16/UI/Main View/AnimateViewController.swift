//
//  AnimateViewController.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 20.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

class AnimateViewController: UIViewController {
    
    @IBOutlet weak var animationView: UIView!
    
    var mainViewAnimator: MainViewAnimator?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainViewAnimator = MainViewAnimator(referenceView: animationView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        mainViewAnimator?.startAnimation()
    }


}
