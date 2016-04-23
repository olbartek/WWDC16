//
//  ContactButton.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 23.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

enum ContactButtonType : Int {
    case Facebook, Twitter, Linkedin
}

class ContactButton: UIButton {
    
    var type: ContactButtonType? {
        didSet {
            guard let currentType = type else { return }
            switch currentType {
            case .Facebook:
                setImage(UIImage(named:"fb-logo"), forState: .Normal)
            case .Twitter:
                setImage(UIImage(named:"twitter-logo"), forState: .Normal)
            case .Linkedin:
                setImage(UIImage(named:"linkedin-logo"), forState: .Normal)
            }
        }
    }
    var startAngle: CGFloat = 0.0
    
    private struct Constants {
        static let ButtonRadius: CGFloat = 25.0
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = Constants.ButtonRadius
        layer.masksToBounds = true
    }

}
