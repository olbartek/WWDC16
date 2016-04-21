//
//  SkillsCategoryTableViewCell.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 21.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

class SkillsCategoryTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var skillsViewHeightConstraint: NSLayoutConstraint! {
        didSet {
            skillsViewHeightConstraint.constant = 0
        }
    }
    
    var skills = [Skill]()

    // MARK: Configuration
   
    func configureWithSkillCategory(skillCategory: SkillsCategory) {
        titleLabel.text = skillCategory.name
        skills = skillCategory.skills
        registerNibs()
        tableView.delegate = self
        tableView.dataSource = self
        selectionStyle = .None
    }
    
    func registerNibs() {
        tableView.registerNib(UINib(nibName: SkillTableViewCell.identifier(), bundle: nil), forCellReuseIdentifier: SkillTableViewCell.identifier())
    }
}

extension SkillsCategoryTableViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return skills.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell        = tableView.dequeueReusableCellWithIdentifier(SkillTableViewCell.identifier(), forIndexPath: indexPath) as! SkillTableViewCell
        let skill    = skills[indexPath.row]
        cell.nameLabel.text = skill.name
        cell.selectionStyle = .None
        cell.userInteractionEnabled = false
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
}
