//
//  SkillTableViewCell.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 21.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

class SkillTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    fileprivate struct Constants {
        static let ForceTouchNotAvailableColor = UIColor(red: 183.0 / 255.0, green: 183.0 / 255.0, blue: 183.0 / 255.0, alpha: 1.0)
    }
    
    @IBOutlet var nameLabel         : UILabel!
    @IBOutlet weak var progressView : UIView!
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
    
    let progressViewWidth           : CGFloat  = 180.0
    var progress                    : CGFloat = 1.0
    
    // MARK: Configuration
    
    func configureWithSkill(_ skill: Skill) {
        nameLabel.text = skill.name
        progress = CGFloat(skill.knowledgePercentage) / 100.0
        selectionStyle = .none
        isUserInteractionEnabled = false
        backgroundColor = UIColor.clear
        if traitCollection.isForceTouchAvailable() {
            nameLabel.textColor = UIColor.white
            progressView.backgroundColor = UIColor.white
        } else {
            nameLabel.textColor = Constants.ForceTouchNotAvailableColor
            progressView.backgroundColor = Constants.ForceTouchNotAvailableColor
        }
    }
    
    // MARK: Animations
    
    func startProgressAnimation() {
        progressWidthConstraint.constant = progressViewWidth * progress
        UIView.animate(withDuration: 0.8, animations: {
            self.layoutIfNeeded()
        }) 
    }
    
    func restartProgressAnimation() {
        progressWidthConstraint.constant = 0.0
    }
}
