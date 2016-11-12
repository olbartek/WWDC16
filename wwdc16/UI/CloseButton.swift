//
//  CloseButton.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 25.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

class CloseButton: UIButton {
    
    // MARK: Properties
    
    fileprivate struct Constants {
        static let ButtonThickness: CGFloat = 6.0
        static let ButtonFillColor: UIColor = .white
        static let ButtonRotationAnimationDuration: CFTimeInterval = 0.4
    }
    
    var topLeftBottomRightCrossPartLayer: CAShapeLayer?
    var bottomLeftTopRightCrossPartLayer: CAShapeLayer?
    
    fileprivate var buttonFillColor: UIColor?
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: SetUp
    
    func setFillColor(_ color: UIColor) {
        buttonFillColor = color
        topLeftBottomRightCrossPartLayer?.fillColor = color.cgColor
        bottomLeftTopRightCrossPartLayer?.fillColor = color.cgColor
    }
    
    // MARK: Drawing

    func drawCross() {
        let fillColor = buttonFillColor ?? Constants.ButtonFillColor
        
        let topLeftBottomRightBezierPath = UIBezierPath.crossPartTopLeftToBottomRightWithinRect(bounds, thickness: Constants.ButtonThickness)
        let topLeftBottomRightCrossPartLayer = CAShapeLayer()
        topLeftBottomRightCrossPartLayer.path = topLeftBottomRightBezierPath.cgPath
        topLeftBottomRightCrossPartLayer.fillColor = fillColor.cgColor
        let layerFrameTopLeftBottomRight = topLeftBottomRightBezierPath.cgPath.boundingBox
        topLeftBottomRightCrossPartLayer.bounds = layerFrameTopLeftBottomRight
        topLeftBottomRightCrossPartLayer.frame = layerFrameTopLeftBottomRight
        
        layer.addSublayer(topLeftBottomRightCrossPartLayer)
        self.topLeftBottomRightCrossPartLayer = topLeftBottomRightCrossPartLayer
        
        let bottomLeftTopRightBezierPath = UIBezierPath.crossPartBottomLeftTopRightWithinRect(bounds, thickness: Constants.ButtonThickness)
        let bottomLeftTopRightCrossPartLayer = CAShapeLayer()
        bottomLeftTopRightCrossPartLayer.path = bottomLeftTopRightBezierPath.cgPath
        bottomLeftTopRightCrossPartLayer.fillColor = fillColor.cgColor
        let layerFrameBottomLeftTopRight = bottomLeftTopRightBezierPath.cgPath.boundingBox
        bottomLeftTopRightCrossPartLayer.bounds = layerFrameBottomLeftTopRight
        bottomLeftTopRightCrossPartLayer.frame = layerFrameBottomLeftTopRight
        
        layer.addSublayer(bottomLeftTopRightCrossPartLayer)
        self.bottomLeftTopRightCrossPartLayer = bottomLeftTopRightCrossPartLayer
    }
    
    // MARK: Animation
    
    func animateCross() {
        guard let firstCrossPart = topLeftBottomRightCrossPartLayer, let secondCrossPart = bottomLeftTopRightCrossPartLayer else { return }
        
        firstCrossPart.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let firstPartRotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        firstPartRotationAnimation.fromValue = 0
        firstPartRotationAnimation.toValue     = CGFloat(-M_PI_2)
        firstPartRotationAnimation.duration    = Constants.ButtonRotationAnimationDuration
        firstPartRotationAnimation.autoreverses = true
        
        secondCrossPart.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let secondPartRotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        secondPartRotationAnimation.fromValue = 0
        secondPartRotationAnimation.toValue     = CGFloat(M_PI_2)
        secondPartRotationAnimation.duration    = Constants.ButtonRotationAnimationDuration
        secondPartRotationAnimation.autoreverses = true
        
        firstCrossPart.add(firstPartRotationAnimation, forKey: "rotationAnimationFirst")
        secondCrossPart.add(secondPartRotationAnimation, forKey: "rotationAnimationSecond")
    }
    
    // MARK: CleanUp
    
    func removeCrossLayer() {
        guard let firstCrossPart = topLeftBottomRightCrossPartLayer, let secondCrossPart = bottomLeftTopRightCrossPartLayer else { return }
        firstCrossPart.removeFromSuperlayer()
        secondCrossPart.removeFromSuperlayer()
        self.topLeftBottomRightCrossPartLayer = nil
        self.bottomLeftTopRightCrossPartLayer = nil
    }

}
