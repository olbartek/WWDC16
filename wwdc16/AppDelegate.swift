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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        DefaultsManager.saveCategoryTypeToPresent(nil)
        if let launchOptions = launchOptions {
            return checkIfShortcutItemTriggeredApplicationStartWithLaunchOptions(launchOptions as NSDictionary)
        } else { return true }
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if let shortcutItem = shortcutItem {
            _ = handleShortcut(shortcutItem)
            self.shortcutItem = nil
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    // MARK: Shortcut items
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem))
    }
    
    func handleShortcut(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
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
    
    func checkIfShortcutItemTriggeredApplicationStartWithLaunchOptions(_ launchOptions: NSDictionary) -> Bool {
        var performShortcutDelegate = true
        if let shortcutItem = launchOptions.object(forKey: UIApplicationLaunchOptionsKey.shortcutItem) as? UIApplicationShortcutItem {
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
        DefaultsManager.saveCategoryTypeToPresent(.myApps)
    }
    
    func handleAboutMeShortcut() {
        DefaultsManager.saveCategoryTypeToPresent(.aboutMe)
    }
    
    func handleInterestsShortcut() {
        DefaultsManager.saveCategoryTypeToPresent(.interests)
    }
    
    func handleSkillsShortcut() {
        DefaultsManager.saveCategoryTypeToPresent(.skills)
    }


}

