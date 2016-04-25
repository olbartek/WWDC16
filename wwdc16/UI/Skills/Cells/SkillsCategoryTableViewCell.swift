//
//  SkillsCategoryTableViewCell.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 21.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

protocol SkillsCategoryTableViewCellDelegate {
    func skillsCategoryCell(cell: SkillsCategoryTableViewCell, shouldOpenSkillsWithTouchForce touchForce: CGFloat)
}

class SkillsCategoryTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    private struct Constants {
        static let CellBackgroundColor = UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0)
        static let TitleLabelTextColor = UIColor(red: 183.0 / 255.0, green: 183.0 / 255.0, blue: 183.0 / 255.0, alpha: 1.0)
        static let Hue: CGFloat = 212.0 / 360.0
        static let Brightness: CGFloat = 96.0 / 100.0
        static let MinSaturation: CGFloat = 5.0 / 100.0
        static let MaxSaturation: CGFloat = 67.0 / 100.0
        static let MinForcePercentageToOpenCell: CGFloat = 0.8
    }
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var cellViewHeightConstraint: NSLayoutConstraint! {
        didSet {
            cellViewHeightConstraint.constant = SkillCategoryModel.TVCBasicHeight
        }
    }
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var cellView: UIView!
    
    var delegate: SkillsCategoryTableViewCellDelegate?
    var skills = [Skill]()
    var selectedIndexPath: NSIndexPath?
    var isOpened = false
    var shouldOpenDelegateSent = false

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
    
    // MARK: Appearance
    
    func setDefaultColors() {
        cellView.backgroundColor = Constants.CellBackgroundColor
        titleLabel.textColor = Constants.TitleLabelTextColor
    }
    
    func colorAccordingToTouchForcePercentage(forcePercentage: CGFloat) -> UIColor {
        
        let saturation = Constants.MinSaturation + forcePercentage * (Constants.MaxSaturation - Constants.MinSaturation)
        
        return UIColor(hue: Constants.Hue, saturation: saturation, brightness: Constants.Brightness, alpha: 1.0)
    }
    
    func titleLabelColorAccordingToTouchForcePercentage(forcePercentage: CGFloat) -> UIColor {
        if forcePercentage >= 0.2 {
            return UIColor.whiteColor()
        } else {
            return Constants.TitleLabelTextColor
        }
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
    
    // MARK: Force Touch
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first where traitCollection.forceTouchCapability == .Available {
            if !isOpened {
                var forcePercentage = touch.force / (Constants.MinForcePercentageToOpenCell * touch.maximumPossibleForce)
                if forcePercentage > 1.0 {
                    if !shouldOpenDelegateSent {
                        delegate?.skillsCategoryCell(self, shouldOpenSkillsWithTouchForce: touch.force)
                        shouldOpenDelegateSent = true
                    }
                    forcePercentage = 1.0
                }
                cellView.backgroundColor = colorAccordingToTouchForcePercentage(forcePercentage)
                titleLabel.textColor = titleLabelColorAccordingToTouchForcePercentage(forcePercentage)
            }
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
