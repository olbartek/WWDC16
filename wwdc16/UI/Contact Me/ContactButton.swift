//
//  ContactButton.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 23.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

enum ContactImageType : Int {
    case Facebook, Twitter, Linkedin
}

class ContactImage: UIImageView {
    
    var type: ContactImageType? {
        didSet {
            guard let currentType = type else { return }
            switch currentType {
            case .Facebook:
                image = UIImage(named:"fb-logo")
            case .Twitter:
                image = UIImage(named:"twitter-logo")
            case .Linkedin:
                image = UIImage(named:"linkedin-logo")
            }
        }
    }
    var startAngle: CGFloat = 0.0
    
    private struct Constants {
        static let ImageRadius: CGFloat = 25.0
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = Constants.ImageRadius
        layer.masksToBounds = true
    }

}
