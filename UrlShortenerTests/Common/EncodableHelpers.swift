//
//  EncodableHelpers.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 09/07/25.
//

import XCTest

enum EncodableHelpers {
    static func assertEqual<T: Encodable>(
        _ lhs: Data?,
        _ rhs: T,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        do {
            let rhs: Data? = try JSONEncoder().encode(rhs)

            assertEqual(lhs, rhs, file: file, line: line)
        } catch {
            XCTFail("\(error.localizedDescription)", file: file, line: line)
        }
    }

    static func assertEqual<T: Encodable>(
        _ lhs: T,
        _ rhs: Data?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        do {
            let lhs: Data? = try JSONEncoder().encode(lhs)

            assertEqual(lhs, rhs, file: file, line: line)
        } catch {
            XCTFail("\(error.localizedDescription)", file: file, line: line)
        }
    }

    static func assertEqual(
        _ lhs: Data?,
        _ rhs: Data?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch (lhs, rhs) {
        case (.none, .none):
            break
        case let (.some(lhsData), .some(rhsData)):
            do {
                let lhs = try toDictionary(lhsData)
                let rhs = try toDictionary(rhsData)
                try validateKeys(lhs, rhs)
            } catch {
                XCTFail("\(error.localizedDescription)", file: file, line: line)
            }
        default:
            XCTFail("One of the values is nil", file: file, line: line)
        }
    }

    static func toDictionary(_ data: Data) throws -> NSDictionary {
        let object = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
        if let data = object as? NSDictionary {
            return data
        }
        throw HelperError(errorDescription: "Invalid JSON format")
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
