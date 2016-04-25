//
//  UITraitCollection+ForceTouch.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 25.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import Foundation
import UIKit

extension UITraitCollection {
    func isForceTouchAvailable() -> Bool {
        return self.forceTouchCapability == .Available
    }
}