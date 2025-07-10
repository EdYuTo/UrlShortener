//
//  NetworkResponse.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma.
//

public struct NetworkResponse<T> {
    public let statusCode: Int
    public let headers: [AnyHashable: Any]
    public let content: T

    public init(statusCode: Int, headers: [AnyHashable: Any], content: T) {
        self.statusCode = statusCode
        self.headers = headers
        self.content = content
    }
}
