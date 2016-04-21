//
//  AboutMeViewController.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

class AboutMeViewController: PresentedViewController {
    
    // MARK: VC's Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .themeOrangeColor()
    }
    
    // MARK: Actions
    
    @IBAction func didPressCloseButton() {
        dismissViewControllerWithoutAnimation()
    }

}
