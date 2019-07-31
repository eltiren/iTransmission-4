//
//  TRSession.swift
//  Transmission
//
//  Created by Vitalii Yevtushenko on 25.07.2019.
//  Copyright © 2019 Roll'n'Code. All rights reserved.
//

import Foundation

class TRSession {

    private var session: OpaquePointer

    deinit {
        tr_sessionClose(session)
    }

    fileprivate func sessionCallback(_ type: tr_rpc_callback_type, _ tor_or_null: OpaquePointer?) -> tr_rpc_callback_status {
        return TR_RPC_OK
    }

    let rpcCallback: tr_rpc_func = { session, type, torrent, userData in
        return TR_RPC_OK
    }

    init(configDir: String, settings: TRVariantDictionary, messageQueueingEnabled: Bool = false) throws {
        tr_formatter_size_init(1000, "kB", "MB", "GB", "TB")
        tr_formatter_speed_init(1000, "kB/s", "MB/s", "GB/s", "TB/s")
        tr_formatter_mem_init(1024, "kB", "MB", "GB", "TB")


        session = tr_sessionInit(configDir, messageQueueingEnabled.asUInt8, settings.pointer)

        tr_sessionSetRPCCallback(session, rpcCallback, nil)
    }

    static func getDefaultConfigDir(appName: String) -> String {
        return tr_getDefaultConfigDir(appName.asUnsafePointer).asString
    }

    static func getDefaultDownloadDir() -> String {
        return tr_getDefaultDownloadDir().asString
    }

    static func getDefaultSettings(_ dictionary: TRVariantDictionary) {
        tr_sessionGetDefaultSettings(dictionary.pointer)
    }

    func getSettings(_ dictionary: TRVariantDictionary) {
        tr_sessionGetSettings(session, dictionary.pointer)
    }

    static func loadSettings(from dictionary: TRVariantDictionary, configDir: String, appName: String) -> Bool {
        return tr_sessionLoadSettings(dictionary.pointer, configDir.asUnsafePointer, appName.asUnsafePointer).asBool
    }

    func saveSettings(mergingWith dictionary: TRVariantDictionary, configDir: String) {
        tr_sessionSaveSettings(session, configDir.asUnsafePointer, dictionary.pointer)
    }

    func set(settings: TRVariantDictionary) {
        tr_sessionSet(session, settings.pointer)
    }

    func reloadBlockLists() {
        tr_sessionReloadBlocklists(session)
    }

    var configDir: String {
        tr_sessionGetConfigDir(session).asString
    }

    var downloadDir: String {
        get {
            tr_sessionGetDownloadDir(session).asString
        }
        set {
            tr_sessionSetDownloadDir(session, newValue.asUnsafePointer)
        }
    }

    func getFreeSpace(forDirectory dir: String) -> Int64 {
        return tr_sessionGetDirFreeSpace(session, dir.asUnsafePointer)
    }

    // tr_ctorSetBandwidthPriority
    // tr_ctorGetBandwidthPriority

    var incompleteDir: String {
        get {
            tr_sessionGetIncompleteDir(session).asString
        }
        set {
            tr_sessionSetIncompleteDir(session, newValue.asUnsafePointer)
        }
    }

    var isIncompleteDirEnabled: Bool {
        get {
            tr_sessionIsIncompleteDirEnabled(session).asBool
        }
        set {
            tr_sessionSetIncompleteDirEnabled(session, newValue.asUInt8)
        }
    }

    var isIncompleteFileNamingEnabled: Bool {
        get {
            tr_sessionIsIncompleteFileNamingEnabled(session).asBool
        }
        set {
            tr_sessionSetIncompleteFileNamingEnabled(session, newValue.asUInt8)
        }
    }

    var isRPCEnabled: Bool {
        get {
            tr_sessionIsRPCEnabled(session).asBool
        }
        set {
            tr_sessionSetRPCEnabled(session, newValue.asUInt8)
        }
    }

    var rpcPort: Int {
        get {
            Int(tr_sessionGetRPCPort(session))
        }
        set {
            tr_sessionSetRPCPort(session, UInt16(newValue))
        }
    }

    var rpcURL: String {
        get {
            tr_sessionGetRPCUrl(session).asString
        }
        set {
            tr_sessionSetRPCUrl(session, newValue.asUnsafePointer)
        }
    }

    var rpcWhitelist: String {
        get {
            tr_sessionGetRPCWhitelist(session).asString
        }
        set {
            tr_sessionSetRPCWhitelist(session, newValue.asUnsafePointer)
        }
    }

    var isRPCWhitelistEnabled: Bool {
        get {
            tr_sessionGetRPCWhitelistEnabled(session).asBool
        }
        set {
            tr_sessionSetRPCWhitelistEnabled(session, newValue.asUInt8)
        }
    }

    var rpcUsername: String {
        get {
            tr_sessionGetRPCUsername(session).asString
        }
        set {
            tr_sessionSetRPCUsername(session, newValue.asUnsafePointer)
        }
    }

    var rpcPassword: String {
        get {
            tr_sessionGetRPCPassword(session).asString
        }
        set {
            tr_sessionSetRPCPassword(session, newValue.asUnsafePointer)
        }
    }

    var rpcPasswordEnabled: Bool {
        get {
            tr_sessionIsRPCPasswordEnabled(session).asBool
        }
        set {
            tr_sessionSetRPCPasswordEnabled(session, newValue.asUInt8)
        }
    }

    var rpcBindAddress: String {
        tr_sessionGetRPCBindAddress(session).asString
    }

}
