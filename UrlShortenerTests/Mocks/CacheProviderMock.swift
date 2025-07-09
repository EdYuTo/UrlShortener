//
//  CacheProviderMock.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 08/07/25.
//

import CacheProvider

final class CacheProviderMock: AsyncCompletion, CacheProviderProtocol {
    private(set) var operationList = [CacheProviderOperation]()

    func get<T: Codable>(key: Key) async throws -> T {
        operationList.append(.get(key))
        return try await complete(with: T.self)
    }

    func set<T: Codable>(key: Key, value: T) async throws {
        operationList.append(.set(key, value))
        try await complete(with: Void.self)
    }

    func delete(key: Key) async throws {
        operationList.append(.delete(key))
        try await complete(with: Void.self)
    }
}

// MARK: - Equatable
enum CacheProviderOperation: Equatable {
    case get(CacheProviderProtocol.Key)
    case set(CacheProviderProtocol.Key, any Codable)
    case delete(CacheProviderProtocol.Key)

    static func == (lhs: CacheProviderOperation, rhs: CacheProviderOperation) -> Bool {
        do {
            switch (lhs, rhs) {
            case let (.get(lhsKey), .get(rhsKey)):
                return try EncodableHelpers.isEqual(lhsKey, rhsKey)
            case let (.set(lhsKey, lhsValue), .set(rhsKey, rhsValue)):
                let areKeysEqual = try EncodableHelpers.isEqual(lhsKey, rhsKey)
                let areValuesEqual = try EncodableHelpers.isEqual(lhsValue, rhsValue)
                return areKeysEqual && areValuesEqual
            case let (.delete(lhsKey), .delete(rhsKey)):
                return try EncodableHelpers.isEqual(lhsKey, rhsKey)
            default:
                return false
            }
        } catch {
            return false
        }
    }
}
