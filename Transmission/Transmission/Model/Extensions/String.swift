//
//  String.swift
//  Transmission
//
//  Created by Vitalii Yevtushenko on 26.07.2019.
//  Copyright © 2019 Roll'n'Code. All rights reserved.
//

import Foundation

extension String {
    var asUnsafePointer: UnsafePointer<Int8>! {
        return UnsafePointer<Int8>(cString(using: .utf8))
    }
}

extension UnsafePointer where Pointee == Int8 {
    var asString: String {
        return String(cString: self)
    }
}

extension BinaryInteger {
    var asBool: Bool {
        self != 0
    }
}
