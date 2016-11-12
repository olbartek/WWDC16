//
//  BOTextAnimator.swift
//  BOTextAnimator
//
//  Created by Bartosz Olszanowski on 13.04.2016.
//  Copyright © 2016 olbart. All rights reserved.
//

import UIKit
import CoreFoundation

public protocol BOTextAnimatorDelegate {
    func textAnimator(_ textAnimator: BOTextAnimator, animationDidStart animation: CAAnimation)
    func textAnimator(_ textAnimator: BOTextAnimator, animationDidStop animation: CAAnimation)
}

open class BOTextAnimator: NSObject, CAAnimationDelegate {
    
    // MARK: Properties
    open var fontName         = "Avenir-Roman"
    open var fontSize         : CGFloat = 50.0
    open var textToAnimate    = "Hello Swift!"
    open var textColor        = UIColor.white.cgColor
    open var delegate         : BOTextAnimatorDelegate?
    
    fileprivate var animationLayer  = CALayer()
    fileprivate var pathLayer       : CAShapeLayer?
    fileprivate var referenceView   : UIView
    
    // MARK: Initialization
    init(referenceView: UIView) {
        self.referenceView          = referenceView
        super.init()
        defaultConfiguration()
    }
    
    deinit {
        clearLayer()
    }
    
    // MARK: Configuration
    fileprivate func defaultConfiguration() {
        animationLayer          = CALayer()
        animationLayer.frame    = referenceView.bounds
        referenceView.layer.addSublayer(animationLayer)
        setupPathLayerWithText(textToAnimate, fontName: fontName, fontSize: fontSize)
    }

    // MARK: Animations
    
    fileprivate func clearLayer() {
        if let _ = pathLayer {
            pathLayer?.removeFromSuperlayer()
            pathLayer = nil
        }
    }
    
    fileprivate func setupPathLayerWithText(_ text: String, fontName: String, fontSize: CGFloat) {
        clearLayer()
        
        let letters     = CGMutablePath()
        let font        = CTFontCreateWithName(fontName as CFString?, fontSize, nil)
        let attrString  = NSAttributedString(string: text, attributes: [kCTFontAttributeName as String : font])
        let line        = CTLineCreateWithAttributedString(attrString)
        let runArray    = CTLineGetGlyphRuns(line)
        
        for runIndex in 0..<CFArrayGetCount(runArray) {
            
            let run     : CTRun =  unsafeBitCast(CFArrayGetValueAtIndex(runArray, runIndex), to: CTRun.self)
            let dictRef : CFDictionary = unsafeBitCast(CTRunGetAttributes(run), to: CFDictionary.self)
            let dict    : NSDictionary = dictRef as NSDictionary
            let runFont = dict[kCTFontAttributeName as String] as! CTFont
            
            for runGlyphIndex in 0..<CTRunGetGlyphCount(run) {
                let thisGlyphRange  = CFRangeMake(runGlyphIndex, 1)
                var glyph           = CGGlyph()
                var position        = CGPoint.zero
                CTRunGetGlyphs(run, thisGlyphRange, &glyph)
                CTRunGetPositions(run, thisGlyphRange, &position)
                
                guard let letter = CTFontCreatePathForGlyph(runFont, glyph, nil) else { return }
                let t = CGAffineTransform(translationX: position.x, y: position.y)
                letters.addPath(letter, transform: t)
            }
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.append(UIBezierPath(cgPath: letters))
        
        let pathLayer               = CAShapeLayer()
        pathLayer.frame             = animationLayer.bounds;
        pathLayer.bounds            = path.cgPath.boundingBox
        pathLayer.isGeometryFlipped   = true
        pathLayer.path              = path.cgPath
        pathLayer.strokeColor       = textColor
        pathLayer.fillColor         = nil
        pathLayer.lineWidth         = 1.0
        pathLayer.lineJoin          = kCALineJoinBevel
        
        self.animationLayer.addSublayer(pathLayer)
        self.pathLayer = pathLayer
        
    }
    
    open func startAnimation() {
        let duration = 4.0
        pathLayer?.removeAllAnimations()
        setupPathLayerWithText(textToAnimate, fontName: fontName, fontSize: fontSize)
        
        let pathAnimation       = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration  = duration
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue   = 1.0
        pathAnimation.delegate  = self
        pathLayer?.add(pathAnimation, forKey: "strokeEnd")
        
        let coloringDuration        = 2.0
        let colorAnimation          = CAKeyframeAnimation(keyPath: "fillColor")
        colorAnimation.duration     = duration + coloringDuration
        colorAnimation.values       = [UIColor.clear.cgColor, UIColor.clear.cgColor, textColor]
        let middleValue             = duration / (duration + coloringDuration)
        colorAnimation.keyTimes     = [0, NSNumber(value: middleValue), 1]
        pathLayer?.add(colorAnimation, forKey: "fillColor")
    }
    
    open func stopAnimation() {
        pathLayer?.removeAllAnimations()
    }
    
    open func clearAnimationText() {
        clearLayer()
    }
    
    open func prepareForAnimation() {
        pathLayer?.removeAllAnimations()
        setupPathLayerWithText(textToAnimate, fontName: fontName, fontSize: fontSize)
        
        let pathAnimation       = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration  = 1.0
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue   = 1.0
        pathAnimation.delegate  = self
        pathLayer?.add(pathAnimation, forKey: "strokeEnd")
        
        pathLayer?.speed        = 0
        
    }
    
    open func updatePathStrokeWithValue(_ value: CGFloat) {
        DispatchQueue.main.async {
            self.pathLayer?.timeOffset = CFTimeInterval(value)
        }
        
    }
    
    // MARK: Animation delegate
    open func animationDidStart(_ anim: CAAnimation) {
        self.delegate?.textAnimator(self, animationDidStart: anim)
    }
    
    open func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.delegate?.textAnimator(self, animationDidStop: anim)
    }

}
