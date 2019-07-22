//
//  FileManager.swift
//  iTransmission
//
//  Created by Vitalii Yevtushenko on 22.07.2019.
//

import Foundation

@objc extension FileManager {
    @objc func documentsDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths.first!
    }

    @objc func documentsDirectoryURL() -> URL {
        URL(fileURLWithPath: documentsDirectoryPath())
    }

    @objc func torrentsPath() -> String {
        torrentsURL().path
    }

    @objc func torrentsURL() -> URL {
        documentsDirectoryURL().appendingPathComponent("torrents")
    }

    @objc func configPath() -> String {
        configURL().path
    }

    @objc func configURL() -> URL {
        documentsDirectoryURL().appendingPathComponent("config")
    }

    @objc func downloadsPath() -> String {
        downloadsURL().path
    }

    @objc func downloadsURL() -> URL {
        documentsDirectoryURL().appendingPathComponent("downloads")
    }

    @objc func transferPlistPath() -> String {
        transferPlistURL().path
    }

    @objc func transferPlistURL() -> URL {
        documentsDirectoryURL().appendingPathComponent("Transfer.plist")
    }

    @objc func randomTorrentPath() -> String {
        randomTorrentURL().path
    }

    @objc func randomTorrentURL() -> URL {
        torrentsURL().appendingPathComponent("\(Date().timeIntervalSince1970).torrent")
    }
}
