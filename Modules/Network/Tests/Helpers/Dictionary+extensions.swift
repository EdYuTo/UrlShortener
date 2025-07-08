//
//  Dictionary+extensions.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma.
//

import Foundation

extension Dictionary {
    func toNSDictionary() -> NSDictionary {
        return NSDictionary(dictionary: self)
    }
}
