//
//  UserDefaultsPreferences.swift
//  Transmission
//
//  Created by Vitalii Yevtushenko on 25.07.2019.
//  Copyright © 2019 Roll'n'Code. All rights reserved.
//

import Foundation

final class UserDefaultsPreferences: Preferences {
    @UserDefault("speed_limit_enabled", default: true)      var isSpeedLimitEnabled: Bool
    @UserDefault("download_limit_enabled", default: false)  var isDownloadLimitEnabled: Bool
    @UserDefault("download_limit", default: 0)              var downloadLimit: Int
    @UserDefault("upload_limit_enabled", default: false)    var isUploadLimitEnabled: Bool
    @UserDefault("upload_limit", default: 0)                var uploadLimit: Int
    @UserDefault("block_list_enabled", default: true)       var isBlockListEnabled: Bool
    @UserDefault("dht_enabled", default: true)              var isDHTEnabled: Bool
    @UserDefault("utp_enabled", default: true)              var isUTPEnabled: Bool
    @UserDefault("lpd_enabled", default: true)              var isLocalPeerDiscoveryEnabled: Bool
    @UserDefault("download_path", default: "downloads")     var downloadFolder: String
    @UserDefault("incomplete_path", default: "incomplete")  var incompleteFolder: String
    @UserDefault("incomplete_enabled", default: true)      var isIncompleteFolderEnabled: Bool
    @UserDefault("log_level", default: TR_LOG_DEBUG)        var logLevel: LogLevel
    @UserDefault("global_peer_limit", default: 30)          var globalPeerLimit: Int
    @UserDefault("per_torrent_peer_limit", default: 20)     var perTorrentPeerLimit: Int
    @UserDefault("use_random_port", default: false)         var useRandomPort: Bool
    @UserDefault("port", default: 30901)                    var port: Int
    @UserDefault("peer_socket_tos", default: 0)             var peerSocketTOS: Int
    @UserDefault("pex_enabled", default: true)              var isPEXEnabled: Bool
    @UserDefault("port_forwarding_enabled", default: true)  var isPortForwardingEnabled: Bool
    @UserDefault("ratio_limit_enabled", default: false)     var isRatioLimitEnabled: Bool
    @UserDefault("ratio_limit", default: 0)                 var ratioLimit: Float
    @UserDefault("rename_partial_files", default: true)     var shouldRenamePartialFiles: Bool
    @UserDefault("rpc_auth_required", default: false)       var isRpcAuthenticationRequired: Bool
    @UserDefault("rpc_enabled", default: false)             var isRpcEnabled: Bool
    @UserDefault("rpc_whitelist_enabled", default: false)   var isRpcWhitelistEnabled: Bool
    @UserDefault("rpc_port", default: 9091)                 var rpcPort: Int
    @UserDefault("rpc_username", default: "")               var rpcUsername: String
    @UserDefault("rpc_password", default: "")               var rpcPassword: String
    @UserDefault("auto_start_download", default: true)      var shouldStartAddedTorrents: Bool
}
