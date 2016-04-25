//
//  UIBezierPath+crossPath.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 25.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import Foundation
import UIKit

extension UIBezierPath {
    
    class func crossPartTopLeftToBottomRightWithinRect(rect: CGRect, thickness: CGFloat) -> UIBezierPath {
        let drawRect = CGRectInset(rect, 15.0, 15.0)
        let x = drawRect.origin.x
        let y = drawRect.origin.y
        let width = drawRect.size.width
        let height = drawRect.size.height
        let offset = thickness / 2
        let path = UIBezierPath()
        
        // Values calculation
        let topLeftLowerPoint = CGPoint(x: x, y: y + offset)
        let bottomRightLowerPoint = CGPoint(x: x + width - offset, y: y + height)
        let bottomRightUpperPoint = CGPoint(x: x + width, y: y + height - offset)
        let topLeftUpperPoint = CGPoint(x: x + offset, y: y)
        let bottomRightControlPoint = CGPoint(x: x + width, y: y + height)
        let topLeftControlPoint = CGPoint(x: x, y: y)
        
        path.moveToPoint(topLeftLowerPoint)
        path.addLineToPoint(bottomRightLowerPoint)
        path.addQuadCurveToPoint(bottomRightUpperPoint, controlPoint: bottomRightControlPoint)
        path.addLineToPoint(topLeftUpperPoint)
        path.addQuadCurveToPoint(topLeftLowerPoint, controlPoint: topLeftControlPoint)
        path.closePath()
        
        return path
    }
    
    class func crossPartBottomLeftTopRightWithinRect(rect: CGRect, thickness: CGFloat) -> UIBezierPath {
        let drawRect = CGRectInset(rect, 15.0, 15.0)
        let x = drawRect.origin.x
        let y = drawRect.origin.y
        let width = drawRect.size.width
        let height = drawRect.size.height
        let offset = thickness / 2
        let path = UIBezierPath()
        
        // Values calculation
        let bottomLeftUpperPoint = CGPoint(x: x, y: y + height - offset)
        let topRightUpperPoint = CGPoint(x: x + width - offset, y: y)
        let topRightLowerPoint = CGPoint(x: x + width, y: y + offset)
        let bottomLeftLowerPoint = CGPoint(x: x + offset, y: y + height)
        let bottomLeftControlPoint = CGPoint(x: x, y: y + height)
        let topRightControlPoint = CGPoint(x: x + width, y: y)
        
        path.moveToPoint(bottomLeftUpperPoint)
        path.addLineToPoint(topRightUpperPoint)
        path.addQuadCurveToPoint(topRightLowerPoint, controlPoint: topRightControlPoint)
        path.addLineToPoint(bottomLeftLowerPoint)
        path.addQuadCurveToPoint(bottomLeftUpperPoint, controlPoint: bottomLeftControlPoint)
        path.closePath()
        
        return path
    }
}