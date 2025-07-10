//
//  UIImage+Extensions.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 09/07/25.
//

import UIKit

extension UIImage {
    // https://stackoverflow.com/questions/27092354/rotating-uiimage-in-swift
    func rotated(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: size).applying(
            CGAffineTransform(rotationAngle: CGFloat(radians))
        ).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: CGFloat(radians))
        draw(
            in: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height)
        )

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage?.withRenderingMode(.alwaysTemplate)
    }
}
