//
//  CacheDebugDecorator.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 07/08/25.
//

import CacheProvider
import DebugLoggerProvider
import Foundation

final class CacheDebugDecorator: CacheProviderProtocol {
    private let logger = DebugLogger(subsystem: "Cache", category: "Queries")
    private let provider: CacheProviderProtocol

    init(provider: CacheProviderProtocol) {
        self.provider = provider
    }

    func get<T: Codable>(key: Key) async throws -> T {
        do {
            let data: T = try await provider.get(key: key)
            logger.logInfo(
                logMessage(),
                args: "Get",
                JsonHelpers.prettyPrintedString(from: key),
                JsonHelpers.prettyPrintedString(from: data)
            )
            return data
        } catch {
            logger.logError(
                logMessage(),
                args: "Get",
                JsonHelpers.prettyPrintedString(from: key),
                errorDescription(error)
            )
            throw error
        }
    }

    func set<T: Codable>(key: Key, value: T) async throws {
        do {
            try await provider.set(key: key, value: value)
            logger.logInfo(
                logMessage(),
                args: "Set",
                JsonHelpers.prettyPrintedString(from: key),
                JsonHelpers.prettyPrintedString(from: value)
            )
        } catch {
            logger.logError(
                logMessage(),
                args: "Set",
                JsonHelpers.prettyPrintedString(from: key),
                errorDescription(error)
            )
            throw error
        }
    }

    func delete(key: Key) async throws {
        do {
            try await provider.delete(key: key)
            logger.logInfo(
                logMessage(),
                args: "Delete",
                JsonHelpers.prettyPrintedString(from: key),
                JsonHelpers.prettyPrintedString(from: [:])
            )
        } catch {
            logger.logError(
                logMessage(),
                args: "Delete",
                JsonHelpers.prettyPrintedString(from: key),
                errorDescription(error)
            )
            throw error
        }
    }
}

// MARK: - Helpers
private extension CacheDebugDecorator {
    func logMessage() -> String {
        """
        ----------------------
        %@ [Key]
        %@
        ----------------------
        [Data]
        %@
        ----------------------
        """
    }

    func errorDescription(_ error: Error) -> String {
        String(describing: error)
    }
}
