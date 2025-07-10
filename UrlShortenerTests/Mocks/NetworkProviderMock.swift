//
//  NetworkProviderMock.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 08/07/25.
//

import Foundation
import NetworkProvider

final class NetworkProviderMock: AsyncCompletion, NetworkProviderProtocol {
    private(set) var requestList = [NetworkRequestProtocol]()

    func makeRequest<T: Decodable>(_ request: NetworkRequestProtocol) async throws -> NetworkResponse<T> {
        requestList.append(request)
        return try await complete(with: NetworkResponse<T>.self)
    }

    func makeRequest(_ request: NetworkRequestProtocol) async throws -> NetworkResponse<Data> {
        requestList.append(request)
        return try await complete(with: NetworkResponse<Data>.self)
    }
}
