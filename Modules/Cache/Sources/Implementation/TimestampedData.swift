//
//  TimestampedData.swift
//  Cache
//
//  Created by Edson Yudi Toma.
//

import Foundation

public struct TimestampedData<T: Codable>: Codable {
    public let data: T
    public let timestamp: Date

    public init(data: T, timestamp: Date = Date()) {
        self.data = data
        self.timestamp = timestamp
    }
}
