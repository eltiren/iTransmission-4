//
//  Notifications.swift
//  iTransmission
//
//  Created by Vitalii Yevtushenko on 22.07.2019.
//

import Foundation

extension Notification.Name {
    struct iTransmission {
        static let newTorrentAdded = Notification.Name("NotificationNewTorrentAdded")
        static let activityCounterChanged = Notification.Name("NotificationActivityCounterChanged")
        static let torrentsRemoved = Notification.Name("NotificationTorrentsRemoved")
        static let networkInterfacesChanged = Notification.Name("NotificationNetworkInterfacesChanged")
        static let globalMessage = Notification.Name("NotificationGlobalMessage")
        static let sessionStatusChanged = Notification.Name("NotificationSessionStatusChanged")
    }
}
