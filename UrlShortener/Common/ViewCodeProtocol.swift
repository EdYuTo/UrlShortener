//
//  ViewCodeProtocol.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 09/07/25.
//

protocol ViewCodeProtocol {
    func setupView()
    func setupHierarchy()
    func setupConstraints()
    func setupConfigurations()
    func setupAccessibility()
}

// MARK: - Default values
extension ViewCodeProtocol {
    func setupView() {
        setupHierarchy()
        setupConstraints()
        setupConfigurations()
        setupAccessibility()
    }

    func setupConfigurations() { /* Optional */ }

    func setupAccessibility() { /* Optional */ }
}
