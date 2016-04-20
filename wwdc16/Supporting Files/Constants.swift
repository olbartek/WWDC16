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
}

struct VC {
    static let AboutMe = Storyboard.AboutMe.instantiateInitialViewController() as! AboutMeViewController
    static let MyApps = Storyboard.MyApps.instantiateInitialViewController() as! MyAppsViewController
    static let Skills = Storyboard.Skills.instantiateInitialViewController() as! SkillsViewController
    static let Interests = Storyboard.Interests.instantiateInitialViewController() as! InterestsViewController
}

struct MainTableView {
    static let MaxHeight: CGFloat = 600.0
    static let MinHeight: CGFloat = 0.0
    static let CellMaxHeight: CGFloat = 250.0
    static let CellMinHeight: CGFloat = 0.0
}

struct AnimatingImage {
    static let Height: CGFloat = 375.0
    static let Width: CGFloat = 375.0
}

struct Animation {
    struct ShowCategories {
        static let Duration = 1.0
        static let Delay = 4.0
        static let Damping: CGFloat = 0.6
        static let Velocity: CGFloat = 0.5
    }
    struct HideCategories {
        static let Duration = 0.5
    }
    struct ShowNameLabels {
        static let Duration = 2.0
    }
    struct Bubbles {
        static let Duration: NSTimeInterval = 4.0
    }
}