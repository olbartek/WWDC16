//
//  UITableViewCell+Identifier.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    class func identifier() -> String! {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
}
