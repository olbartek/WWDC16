//
//  SkillsCategory.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 21.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

let skillNameKey                = "skillName"
let skillKnowledgePercentageKey = "percentage"

class SkillsCategory: NSObject {
    
    // MARK: Properties
    
    var name    : String
    var skills  = [Skill]()
    
    // MARK: Initialization
    
    init(name: String, skills: [[String: AnyObject]]) {
        self.name = name
        for skill in skills {
            if let skillName = skill[skillNameKey] as? String, skillPercentage = skill[skillKnowledgePercentageKey] as? Int {
                let newSkill = Skill(name: skillName, knowledgePercentage: skillPercentage)
                self.skills.append(newSkill)
            }
        }
    }

}
