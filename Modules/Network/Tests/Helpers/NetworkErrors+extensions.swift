//
//  NetworkErrors+extensions.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma.
//

import Foundation
import NetworkProvider

extension NetworkError {
    init?(error: NSError) {
        guard error.domain == "MoviesSampleApp.NetworkError" else { return nil }
        switch error.code {
        case 0:
            self = .connection
        case 1:
            self = .decoding(description: String(), statusCode: -1)
        case 2:
            self = .invalidParams
        case 3:
            self = .invalidResponse
        case 4:
            self = .invalidUrl
        default:
            return nil
        }
    }
}
