//
//  ShortenedUrlStorage.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 09/07/25.
//

import Foundation

struct ShortenedUrlStorage: Codable {
    static let key = "ShortenedUrlHistory"

    let id: String
    let original: String
    let shortened: String
    let date: Date
}
