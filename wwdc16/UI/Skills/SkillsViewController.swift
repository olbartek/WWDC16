//
//  SkillsViewController.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

let categoryNameKey     = "name"
let categorySkillsKey   = "skills"

class SkillsViewController: PresentedViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    var skillCategories: [SkillsCategory] = {
        var categories = [SkillsCategory]()
        for categoryDict in SkillCategoryModel.Categories {
            if let categoryName = categoryDict[categoryNameKey] as? String, categorySkills = categoryDict[categorySkillsKey] as? [[String: AnyObject]] {
                let newCategory = SkillsCategory(name: categoryName, skills: categorySkills)
                categories.append(newCategory)
            }
        }
        return categories
    }()
    
    
    // MARK: VC's Lifecyle

    override func viewDidLoad() {
        super.viewDidLoad()

        registerNibs()
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

}
