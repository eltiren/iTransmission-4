//
//  FileManager.swift
//  Transmission
//
//  Created by Vitalii Yevtushenko on 25.07.2019.
//  Copyright © 2019 Roll'n'Code. All rights reserved.
//

import Foundation

extension FileManager {
    func containerURL() -> URL {
        URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
    }

    func containerSubURL(_ subdir: String) -> URL {
        return containerURL().appendingPathComponent(subdir)
    }

    func containerSubPath(_ subdir: String) -> String {
        return containerSubURL(subdir).path
    }

    func containerSubPathСString(_ subdir: String) -> [CChar] {
        return containerSubURL(subdir).path.cString(using: .utf8)!
    }

    func configURL() -> URL {
        return containerSubURL("config")
    }

    func configPath() -> String {
        return configURL().path
    }

    func torrentsURL() -> URL {
        return containerSubURL("torrents")
    }

    func createFoldersIfNeeded(_ preferences: Preferences) throws {
        let downloadsURL = containerSubURL(preferences.downloadFolder)
        let incompleteURL = containerSubURL(preferences.incompleteFolder)
        let urls = [configURL(), torrentsURL(), downloadsURL, incompleteURL]
        let attributes: [FileAttributeKey : Any] = [
            .protectionKey:FileProtectionType.none
        ]

        try urls.forEach {
            var isDirectory: ObjCBool = false
            var exists = self.fileExists(atPath: $0.path, isDirectory: &isDirectory)

            if exists && !isDirectory.boolValue {
                try self.removeItem(at: $0)
                exists = false
            }

            if !exists {
                try self.createDirectory(at: $0, withIntermediateDirectories: true, attributes: attributes)
            }
        }
    }
}
