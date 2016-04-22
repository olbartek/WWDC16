//
//  ProgressView.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 22.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    // MARK: Properties
    
    var progressFill = 0.5
    var progressLayer: CAShapeLayer?
    
    // MARK: Drawing

    override func drawRect(rect: CGRect) {
        
        layer.cornerRadius = rect.size.height / 2
        layer.masksToBounds = true
        
        let startPoint = CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMidY(rect))
        let endPoint = CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMidY(rect))
        
        let drawingPath = UIBezierPath()
        drawingPath.moveToPoint(startPoint)
        drawingPath.addLineToPoint(endPoint)
        drawingPath.closePath()
        
        let progressLayer = CAShapeLayer()
        progressLayer.path = drawingPath.CGPath
        progressLayer.strokeColor = UIColor.greenColor().CGColor
        progressLayer.lineWidth = rect.size.width / 2
        self.progressLayer = progressLayer
        
    }
    
    // MARK: Animation
    
    func startAnimation() {
        guard let progressLayer = progressLayer else { return }
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.duration = 0.5
        strokeAnimation.removedOnCompletion = false
        strokeAnimation.fromValue = 0
        strokeAnimation.toValue = progressFill
        
        progressLayer.addAnimation(strokeAnimation, forKey: "progressAnimation")
        
        layer.sublayers?.forEach({ (sublayer) in
            sublayer.removeFromSuperlayer()
        })
        layer.addSublayer(progressLayer)
    }
    
    

}
