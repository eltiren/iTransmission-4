//
//  TRVariantDictionary.swift
//  Transmission
//
//  Created by Vitalii Yevtushenko on 26.07.2019.
//  Copyright © 2019 Roll'n'Code. All rights reserved.
//

import Foundation

class TRVariantDictionary: TRVariant {
    override init() {
        super.init()
        tr_variantInitDict(pointer, 0)
    }
}

extension TRVariantDictionary {
    subscript(key: Int) -> Int {
        get {
            var value: Int64 = 0
            tr_variantDictFindInt(pointer, key, &value)
            return Int(value)
        }
        set {
            tr_variantDictAddInt(pointer, key, Int64(newValue))
        }
    }

    subscript(key: Int) -> Float {
        get {
            var value: Double = 0
            tr_variantDictFindReal(pointer, key, &value)
            return Float(value)
        }
        set {
            tr_variantDictAddReal(pointer, key, Double(newValue))
        }
    }

    subscript(key: Int) -> tr_log_level {
        get {
            var value: Int64 = 0
            tr_variantDictFindInt(pointer, key, &value)
            return tr_log_level(rawValue: UInt32(value))
        }
        set {
            tr_variantDictAddInt(pointer, key, Int64(newValue.rawValue))
        }
    }

    subscript(key: Int) -> Bool {
        get {
            var value: UInt8 = 0
            tr_variantDictFindBool(pointer, key, &value)
            return (value != 0)
        }
        set {
            tr_variantDictAddBool(pointer, key, newValue.asUInt8)
        }
    }

    subscript(key: Int) -> String {
        get {
            var value: [CChar] = [CChar](repeating: 0, count: 2048)
            var len: Int = 2048
            var pointer: UnsafePointer<Int8>? = UnsafePointer<CChar>(&value)
            tr_variantDictFindStr(self.pointer, key, &pointer, &len)
            return (String(cString: pointer!))
        }
        set {
            tr_variantDictAddStr(pointer, key, newValue.cString(using: .utf8)!)
        }
    }
}
