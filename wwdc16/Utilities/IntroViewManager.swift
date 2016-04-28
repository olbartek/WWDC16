//
//  IntroViewManager.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

enum IntroViewType {
    case MyApps
    case MyHobbies
    case MySkills
}

class IntroViewManager: NSObject {
    
    private class func getViewFromNib() -> IntroViewTemplate? {
        if let aView =  NSBundle.mainBundle().loadNibNamed("IntroViewTemplate", owner: self, options: nil)[0] as? IntroViewTemplate {
            return aView
        }
        return nil
    }
    
    class func presentIntroViewWithType(type: IntroViewType, onPresenter presenter: UIViewController) {
        guard let viewToPresent = getViewFromNib() else { return }
        let textToPresent: String?
        let imageToPresent: UIImage?
        switch type {
        case .MyApps:
            textToPresent = "Swipe down \nto reach AppStore"
            imageToPresent = UIImage(named: "swipe-down")
        case .MyHobbies:
            textToPresent = "Double tap to change \nbackground photo. \nLive Photos are supported."
            imageToPresent = UIImage(named: "tap")
        case .MySkills:
            textToPresent = "Use force touch to show skills."
            imageToPresent = UIImage(named: "force-touch")
        }
        viewToPresent.frame = presenter.view.bounds
        viewToPresent.textLabel.text = textToPresent
        viewToPresent.imageView.image = imageToPresent
        
        presenter.view.addSubview(viewToPresent)
        presenter.view.bringSubviewToFront(viewToPresent)
        viewToPresent.animateAppearance()
        
    }

}
