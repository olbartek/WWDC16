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
    
    @IBOutlet var nameLabel         : UILabel!
    @IBOutlet weak var progressView : UIView!
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
    
    let progressViewWidth: CGFloat = 180.0
    var progress                    : CGFloat = 1.0
    
    // MARK: Configuration
    
    func configureWithSkill(skill: Skill) {
        nameLabel.text = skill.name
        progress = CGFloat(skill.knowledgePercentage) / 100.0
        selectionStyle = .None
        userInteractionEnabled = false
    }
    
    // MARK: Animations
    
    func startProgressAnimation() {
        progressWidthConstraint.constant = progressViewWidth * progress
        UIView.animateWithDuration(0.8) {
            self.layoutIfNeeded()
        }
    }
    
    func restartProgressAnimation() {
        progressWidthConstraint.constant = 0.0
    }
}
