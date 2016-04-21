//
//  Skill.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 21.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

class Skill: NSObject {
    
    // MARK: Properties
    
    var name                : String
    var knowledgePercentage : Int
    
    // MARK: Initilization
    
    init(name: String, knowledgePercentage: Int) {
        self.name                   = name
        self.knowledgePercentage    = knowledgePercentage
        super.init()
    }

}
