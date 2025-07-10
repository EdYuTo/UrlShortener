//
//  NetworkErrors.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma.
//

public enum NetworkError: Error {
    case connection
    case decoding(description: String, statusCode: Int)
    case invalidParams
    case invalidResponse
    case invalidUrl
}

enum ConnectionError: Int {
    case timeout = -1001
    case cannotConnectToHost = -1004
    case connectionLost = -1005
    case unreachable = -1009
}
