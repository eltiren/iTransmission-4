//
//  Bool.swift
//  Transmission
//
//  Created by Vitalii Yevtushenko on 25.07.2019.
//  Copyright © 2019 Roll'n'Code. All rights reserved.
//

import Foundation

extension Bool {
    var asUInt8: UInt8 {
        self ? 1 : 0
    }
}
