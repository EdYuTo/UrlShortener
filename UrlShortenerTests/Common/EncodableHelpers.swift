//
//  EncodableHelpers.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 09/07/25.
//

import XCTest

// MARK: - Namespace
enum EncodableHelpers {}

// MARK: - Conversions
extension EncodableHelpers {
    static func toData<T: Encodable>(_ encodable: T) throws -> Data {
        try JSONEncoder().encode(encodable)
    }

    static func toDictionary(_ data: Data) throws -> NSDictionary {
        let object = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
        if let data = object as? NSDictionary {
            return data
        }
        throw HelperError(errorDescription: "Invalid JSON format")
    }
}

// MARK: Equality
extension EncodableHelpers {
    static func isEqual<T: Encodable, U: Encodable>(
        _ lhs: T,
        _ rhs: U
    ) throws -> Bool {
        try isEqual(try toData(lhs), try toData(rhs))
    }

    static func isEqual<T: Encodable>(
        _ lhs: Data?,
        _ rhs: T
    ) throws -> Bool {
        try isEqual(lhs, toData(rhs))
    }

    static func isEqual<T: Encodable>(
        _ lhs: T,
        _ rhs: Data?,
    ) throws -> Bool {
        try isEqual(toData(lhs), rhs)
    }

    static func isEqual(
        _ lhs: Data?,
        _ rhs: Data?
    ) throws -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.some(lhsData), .some(rhsData)):
            let lhs = try toDictionary(lhsData)
            let rhs = try toDictionary(rhsData)
            try validateKeys(lhs, rhs)
            return true
        default:
            return false
        }
    }
}

// MARK: - Assertions
extension EncodableHelpers {
    static func assertEqual<T: Encodable, U: Encodable>(
        _ lhs: T,
        _ rhs: U,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertEqual(try isEqual(lhs, rhs), file: file, line: line)
    }

    static func assertEqual<T: Encodable>(
        _ lhs: Data?,
        _ rhs: T,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertEqual(try isEqual(lhs, rhs), file: file, line: line)
    }

    static func assertEqual<T: Encodable>(
        _ lhs: T,
        _ rhs: Data?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertEqual(try isEqual(lhs, rhs), file: file, line: line)
    }

    static func assertEqual(
        _ lhs: Data?,
        _ rhs: Data?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertEqual(try isEqual(lhs, rhs), file: file, line: line)
    }

    static func assertEqual(
        _ expression: @autoclosure () throws -> Bool,
        file: StaticString,
        line: UInt
    ) {
        do {
            guard try expression() else {
                return XCTFail("One of the values is nil", file: file, line: line)
            }
        } catch {
            XCTFail("\(error.localizedDescription)", file: file, line: line)
        }
    }
}

// MARK: - Helpers
private extension EncodableHelpers {
    struct HelperError: LocalizedError {
        let errorDescription: String?
    }

    static func validateKeys(_ lhs: NSDictionary, _ rhs: NSDictionary, path: String = "") throws {
        let allKeys = NSSet(array: lhs.allKeys)
        rhs.allKeys.forEach { allKeys.adding($0) }

        for key in allKeys {
            let currentPath = path.isEmpty ? "\(key)" : "\(path).\(key)"
            let lhsData = lhs[key]
            let rhsData = rhs[key]

            switch (lhsData, rhsData) {
            case let (lhs as NSDictionary, rhs as NSDictionary):
                try validateKeys(lhs, rhs, path: currentPath)
            case (.none, _), (_, .none):
                throw HelperError(errorDescription: "Missing key <\(currentPath)>")
            default:
                if "\(String(describing: lhsData))" != "\(String(describing: rhsData))" {
                    throw HelperError(errorDescription: "Data for key <\(currentPath)> is different")
                }
            }
        }
    }
}
