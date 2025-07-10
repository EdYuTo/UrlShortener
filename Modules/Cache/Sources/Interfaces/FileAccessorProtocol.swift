//
//  FileAccessorProtocol.swift
//  Cache
//
//  Created by Edson Yudi Toma.
//

import Foundation

public protocol FileAccessorProtocol {
    func get() async throws -> Data
    func set(_ data: Data) async throws
    func delete() async throws
}
