//
//  Constants.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import Foundation
import UIKit

struct ShortcutItem {
    static let MyApps = "com.olbart.wwdc16.my-apps"
    static let AboutMe = "com.olbart.wwdc16.about-me"
    static let Interests = "com.olbart.wwdc16.interests"
    static let Skills = "com.olbart.wwdc16.skills"
}

private struct Storyboard {
    static let AboutMe = UIStoryboard(name: "AboutMe", bundle: nil)
    static let MyApps = UIStoryboard(name: "MyApps", bundle: nil)
    static let Skills = UIStoryboard(name: "Skills", bundle: nil)
    static let Interests = UIStoryboard(name: "Interests", bundle: nil)
    static let ContactMe = UIStoryboard(name: "ContactMe", bundle: nil)
}

struct VC {
    static let AboutMe = Storyboard.AboutMe.instantiateInitialViewController() as! AboutMeViewController
    static let MyApps = Storyboard.MyApps.instantiateInitialViewController() as! MyAppsViewController
    static let Skills = Storyboard.Skills.instantiateInitialViewController() as! SkillsViewController
    static let Interests = Storyboard.Interests.instantiateInitialViewController() as! InterestsViewController
    static let ContactMe = Storyboard.ContactMe.instantiateInitialViewController() as! ContactMeViewController
}

struct MainTableView {
    static let MaxHeight: CGFloat = 600.0
    static let MinHeight: CGFloat = 0.0
}

struct AnimatingImage {
    static let Height: CGFloat = 375.0
    static let Width: CGFloat = 375.0
}

struct Animation {
    struct ShowCategories {
        static let Duration = 0.8
        static let Delay = 0.5
        static let Damping: CGFloat = 0.6
        static let Velocity: CGFloat = 0.5
    }
    struct HideCategories {
        static let Duration = 0.3
    }
    struct ShowNameLabels {
        static let Duration = 0.5
    }
    struct Bubbles {
        static let Duration: NSTimeInterval = 4.0
        static let RotateOneHalfDuration: CFTimeInterval = 1.5
        static let DelayBetweenRotations: CFTimeInterval = 0.25
    }
}

struct CategoryModel {
    static let NumOfCategories  = 5
    static let IconNames        = ["about-me", "interests", "skills", "my-apps", "about-me"]
    static let Titles           = ["About me", "Interests", "Skills", "My Apps", "Contact me"]
    static let Colors           : [UIColor] = [.themeOrangeColor(), .themePurpleColor(), .themePlumColor(), .themeBlueColor(), .themeRedColor()]
    static let TVCHeight: CGFloat = 250.0
}

struct SkillCategoryModel {
    static let Categories: [[String: AnyObject]] = [
        ["name" : "Programming",
        "skills" : [
            ["skillName" : "Obj-C", "percentage" : 90],
            ["skillName" : "Swift", "percentage" : 70],
            ["skillName" : "PHP", "percentage" : 60]
        ]],
        ["name" : "Electronics",
            "skills" : [
                ["skillName" : "ARM Cortex-M", "percentage" : 60],
                ["skillName" : "AVR", "percentage" : 50],
                ["skillName" : "RaspberryPI", "percentage" : 35]
        ]],
        ["name" : "Graphic Design",
            "skills" : [
                ["skillName" : "Adobe Photoshop", "percentage" : 60],
                ["skillName" : "Adobe Illustrator", "percentage" : 40],
                ["skillName" : "Gimp", "percentage" : 80]
            ]],
    ]
    static let TVCBasicHeight: CGFloat = 100.0
    static let CellCornerRadius: CGFloat = 8.0
}

struct SkillModel {
    static let TVCHeight: CGFloat = 80.0
}