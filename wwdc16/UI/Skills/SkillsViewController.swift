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
            if let categoryName = categoryDict[categoryNameKey] as? String, let categoryImageName = categoryDict[categoryImageNameKey] as? String, let categorySkills = categoryDict[categorySkillsKey] as? [[String: AnyObject]] {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        closeButton.setFillColor(.themeSkyBlueColor())
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if traitCollection.isForceTouchAvailable() {
            IntroViewManager.presentIntroViewWithType(.mySkills, onPresenter: self)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let enlargedCell = enlargedCell {
            enlargedCell.setDefaultColors()
            shrinkCell(enlargedCell)
        }
    }
    
    // MARK: Appearance
    
    func registerNibs() {
        tableView.register(UINib(nibName: SkillsCategoryTableViewCell.identifier(), bundle: nil), forCellReuseIdentifier: SkillsCategoryTableViewCell.identifier())
    }
    
    // MARK: Actions
    
    @IBAction func didPressCloseButton() {
        dismissViewControllerWithoutAnimation()
    }

}

extension SkillsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return skillCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell        = tableView.dequeueReusableCell(withIdentifier: SkillsCategoryTableViewCell.identifier(), for: indexPath) as! SkillsCategoryTableViewCell
        
        let skillCategory = skillCategories[(indexPath as NSIndexPath).row]
        cell.configureWithSkillCategory(skillCategory)
        if traitCollection.isForceTouchAvailable() {
            cell.delegate = self
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !traitCollection.isForceTouchAvailable() {
            if let enlargedCell = enlargedCell {
                shrinkCell(enlargedCell)
            } else {
                let cell = tableView.cellForRow(at: indexPath) as! SkillsCategoryTableViewCell
                enlargeCell(cell)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if !traitCollection.isForceTouchAvailable() {
            if let enlargedCell = enlargedCell {
                shrinkCell(enlargedCell)
            }
        }
    }
    
    func shrinkCell(_ cell: SkillsCategoryTableViewCell) {
        cell.cellViewHeightConstraint.constant = 0
        enlargedCell = nil
        tableView.beginUpdates()
        tableView.endUpdates()
        cell.restartSkillsAnimation()
        cell.isOpened = false
        cell.shouldOpenDelegateSent = false
    }
    
    func enlargeCell(_ cell: SkillsCategoryTableViewCell) {
        enlargedCell = cell
        let cellsHeight = SkillModel.TVCHeight * CGFloat(cell.tableView.numberOfRows(inSection: 0))
        cell.cellViewHeightConstraint.constant = SkillCategoryModel.TVCBasicHeight + cellsHeight
        tableView.beginUpdates()
        tableView.endUpdates()
        cell.startSkillsAnimation()
        cell.isOpened = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}

// MARK: SkillsCategoryTableViewCell delegate

extension SkillsViewController: SkillsCategoryTableViewCellDelegate {
    func skillsCategoryCell(_ cell: SkillsCategoryTableViewCell, shouldOpenSkillsWithTouchForce touchForce: CGFloat) {
        if let enlargedCell = enlargedCell , enlargedCell != cell {
            enlargedCell.setDefaultColors()
            shrinkCell(enlargedCell)
            enlargeCell(cell)
        } else {
            enlargeCell(cell)
        }
    }
}
