//
//  SkillsViewController.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

let categoryNameKey         = "name"
let categoryImageNameKey    = "imageName"
let categorySkillsKey       = "skills"

class SkillsViewController: PresentedViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    var skillCategories: [SkillsCategory] = {
        var categories = [SkillsCategory]()
        for categoryDict in SkillCategoryModel.Categories {
            if let categoryName = categoryDict[categoryNameKey] as? String, categoryImageName = categoryDict[categoryImageNameKey] as? String, categorySkills = categoryDict[categorySkillsKey] as? [[String: AnyObject]] {
                let newCategory = SkillsCategory(name: categoryName, imageName: categoryImageName, skills: categorySkills)
                categories.append(newCategory)
            }
        }
        return categories
    }()
    var enlargedCell: SkillsCategoryTableViewCell?
    
    // MARK: VC's Lifecyle

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        closeButton.setFillColor(.themeSkyBlueColor())
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        IntroViewManager.presentIntroViewWithType(.MySkills, onPresenter: self)
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if let enlargedCell = enlargedCell {
            enlargedCell.setDefaultColors()
            shrinkCell(enlargedCell)
        }
    }
    
    // MARK: Appearance
    
    func registerNibs() {
        tableView.registerNib(UINib(nibName: SkillsCategoryTableViewCell.identifier(), bundle: nil), forCellReuseIdentifier: SkillsCategoryTableViewCell.identifier())
    }
    
    // MARK: Actions
    
    @IBAction func didPressCloseButton() {
        dismissViewControllerWithoutAnimation()
    }

}

extension SkillsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return skillCategories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell        = tableView.dequeueReusableCellWithIdentifier(SkillsCategoryTableViewCell.identifier(), forIndexPath: indexPath) as! SkillsCategoryTableViewCell
        
        let skillCategory = skillCategories[indexPath.row]
        cell.configureWithSkillCategory(skillCategory)
        if traitCollection.isForceTouchAvailable() {
            cell.delegate = self
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !traitCollection.isForceTouchAvailable() {
            if let enlargedCell = enlargedCell {
                shrinkCell(enlargedCell)
            } else {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! SkillsCategoryTableViewCell
                enlargeCell(cell)
            }
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if !traitCollection.isForceTouchAvailable() {
            if let enlargedCell = enlargedCell {
                shrinkCell(enlargedCell)
            }
        }
    }
    
    func shrinkCell(cell: SkillsCategoryTableViewCell) {
        cell.cellViewHeightConstraint.constant = 0
        enlargedCell = nil
        tableView.beginUpdates()
        tableView.endUpdates()
        cell.restartSkillsAnimation()
        cell.isOpened = false
        cell.shouldOpenDelegateSent = false
    }
    
    func enlargeCell(cell: SkillsCategoryTableViewCell) {
        enlargedCell = cell
        let cellsHeight = SkillModel.TVCHeight * CGFloat(cell.tableView.numberOfRowsInSection(0))
        cell.cellViewHeightConstraint.constant = SkillCategoryModel.TVCBasicHeight + cellsHeight
        tableView.beginUpdates()
        tableView.endUpdates()
        cell.startSkillsAnimation()
        cell.isOpened = true
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}

// MARK: SkillsCategoryTableViewCell delegate

extension SkillsViewController: SkillsCategoryTableViewCellDelegate {
    func skillsCategoryCell(cell: SkillsCategoryTableViewCell, shouldOpenSkillsWithTouchForce touchForce: CGFloat) {
        if let enlargedCell = enlargedCell where enlargedCell != cell {
            enlargedCell.setDefaultColors()
            shrinkCell(enlargedCell)
            enlargeCell(cell)
        } else {
            enlargeCell(cell)
        }
    }
}
