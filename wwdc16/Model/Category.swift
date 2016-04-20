//
//  Category.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 20.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

enum CategoryType: Int {
    case AboutMe, Interests, Skills, MyApps, Something
}

class Category: NSObject {
    
    // MARK: Properties
    
    var bgColor     : UIColor
    var title       : String
    var iconName    : String
    var type        : CategoryType
    
    // MARK: Initialization
    
    init(title: String, bgColor: UIColor, iconName: String, type: CategoryType) {
        self.title      = title
        self.bgColor    = bgColor
        self.iconName   = iconName
        self.type       = type
        super.init()
    }

}
