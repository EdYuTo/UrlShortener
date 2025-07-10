//
//  FileAccessor.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma.
//

import Foundation

public actor FileAccessor {
    private let fileUrl: URL

    public init(fileUrl: URL) {
        self.fileUrl = fileUrl
    }
}

// MARK: - FileAccessorProtocol
extension FileAccessor: FileAccessorProtocol {
    public func get() async throws -> Data {
        try Data(contentsOf: fileUrl)
    }

    public func set(_ data: Data) async throws {
        try data.write(to: fileUrl)
    }

    public func delete() async throws {
        try FileManager.default.removeItem(at: fileUrl)
    }
}
