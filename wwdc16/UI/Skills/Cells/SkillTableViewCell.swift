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
    @IBOutlet weak var progressView : ProgressView!
    
    // MARK: Configuration
    
    func configureWithSkill(skill: Skill) {
        nameLabel.text = skill.name
        progressView.progressFill = Double(skill.knowledgePercentage) / 100.0
        selectionStyle = .None
        userInteractionEnabled = false
    }
    
    // MARK: Animations
    
    func startProgressAnimation() {
        progressView.startAnimation()
    }
}
