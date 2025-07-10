//
//  ShortenedListCellTests.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 09/07/25.
//

import Foundation
@testable
import UrlShortener

final class ShortenedListCellTests: SnapshotTestCase {
    func testView() {
        let sut = ShortenedListCell()

        sut.setup(
            ShortenedUrlModel(
                id: UUID().uuidString,
                original: "https://www.linkedin.com/in/edyuto/",
                shortened: "https://url-shortener-server.onrender.com/api/alias/1544093959",
                date: Date(timeIntervalSince1970: 1752095756)
            )
        )

        verify(sut, size: CGSize(width: 402, height: 101))
    }
}
