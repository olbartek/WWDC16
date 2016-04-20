//
//  UIView+Constraints.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 20.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    /**
     :returns: true if v is in this view's super view chain
     */
    public func isSuper(v : UIView) -> Bool
    {
        var s: UIView? = self
        while (s != nil) {
            if(v == s) { return true }
            s = s?.superview
        }
        return false
    }
    
    public func constrain(attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, _ otherView: UIView, _ otherAttribute: NSLayoutAttribute, constant: CGFloat = 0.0, multiplier : CGFloat = 1.0) -> UIView?
    {
        let c = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: otherView, attribute: otherAttribute, multiplier: multiplier, constant: constant)
        
        if isSuper(otherView) {
            otherView.addConstraint(c)
            return self
        }
        else if(otherView.isSuper(self) || otherView == self)
        {
            self.addConstraint(c)
            return self
        }
        assert(false)
        return nil
    }
    
    public func constrain(attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, constant: CGFloat, multiplier : CGFloat = 1.0) -> UIView?
    {
        let c = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: nil, attribute: .NotAnAttribute, multiplier: multiplier, constant: constant)
        self.addConstraint(c)
        return self
    }
    
}