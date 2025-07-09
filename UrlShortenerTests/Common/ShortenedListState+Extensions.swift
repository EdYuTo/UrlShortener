//
//  ShortenedListState+Extensions.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 09/07/25.
//

@testable
import UrlShortener

extension ShortenedListState: @retroactive Equatable {
    public static func == (lhs: ShortenedListState, rhs: ShortenedListState) -> Bool {
        switch (lhs, rhs) {
        case (.error, .error),
            (.connectionError, .connectionError),
            (.loading, .loading),
            (.success, .success):
            return true
        default:
            return false
        }
    }

    static var error: Self {
        .error(.init(title: "", buttonTitle: ""))
    }

    static var connectionError: Self {
        .connectionError(.init(title: "", buttonTitle: ""))
    }
}

