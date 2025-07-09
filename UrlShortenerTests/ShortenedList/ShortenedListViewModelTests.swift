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
    // MARK: - Remote
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

    // MARK: - Cache
    func testCacheShouldFetchWithCorrectKey() async {
        let (sut, cacheProvider, _) = makeSut()

        await sut.loadHistory().value

        XCTAssertEqual(cacheProvider.operationList, [.get("ShortenedUrlHistory")])
    }

    func testEmptyCacheShouldYieldEmptyData() async {
        let (sut, cacheProvider, _) = makeSut()

        cacheProvider.add(.success([ShortenedUrlStorage]()))
        await sut.loadHistory().value

        XCTAssertEqual(sut.urlList.count, 0)
    }

    func testNilCacheShouldYieldEmptyData() async {
        let (sut, _, _) = makeSut()

        await sut.loadHistory().value

        XCTAssertEqual(sut.urlList.count, 0)
    }

    func testCacheShouldYieldDomainModel() async {
        let cacheModel = makeCacheModel()
        let (sut, cacheProvider, _) = makeSut()

        cacheProvider.add(.success([cacheModel]))
        await sut.loadHistory().value

        XCTAssertEqual(sut.urlList.count, 1)

        let model = sut.urlList.first!
        XCTAssertEqual(model.id, cacheModel.id)
        XCTAssertEqual(model.original, cacheModel.original)
        XCTAssertEqual(model.shortened, cacheModel.shortened)
        XCTAssertLessThan(model.date.timeIntervalSince(cacheModel.date), 1)
    }

    func testCacheSucceedsAndAppendRespectsLimits() async {
        let limitCount = 2
        let cacheList = (0...5).map { _ in makeCacheModel() }

        let (sut, cacheProvider, _) = makeSut(historyLimitCount: limitCount)

        cacheProvider.add(.success(cacheList))
        await sut.loadHistory().value

        XCTAssertEqual(sut.urlList.count, limitCount)
    }

    // MARK: - Remote & cache
    func testShortenUrlRequestShouldSaveOnCacheWhenSucceeds() async {
        let url = "https://www.linkedin.com/in/edyuto/"
        let response = makeResponse(url)
        let (sut, cacheProvider, networkProvider) = makeSut()
        
        networkProvider.add(.success(response))

        sut.onUpdate = { state in
            if state != .success {
                XCTFail("Should yield success")
            }
        }

        await sut.shorten(url).value

        if case let .set(key as String, cacheModelList as [ShortenedUrlStorage]) = cacheProvider.operationList.first,
           let cacheModel = cacheModelList.first {
            XCTAssertEqual(cacheModel.id, response.content.alias)
            XCTAssertEqual(cacheModel.original, response.content.links.original)
            XCTAssertEqual(cacheModel.shortened, response.content.links.shortened)
            XCTAssertLessThan(Date().timeIntervalSince(cacheModel.date), 1)
            XCTAssertEqual(key, "ShortenedUrlHistory")
        } else {
            XCTFail("Should've saved remote model to cache")
        }
    }

    // MARK: - Localization
    func testTitleLocalization() {
        let (sut, _, _) = makeSut()

        let expectedTitle = [
            "en": "Recently shortened URLs",
            "pt-BR": "URLs encurtadas recentemente"
        ]

        let bundle = Bundle(for: UrlShortener.self)
        addTeardownBlock {
            bundle.unsetLocalizedLanguage()
        }

        for (language, expectedTitle) in expectedTitle {
            bundle.setLocalizedLanguage(to: language)
            let title = sut.viewTitle
            XCTAssertEqual(title, expectedTitle, "Expected \(title) to be \(expectedTitle) in \(language)")
        }
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

    func makeCacheModel(
        _ url: String = "https://www.linkedin.com/in/edyuto/",
        shortenedId: UUID = UUID()
    ) -> ShortenedUrlStorage {
        ShortenedUrlStorage(
            id: shortenedId.uuidString,
            original: url,
            shortened: "https://url-shortener-server.onrender.com/api/alias/1544093959",
            date: Date()
        )
    }
}
