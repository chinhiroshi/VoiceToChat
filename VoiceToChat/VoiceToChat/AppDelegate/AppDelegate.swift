//
//  AppDelegate.swift
//  VoiceToChat
//
//  Created by Shree on 31/03/20.
//  Copyright © 2020 Shree. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let strLang = UserDefaults.Main.string(forKey: .changeLanguage)
        if strLang.count == 0 {
            
            var deviceLanguage = Locale.current.languageCode ?? "en"
            deviceLanguage = deviceLanguage.lowercased()
            
            if deviceLanguage == "zh-hans" || deviceLanguage == "zh-hant" || deviceLanguage == "zh-hk" || deviceLanguage == "zh"  {
                deviceLanguage = "zh-Hans"
            }
            
            if deviceLanguage == "en" || deviceLanguage == "ja" || deviceLanguage == "zh-Hans" {
                UserDefaults.Main.set(deviceLanguage, forKey: .changeLanguage)
                UserDefaults.standard.synchronize()
            } else {
                UserDefaults.Main.set("en", forKey: .changeLanguage)
                UserDefaults.standard.synchronize()
            }
        }
        
        let strSpeechToTextLang = UserDefaults.Main.string(forKey: .speechToTextLanguage)
        var deviceLanguage = Locale.current.languageCode ?? "en"
        deviceLanguage = deviceLanguage.lowercased()
        
        if deviceLanguage == "zh-hans" || deviceLanguage == "zh-hant" || deviceLanguage == "zh-hk" || deviceLanguage == "zh"  {
            deviceLanguage = "zh-Hans"
        }
        print("deviceLanguage : ",deviceLanguage)
        
        if strSpeechToTextLang.count == 0 {
            if deviceLanguage == "en" || deviceLanguage == "ja" || deviceLanguage == "zh-Hans" {
                
                UserDefaults.Main.set(deviceLanguage, forKey: .speechToTextLanguage)
                UserDefaults.standard.synchronize()
            } else {
                
                UserDefaults.Main.set("en", forKey: .speechToTextLanguage)
                UserDefaults.standard.synchronize()
            }
        }
        
        UserDefaults.Main.set(false, forKey: .isBannerAdsReceived)
        UserDefaults.standard.synchronize()
        
        let strLastDate = UserDefaults.Main.string(forKey: .last_date)
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let str_current_date = formatter.string(from: date)
        if strLastDate.count == 0 {
            
            UserDefaults.Main.set(str_current_date, forKey: .last_date)
            UserDefaults.Main.set(0, forKey: .int_chat_counter)
            
        } else if strLastDate != str_current_date {
            
            UserDefaults.Main.set(str_current_date, forKey: .last_date)
            UserDefaults.Main.set(0, forKey: .int_chat_counter)
        }
        
        if #available(iOS 13, *) {
            // use the feature only available in iOS 9
            // for ex. UIStackView
        } else {
            redirectNavigation()
        }
        
        //Memory Initialize Ads View
        //GoogleAdMob.sharedInstance.initializeInterstitial(isLiveUnitID: false)
        let isProductPurchased = IAPManager.shared.isProductPurchased(productId: strInAppPurchase)
        if isProductPurchased == false {
            GoogleAdMob.sharedInstance.initializeBannerView(isLiveUnitID: false)
        }
        
        return true
    }
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        print("url : ",url)
        print("app : ",app)
        
        return true
    }
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        
        print("url : ",url)
        
        return true
    }
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "VoiceToChat")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate {
    
    func redirectNavigation() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserListVC") as! UserListVC
        let navVC = UINavigationController(rootViewController: vc)
        navVC.isNavigationBarHidden = true
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
    }
}
