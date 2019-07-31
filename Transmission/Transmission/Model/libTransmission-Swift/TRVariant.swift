//
//  TRVariant.swift
//  Transmission
//
//  Created by Vitalii Yevtushenko on 26.07.2019.
//  Copyright © 2019 Roll'n'Code. All rights reserved.
//

import Foundation

class TRVariant {

    enum Error: Swift.Error {
        case cantWriteToFile(String, Format)
    }

    enum Format {
        case benc
        case json
        case jsonLean
    }

    private var rawValue: tr_variant

    var pointer: UnsafeMutablePointer<tr_variant> {
        return UnsafeMutablePointer(&rawValue)
    }

    init() {
        rawValue = tr_variant()
    }

    deinit {
        tr_variantFree(&rawValue)
    }

    func writeToFile(atPath path: String, format: Format) throws {
        if !tr_variantToFile(&rawValue, format.fmt, path.asUnsafePointer).asBool {
            throw Error.cantWriteToFile(path, format)
        }
    }
}

fileprivate extension TRVariant.Format {
    var fmt: tr_variant_fmt {
        switch self {
        case .benc:
            return TR_VARIANT_FMT_BENC
        case .json:
            return TR_VARIANT_FMT_JSON
        case .jsonLean:
            return TR_VARIANT_FMT_JSON_LEAN
        }
    }
}
