//
//  ShortenedUrlModel.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 09/07/25.
//

import Foundation

struct ShortenedUrlModel {
    let id: String
    let original: String
    let shortened: String
    let date: Date
}

// MARK: - Hashable
extension ShortenedUrlModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
