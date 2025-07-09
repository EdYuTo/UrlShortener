//
//  ShortenedListViewModelTests.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 08/07/25.
//

@testable
import UrlShortener
import NetworkProvider
import XCTest

final class ShortenedListViewModelTests: XCTestCase {
    func testShortenUrlRequest() async {
        let url = "https://www.linkedin.com/in/edyuto/"
        let response = makeResponse(url)

        let (sut, _, networkProvider) = makeSut()
        networkProvider.add(.success(response))

        await sut.shorten(url).value

        let request = networkProvider.requestList.first!
        XCTAssertEqual(request.endpoint, "https://url-shortener-server.onrender.com/api/alias")
        EncodableHelpers.assertEqual(
            request.body,
                """
                   {"url": "\(url)"}
                """.data(using: .utf8)
        )
        XCTAssertEqual(request.httpMethod, .post)
        XCTAssertNil(request.queryParams)
        XCTAssertEqual(
            NSDictionary(dictionary: request.headers!),
            NSDictionary(dictionary: ["Content-Type": "application/json"])
        )
    }

    func testShortenUrlSucceeds() async {
        let url = "https://www.linkedin.com/in/edyuto/"
        let response = makeResponse(url)

        let (sut, _, networkProvider) = makeSut()
        networkProvider.add(.success(response))

        sut.onUpdate = { state in
            if state != .success {
                XCTFail("Should yield success")
            }
        }

        await sut.shorten(url).value
    }

    func testShortenUrlFailsWithConnectionError() async {
        let url = "https://www.linkedin.com/in/edyuto/"
        let error = NetworkError.connection

        let (sut, _, networkProvider) = makeSut()
        networkProvider.add(.failure(error))

        sut.onUpdate = { state in
            if state != .connectionError {
                XCTFail("Should yield connection error")
            }
        }

        await sut.shorten(url).value
    }

    func testShortenUrlFailsWithGenericError() async {
        let url = "https://www.linkedin.com/in/edyuto/"
        let error = NSError(domain: "Generic", code: 500)

        let (sut, _, networkProvider) = makeSut()
        networkProvider.add(.failure(error))

        sut.onUpdate = { state in
            if state != .error {
                XCTFail("Should yield generic error")
            }
        }

        await sut.shorten(url).value
    }

    func testShortenUrlSucceedsAndAppendData() async {
        let url = "https://www.linkedin.com/in/edyuto/"
        let response = makeResponse(url)

        let (sut, _, networkProvider) = makeSut()
        networkProvider.add(.success(response))
        networkProvider.add(.success(response))

        await sut.shorten(url).value

        let model = sut.urlList.first!
        XCTAssertEqual(model.id, response.content.alias)
        XCTAssertEqual(model.original, response.content.links.original)
        XCTAssertEqual(model.shortened, response.content.links.shortened)
        XCTAssertLessThan(Date().timeIntervalSince(model.date), 1)
    }

    func testShortenUrlSucceedsAndAppendUniqueData() async {
        let url = "https://www.linkedin.com/in/edyuto/"
        let id = UUID()
        let response = makeResponse(url, shortenedId: id)

        let (sut, _, networkProvider) = makeSut()
        networkProvider.add(.success(response))
        networkProvider.add(.success(response))

        await sut.shorten(url).value
        await sut.shorten(url).value

        XCTAssertEqual(sut.urlList.count, 1)
        XCTAssertEqual(sut.urlList.count, 1)
    }

    func testShortenUrlSucceedsAndAppendRespectsLimits() async {
        let url = "https://www.linkedin.com/in/edyuto/"
        let limitCount = 2
        let responseList = (0...5).map { _ in makeResponse(url) }

        let (sut, _, networkProvider) = makeSut(historyLimitCount: limitCount)

        for response in responseList {
            networkProvider.add(.success(response))
            await sut.shorten(url).value
        }

        XCTAssertEqual(sut.urlList.count, limitCount)
    }
}

// MARK: - Helpers
private extension ShortenedListViewModelTests {
    func makeSut(
        historyLimitCount: Int = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (ShortenedListViewModelProtocol, CacheProviderMock, NetworkProviderMock) {
        let cacheProvider = CacheProviderMock()
        let networkProvider = NetworkProviderMock()
        let sut = ShortenedListViewModel(
            cacheProvider: cacheProvider,
            networkProvider: networkProvider,
            historyLimitCount: historyLimitCount
        )
        trackMemoryLeaks(cacheProvider, file: file, line: line)
        trackMemoryLeaks(networkProvider, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, cacheProvider, networkProvider)
    }

    func makeResponse(_ url: String, shortenedId: UUID = UUID()) -> NetworkResponse<ShortenUrlResponse> {
        .init(
            statusCode: 201,
            headers: [:],
            content: ShortenUrlResponse(
                alias: shortenedId.uuidString,
                links: ShortenUrlLinksResponse(
                    original: url,
                    shortened: "https://url-shortener-server.onrender.com/api/alias/1544093959"
                )
            )
        )
    }
}
