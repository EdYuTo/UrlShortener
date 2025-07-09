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

enum CacheProviderOperation {
    case get(CacheProviderProtocol.Key)
    case set(CacheProviderProtocol.Key, Any)
    case delete(CacheProviderProtocol.Key)
}
