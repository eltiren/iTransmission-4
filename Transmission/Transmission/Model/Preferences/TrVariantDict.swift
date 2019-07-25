//
//  TrVariantDict.swift
//  Transmission
//
//  Created by Vitalii Yevtushenko on 25.07.2019.
//  Copyright © 2019 Roll'n'Code. All rights reserved.
//

import Foundation

final class TrVariantDict {
    var dict = tr_variant()

    init() {
        tr_variantInitDict(&dict, 0)
    }

    func getDefaultSettings() {
        tr_sessionGetDefaultSettings(&dict)
    }

    subscript(key: Int) -> Int {
        get {
            var value: Int64 = 0
            tr_variantDictFindInt(&dict, key, &value)
            return Int(value)
        }
        set {
            tr_variantDictAddInt(&dict, key, Int64(newValue))
        }
    }

    subscript(key: Int) -> Float {
        get {
            var value: Double = 0
            tr_variantDictFindReal(&dict, key, &value)
            return Float(value)
        }
        set {
            tr_variantDictAddReal(&dict, key, Double(newValue))
        }
    }

    subscript(key: Int) -> tr_log_level {
        get {
            var value: Int64 = 0
            tr_variantDictFindInt(&dict, key, &value)
            return tr_log_level(rawValue: UInt32(value))
        }
        set {
            tr_variantDictAddInt(&dict, key, Int64(newValue.rawValue))
        }
    }

    subscript(key: Int) -> Bool {
        get {
            var value: UInt8 = 0
            tr_variantDictFindBool(&dict, key, &value)
            return (value != 0)
        }
        set {
            tr_variantDictAddBool(&dict, key, newValue.asUInt8)
        }
    }

    subscript(key: Int) -> String {
        get {
            var value: [CChar] = [CChar](repeating: 0, count: 2048)
            var len: Int = 2048
            var pointer: UnsafePointer<Int8>? = UnsafePointer<CChar>(&value)
            tr_variantDictFindStr(&dict, key, &pointer, &len)
            return (String(cString: pointer!))
        }
        set {
            tr_variantDictAddStr(&dict, key, newValue.cString(using: .utf8)!)
        }
    }

    deinit {
        tr_variantFree(&dict)
    }
}
