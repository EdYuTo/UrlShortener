//
//  Localizable.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 09/07/25.
//

import Foundation

// MARK: - Keys
enum Localizable: String {
    case shortenedListTitle
    case connectionErrorTitle
    case connectionErrorDescription
    case connectionErrorButtonTitle
    case genericErrorTitle
    case genericErrorButtonTitle
    case originalUrlAlertTitle
    case originalUrlAlertButtonTitle
}

// MARK: - Bundle locator
private extension Localizable {
    class MainBundle {}

    var bundle: Bundle {
        Bundle(for: MainBundle.self)
    }
}

// MARK: - Localization
extension Localizable {
    var localized: String {
        NSLocalizedString(rawValue, bundle: bundle, comment: String())
    }

    func localized(with arguments: CVarArg...) -> String {
        String(format: localized, arguments)
    }
}
