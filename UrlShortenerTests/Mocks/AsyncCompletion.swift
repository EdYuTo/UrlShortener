//
//  AsyncCompletion.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 08/07/25.
//

import Foundation

class AsyncCompletion {
    private var completionList = [Result<Any, Error>]()

    func complete<T>(with type: T.Type) async throws -> T {
        guard completionList.count > 0 else {
            throw NSError(domain: "Add a completion result first", code: 404)
        }
        switch completionList.removeFirst() {
        case let .success(value):
            if let value = value as? T {
                return value
            } else {
                throw NSError(domain: "Cannot cast \(value) to \(type)", code: 500)
            }
        case let .failure(error):
            throw error
        }
    }

    func add(_ completion: Result<Any, Error>) {
        completionList.append(completion)
    }
}
