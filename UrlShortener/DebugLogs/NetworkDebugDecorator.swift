//
//  NetworkDebugLogger.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 07/08/25.
//

import DebugLoggerProvider
import NetworkProvider
import Foundation

final class NetworkDebugDecorator: NetworkProviderProtocol {
    private let logger = DebugLogger(subsystem: "Network", category: "Requests")
    private let provider: NetworkProviderProtocol

    init(provider: NetworkProviderProtocol) {
        self.provider = provider
    }

    func makeRequest<T: Decodable>(_ request: NetworkRequestProtocol) async throws -> NetworkResponse<T> {
        do {
            let response: NetworkResponse<T> = try await provider.makeRequest(request)
            logger.logInfo(logMessage(), args: requestDescription(request), responseDescription(response))
            return response
        } catch {
            logger.logError(logMessage(), args: requestDescription(request), errorDescription(error))
            throw error
        }
    }

    func makeRequest(_ request: NetworkRequestProtocol) async throws -> NetworkResponse<Data> {
        do {
            let response = try await provider.makeRequest(request)
            logger.logInfo(logMessage(), args: requestDescription(request), responseDescription(response))
            return response
        } catch {
            logger.logError(logMessage(), args: requestDescription(request), errorDescription(error))
            throw error
        }
    }
}

// MARK: - Helpers
private extension NetworkDebugDecorator {
    func logMessage() -> String {
        """
        ----------------------
        [Request]
        %@
        ----------------------
        [Response]
        %@
        ----------------------
        """
    }

    func requestDescription(_ request: NetworkRequestProtocol) -> String {
        """
        * Endpoint: \(request.endpoint)
        * Http method: \(request.httpMethod.rawValue)
        * Body: \(JsonHelpers.prettyPrintedString(from: request.body))
        * Headers: \(JsonHelpers.prettyPrintedString(from: request.headers))
        * Query params: \(JsonHelpers.prettyPrintedString(from: request.queryParams))
        """
    }

    func responseDescription<T>(_ response: NetworkResponse<T>) -> String {
        """
        * Status code: \(response.statusCode)
        * Headers: \(JsonHelpers.prettyPrintedString(from: response.headers))
        * Content: \(contentDescription(response.content))
        """
    }

    func errorDescription(_ error: Error) -> String {
        String(describing: error)
    }

    func contentDescription<T>(_ content: T) -> String {
        if let content = content as? Data {
            JsonHelpers.prettyPrintedString(from: content)
        } else {
            String(describing: content)
        }
    }
}
