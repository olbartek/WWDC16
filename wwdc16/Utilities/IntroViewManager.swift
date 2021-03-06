//
//  IntroViewManager.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

enum IntroViewType {
    case myApps
    case myHobbies
    case mySkills
}

class IntroViewManager: NSObject {
    
    // MARK: Constants
    
    fileprivate struct Constants {
        static let ForceTouchAnimationDuration: CFTimeInterval = 1.0
        static let SwipeAnimationDuration: CFTimeInterval = 1.0
        static let TapAnimationDuration: CFTimeInterval = 0.1
        static let SwipeAnimationYOffset: CGFloat = 20.0
        static let TapAnimationYOffset: CGFloat = 5.0
    }
    
    // MARK: Initialization
    
    fileprivate class func getViewFromNib() -> IntroViewTemplate? {
        if let aView =  Bundle.main.loadNibNamed("IntroViewTemplate", owner: self, options: nil)?[0] as? IntroViewTemplate {
            return aView
        }
        return nil
    }
    
    // MARK: Presenting a view
    
    class func presentIntroViewWithType(_ type: IntroViewType, onPresenter presenter: UIViewController) {
        guard let viewToPresent = getViewFromNib() else { return }
        let textToPresent: String?
        let imageToPresent: UIImage?
        switch type {
        case .myApps:
            textToPresent = "Swipe down \nto reach AppStore"
            imageToPresent = UIImage(named: "swipe-down")
        case .myHobbies:
            textToPresent = "Double tap to change \nbackground photo. \nLive Photos are supported."
            imageToPresent = UIImage(named: "tap")
        case .mySkills:
            textToPresent = "Use force touch to show skills."
            imageToPresent = UIImage(named: "force-touch")
        }
        viewToPresent.frame = presenter.view.bounds
        viewToPresent.textLabel.text = textToPresent
        viewToPresent.imageView.image = imageToPresent
        
        presenter.view.addSubview(viewToPresent)
        presenter.view.bringSubview(toFront: viewToPresent)
        viewToPresent.setNeedsLayout()
        viewToPresent.layoutIfNeeded()
        applyAnimationToImageView(viewToPresent.imageView, accordingToType: type)
        
        viewToPresent.animateAppearance()
    }
    
    // MARK: Animations
    
    fileprivate class func tapAnimationFromStarPoint(_ startPoint: CGPoint) -> CAAnimation {
        let endPoint = CGPoint(x: startPoint.x, y: startPoint.y + Constants.TapAnimationYOffset)
        
        let anim = CABasicAnimation(keyPath: "position")
        anim.fromValue = NSValue(cgPoint: startPoint)
        anim.toValue = NSValue(cgPoint: endPoint)
        anim.duration = Constants.TapAnimationDuration
        anim.autoreverses = true
        anim.beginTime = 1
        anim.repeatCount = 2
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [anim]
        animGroup.duration = 2 + Constants.TapAnimationDuration
        animGroup.repeatCount = Float.infinity
        
        return animGroup
    }
    
    fileprivate class func forceTouchAnimation() -> CAAnimation {
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.duration = Constants.ForceTouchAnimationDuration
        anim.autoreverses = true
        anim.fromValue = 1.0
        anim.toValue = 0.9
        anim.timingFunction = timingFunction
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [anim]
        animGroup.duration = 2 * Constants.ForceTouchAnimationDuration
        animGroup.repeatCount = Float.infinity
        
        return animGroup
    }
    
    fileprivate class func swipeDownAnimationFromStartPoint(_ startPoint: CGPoint) -> CAAnimation {
        let endPoint = CGPoint(x: startPoint.x, y: startPoint.y + Constants.SwipeAnimationYOffset)
        
        let anim = CABasicAnimation(keyPath: "position")
        anim.fromValue = NSValue(cgPoint: startPoint)
        anim.toValue = NSValue(cgPoint: endPoint)
        anim.duration = Constants.SwipeAnimationDuration
        anim.autoreverses = true
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [anim]
        animGroup.duration = 2 * Constants.SwipeAnimationDuration
        animGroup.repeatCount = Float.infinity
        
        return animGroup
    }
    
    fileprivate class func applyAnimationToImageView(_ imageView: UIImageView, accordingToType type: IntroViewType) {
        switch type {
        case .myApps:
            imageView.layer.add(swipeDownAnimationFromStartPoint(imageView.layer.position), forKey: "swipeDownAnimation")
        case .myHobbies:
            imageView.layer.add(tapAnimationFromStarPoint(imageView.layer.position), forKey: "tapAnimation")
        case .mySkills:
            imageView.layer.add(forceTouchAnimation(), forKey: "forceTouchAnimation")
        }
    }

}
