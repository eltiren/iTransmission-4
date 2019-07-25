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

    init(preferences: Preferences) {
        let settings = preferences.variantDict()

        tr_formatter_size_init(1000, "kB", "MB", "GB", "TB")
        tr_formatter_speed_init(1000, "kB/s", "MB/s", "GB/s", "TB/s")
        tr_formatter_mem_init(1024, "kB", "MB", "GB", "TB")

        session = tr_sessionInit(FileManager.default.configPath(), true.asUInt8, &settings.dict)

        print(session)
    }
}
