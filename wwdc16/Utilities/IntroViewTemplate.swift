//
//  IntroViewTemplate.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 26.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

class IntroViewTemplate: UIView {

    // MARK: Properties
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
    // Gesture Recognizers
    
    func addGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnView(_:)))
        bgView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: Early initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.alpha = 0.0
        addGestureRecognizer()
    }
    
    // MARK: Animations
    
    func animateAppearance() {
        UIView.animate(withDuration: 1, animations: {
            self.bgView.alpha = 0.7
        }, completion: { (finished) in
            
        }) 
    }
    
    func didTapOnView(_ gesture: UITapGestureRecognizer) {
        UIView.animate(withDuration: 1, animations: {
            self.bgView.alpha = 0.0
            }, completion: { (finished) in
                self.removeFromSuperview()
        }) 
    }
}
