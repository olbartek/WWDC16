//
//  DefaultsManager.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 23.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

let categoryToPresentKey = "categoryToPresentKey"

class DefaultsManager: NSObject {
    
    // MARK: Category to present
    
    class func saveCategoryTypeToPresent(_ categoryType: CategoryType?) {
        if let categoryType = categoryType {
            UserDefaults.standard.set(categoryType.rawValue, forKey: categoryToPresentKey)
        } else {
            UserDefaults.standard.set(-1, forKey: categoryToPresentKey)
        }
    }
    
    class func loadCategoryTypeToPresent() -> CategoryType? {
        let categoryToPresentInt = UserDefaults.standard.integer(forKey: categoryToPresentKey)
        if categoryToPresentInt < 0 {
            return nil
        } else {
            return CategoryType(rawValue: categoryToPresentInt)
        }
    }

}
