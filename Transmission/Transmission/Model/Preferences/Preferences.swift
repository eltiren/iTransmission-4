//
//  Preferences.swift
//  Transmission
//
//  Created by Vitalii Yevtushenko on 25.07.2019.
//  Copyright © 2019 Roll'n'Code. All rights reserved.
//

import Foundation

typealias LogLevel = tr_log_level

protocol Preferences {
    var isSpeedLimitEnabled: Bool { get set }

    var isDownloadLimitEnabled: Bool { get set }
    var downloadLimit: Int { get set }

    var isUploadLimitEnabled: Bool { get set }
    var uploadLimit: Int { get set }

    var isBlockListEnabled: Bool { get set }
    var isDHTEnabled: Bool { get set }
    var isUTPEnabled: Bool { get set }
    var isLocalPeerDiscoveryEnabled: Bool { get set }

    var downloadFolder: String { get set }
    var incompleteFolder: String { get set }
    var isIncompleteFolderEnabled: Bool { get set }

    var logLevel: LogLevel { get set }

    var globalPeerLimit: Int { get set }
    var perTorrentPeerLimit: Int { get set }

    var useRandomPort: Bool { get set }
    var port: Int { get set }

    var peerSocketTOS: Int { get set }
    var isPEXEnabled: Bool { get set }
    var isPortForwardingEnabled: Bool { get set }

    var isRatioLimitEnabled: Bool { get set }
    var ratioLimit: Float { get set }

    var shouldRenamePartialFiles: Bool { get set }

    var isRpcAuthenticationRequired: Bool { get set }
    var isRpcEnabled: Bool { get set }
    var isRpcWhitelistEnabled: Bool { get set }
    var rpcPort: Int { get set }
    var rpcUsername: String { get set }
    var rpcPassword: String { get set }

    var shouldStartAddedTorrents: Bool { get set}
}

extension Preferences {

    /// You must free returned value using tr_variantFree
    func variantDict() -> TrVariantDict {
        let settings = TrVariantDict()
        settings.getDefaultSettings()

        settings[TR_KEY_alt_speed_enabled] = isSpeedLimitEnabled
        settings[TR_KEY_alt_speed_time_enabled] = false
        settings[TR_KEY_speed_limit_down_enabled] = isDownloadLimitEnabled
        settings[TR_KEY_speed_limit_down] = downloadLimit
        settings[TR_KEY_speed_limit_up_enabled] = isUploadLimitEnabled
        settings[TR_KEY_speed_limit_up] = uploadLimit

        settings[TR_KEY_blocklist_enabled] = isBlockListEnabled
        settings[TR_KEY_dht_enabled] = isDHTEnabled
        settings[TR_KEY_utp_enabled] = isUTPEnabled
        settings[TR_KEY_lpd_enabled] = isLocalPeerDiscoveryEnabled

        settings[TR_KEY_download_dir] = FileManager.default.containerSubPath(downloadFolder)
        settings[TR_KEY_incomplete_dir] = FileManager.default.containerSubPath(incompleteFolder)
        settings[TR_KEY_incomplete_dir_enabled] = isIncompleteFolderEnabled

        settings[TR_KEY_message_level] = logLevel

        settings[TR_KEY_peer_limit_global] = globalPeerLimit
        settings[TR_KEY_peer_limit_per_torrent] = perTorrentPeerLimit

        settings[TR_KEY_peer_port_random_on_start] = useRandomPort

        if !useRandomPort {
            settings[TR_KEY_peer_port] = port
        }

        settings[TR_KEY_peer_socket_tos] = peerSocketTOS
        settings[TR_KEY_pex_enabled] = isPEXEnabled
        settings[TR_KEY_port_forwarding_enabled] = isPortForwardingEnabled

        settings[TR_KEY_rename_partial_files] = shouldRenamePartialFiles

        settings[TR_KEY_rpc_authentication_required] = isRpcAuthenticationRequired
        settings[TR_KEY_rpc_enabled] = isRpcEnabled
        settings[TR_KEY_rpc_whitelist_enabled] = isRpcWhitelistEnabled
        settings[TR_KEY_rpc_port] = rpcPort
        settings[TR_KEY_rpc_username] = rpcUsername
        settings[TR_KEY_rpc_password] = rpcPassword

        settings[TR_KEY_start_added_torrents] = shouldStartAddedTorrents

        return settings
    }
}
