//
//  CacheErrors.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma.
//

public enum CacheError: Error {
    case notFound(key: CacheProviderProtocol.Key)
    case decodingError(description: String)
    case encodingError(description: String)
    case unknown(description: String)
    case expired
    case invalidKey
}
