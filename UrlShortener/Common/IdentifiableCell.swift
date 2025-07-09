//
//  IdentifiableCell.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 09/07/25.
//

protocol IdentifiableCell {}

extension IdentifiableCell {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}
