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
    var selectedIndexPath: NSIndexPath?
    
    // MARK: VC's Lifecyle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .themeSkyBlueColor()
        registerNibs()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedIndexPath = selectedIndexPath {
            shrinkCellAtIndexPath(selectedIndexPath)
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
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let selectedIndexPath = selectedIndexPath where selectedIndexPath.row == indexPath.row {
            shrinkCellAtIndexPath(indexPath)
        } else {
            enlargeCellAtIndexPath(indexPath)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        shrinkCellAtIndexPath(indexPath)
    }
    
    func shrinkCellAtIndexPath(indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SkillsCategoryTableViewCell
        cell.cellViewHeightConstraint.constant = 0
        selectedIndexPath = nil
        tableView.beginUpdates()
        tableView.endUpdates()
        cell.restartSkillsAnimation()
    }
    
    func enlargeCellAtIndexPath(indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SkillsCategoryTableViewCell
        let selectedSkillCategory = skillCategories[indexPath.row]
        let cellsHeight = SkillModel.TVCHeight * CGFloat(selectedSkillCategory.skills.count)
        cell.cellViewHeightConstraint.constant = SkillCategoryModel.TVCBasicHeight + cellsHeight
        tableView.beginUpdates()
        tableView.endUpdates()
        cell.startSkillsAnimation()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}
