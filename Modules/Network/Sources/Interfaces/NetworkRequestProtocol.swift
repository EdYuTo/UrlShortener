//
//  NetworkRequestProtocol.swift
//  Network
//
//  Created by Edson Yudi Toma on 08/07/25.
//

import Foundation

public protocol NetworkRequestProtocol {
    var endpoint: String { get }
    var body: Data? { get }
    var httpMethod: HTTPMethod { get }
    var queryParams: [String: String]? { get }
    var headers: [String: String]? { get }
    var decoder: JSONDecoder { get }
}
