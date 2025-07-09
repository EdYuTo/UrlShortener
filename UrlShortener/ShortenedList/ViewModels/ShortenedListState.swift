//
//  ShortenedListState.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 08/07/25.
//

enum ShortenedListState {
    case error(AlertModel)
    case connectionError(AlertModel)
    case loading
    case success
}
