//
//  AppDelegate.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Properties

    var window: UIWindow?
    var shortcutItem: UIApplicationShortcutItem?
    
    // MARK: App delegate main methods

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        DefaultsManager.saveCategoryTypeToPresent(nil)
        if let launchOptions = launchOptions {
            return checkIfShortcutItemTriggeredApplicationStartWithLaunchOptions(launchOptions)
        } else { return true }
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
        if let shortcutItem = shortcutItem {
            handleShortcut(shortcutItem)
            self.shortcutItem = nil
        }
    }

    func applicationWillTerminate(application: UIApplication) {
    }
    
    // MARK: Shortcut items
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem))
    }
    
    func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
        switch shortcutItem.type {
        case ShortcutItem.MyApps:
            handleMyAppsShortcut()
            return true
        case ShortcutItem.AboutMe:
            handleAboutMeShortcut()
            return true
        case ShortcutItem.Interests:
            handleInterestsShortcut()
            return true
        case ShortcutItem.Skills:
            handleSkillsShortcut()
            return true
        default:
            break
        }
        return false
    }
    
    func checkIfShortcutItemTriggeredApplicationStartWithLaunchOptions(launchOptions: NSDictionary) -> Bool {
        var performShortcutDelegate = true
        if let shortcutItem = launchOptions.objectForKey(UIApplicationLaunchOptionsShortcutItemKey) as? UIApplicationShortcutItem {
            self.shortcutItem = shortcutItem
            performShortcutDelegate = false
            switch shortcutItem.type {
            case ShortcutItem.MyApps:
                handleMyAppsShortcut()
            case ShortcutItem.AboutMe:
                handleAboutMeShortcut()
            case ShortcutItem.Interests:
                handleInterestsShortcut()
            case ShortcutItem.Skills:
                handleSkillsShortcut()
            default:
                break
            }
        }
        return performShortcutDelegate
    }
    
    func handleMyAppsShortcut() {
        DefaultsManager.saveCategoryTypeToPresent(.MyApps)
    }
    
    func handleAboutMeShortcut() {
        DefaultsManager.saveCategoryTypeToPresent(.AboutMe)
    }
    
    func handleInterestsShortcut() {
        DefaultsManager.saveCategoryTypeToPresent(.Interests)
    }
    
    func handleSkillsShortcut() {
        DefaultsManager.saveCategoryTypeToPresent(.Skills)
    }


}

