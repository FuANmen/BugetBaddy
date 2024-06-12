//
//  AppDelegate.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/01.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // UserDefaultsに保存されている初回起動フラグを確認
        if UserDefaults.standard.bool(forKey: "isFirstLaunch") == false {
            // UserDefaultsの初期値設定
            UserDefaults.standard.set("50000", forKey: "MonthlyDefaultManagementAmount")
            
            // デバイスの設定言語をUserDefaultsに保存
            let currentLanguage = Locale.preferredLanguages.first
            UserDefaults.standard.set([currentLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
            
            // アプリ初回起動日時を登録
            if UserDefaults.standard.object(forKey: "firstLaunchDate") == nil {
                UserDefaults.standard.set(Date(), forKey: "firstLaunchDate")
            }
            
            // UserDefaultsに初回起動フラグを保存
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
            UserDefaults.standard.synchronize()
        }
        

        UserDefaults.standard.set("2023-12", forKey: "firstLaunchDate")
            
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

