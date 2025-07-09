//
//  Collection+Extensions.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 08/07/25.
//

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
