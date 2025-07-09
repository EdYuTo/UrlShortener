//
//  ShortenUrlRequest.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 08/07/25.
//

import Foundation
import NetworkProvider

struct ShortenUrlRequest: Encodable {
    let url: String

    enum CodingKeys: CodingKey {
        case url
    }
}

extension ShortenUrlRequest: NetworkRequestProtocol {
    var endpoint: String {
        "https://url-shortener-server.onrender.com/api/alias"
    }
    var body: Data? {
        try? JSONEncoder().encode(self)
    }
    var httpMethod: HTTPMethod { .post }
    var queryParams: [String: String]? { nil }
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
    var decoder: JSONDecoder { JSONDecoder() }
}
