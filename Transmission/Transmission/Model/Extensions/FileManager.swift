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

    func configPath() -> String {
        return containerSubPath("config")
    }
}
