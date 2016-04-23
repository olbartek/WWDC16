//
//  MyAppsViewController.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

class MyAppsViewController: PresentedViewController {
    
    // MARK: VC's Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .themeMarineColor()
    }
    
    // MARK: Actions
    
    @IBAction func didPressCloseButton() {
        dismissViewControllerWithoutAnimation()
    }

}
