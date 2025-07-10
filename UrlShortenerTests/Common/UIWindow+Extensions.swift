//
//  UIWindow+Extensions.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 09/07/25.
//

import UIKit

extension UIWindow {
    func takeSnapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        return renderer.image { action in
            layer.render(in: action.cgContext)
        }
    }
}
