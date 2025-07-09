//
//  ShortenUrlResponse.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 08/07/25.
//

struct ShortenUrlResponse: Decodable {
    let alias: String
    let links: ShortenUrlLinksResponse

    enum CodingKeys: String, CodingKey {
        case alias
        case links = "_links"
    }
}

struct ShortenUrlLinksResponse: Decodable {
    let original: String
    let shortened: String

    enum CodingKeys: String, CodingKey {
        case original = "self"
        case shortened = "short"
    }
}
