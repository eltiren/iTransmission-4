//
//  AppDelegate.swift
//  Transmission
//
//  Created by Vitalii Yevtushenko on 25.07.2019.
//  Copyright © 2019 Roll'n'Code. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let session = try! TRSession(preferences: UserDefaultsPreferences())

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        session.addTorrentsFromDocuments()
        print(session)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

