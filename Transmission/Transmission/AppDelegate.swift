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
    var preferences = UserDefaultsPreferences()
    var session: TRSession!

    func test() {
        print("Config Dir: \(session.configDir)")
        print("Download Dir: \(session.downloadDir)")
        print("Incomplete Dir: \(session.incompleteDir)")
        print("Incomplete Dir Enabled: \(session.isIncompleteDirEnabled)")
        print("Incomplete File Naming Enabled: \(session.isIncompleteFileNamingEnabled)")
        print("RPC Enabled: \(session.isRPCEnabled)")
        print("RPC Port: \(session.rpcPort)")
        print("RPC URL: \(session.rpcURL)")
        print("RPC Whitelist: \(session.rpcWhitelist)")
        print("RPC Whitelist Enabled: \(session.isRPCWhitelistEnabled)")
        print("RPC Username: \(session.rpcUsername)")
        print("RPC Password: \(session.rpcPassword)")
        print("RPC Password Enabled: \(session.rpcPasswordEnabled)")
        print("RPC Bind Address: \(session.rpcBindAddress)")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        try! FileManager.default.createFoldersIfNeeded(preferences)
        session = try! TRSession(configDir: FileManager.default.configPath(), settings: preferences.toVariantDictionary())
        test()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

