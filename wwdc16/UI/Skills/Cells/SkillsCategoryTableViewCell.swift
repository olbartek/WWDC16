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
    @IBOutlet weak var cellViewHeightConstraint: NSLayoutConstraint! {
        didSet {
            cellViewHeightConstraint.constant = SkillCategoryModel.TVCBasicHeight
        }
    }
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var cellView: UIView!
    
    var skills = [Skill]()
    var selectedIndexPath: NSIndexPath?

    // MARK: Configuration
   
    func configureWithSkillCategory(skillCategory: SkillsCategory) {
        titleLabel.text = skillCategory.name
        categoryImageView.image = UIImage(named: skillCategory.imageName)
        skills = skillCategory.skills
        registerNibs()
        tableView.delegate = self
        tableView.dataSource = self
        cellView.layer.cornerRadius = SkillCategoryModel.CellCornerRadius
        cellView.layer.masksToBounds = true
        selectionStyle = .None
        backgroundColor = .clearColor()
    }
    
    func registerNibs() {
        tableView.registerNib(UINib(nibName: SkillTableViewCell.identifier(), bundle: nil), forCellReuseIdentifier: SkillTableViewCell.identifier())
    }
    
    // MARK: Skills animation
    
    func startSkillsAnimation() {
        for row in 0..<skills.count {
            let cellToAnimate = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as! SkillTableViewCell
            cellToAnimate.startProgressAnimation()
        }
    }
    
    func restartSkillsAnimation() {
        for row in 0..<skills.count {
            let cellToAnimate = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as! SkillTableViewCell
            cellToAnimate.restartProgressAnimation()
        }
    }
}

extension SkillsCategoryTableViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return skills.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell        = tableView.dequeueReusableCellWithIdentifier(SkillTableViewCell.identifier(), forIndexPath: indexPath) as! SkillTableViewCell
        let skill    = skills[indexPath.row]
        cell.configureWithSkill(skill)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SkillModel.TVCHeight
    }
}
