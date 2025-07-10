//
//  Encodable+CacheKey.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma.
//

import CryptoKit
import Foundation

extension Encodable {
    var cacheKey: String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
