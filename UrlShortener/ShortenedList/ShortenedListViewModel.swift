//
//  ShortenedListViewModel.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 08/07/25.
//

import CacheProvider
import Foundation
import NetworkProvider

protocol ShortenedListViewModelProtocol: AnyObject {
    typealias Observer<T> = (T) -> Void

    @discardableResult
    func shorten(_ url: String) -> Task<Void, Never>
    @discardableResult
    func loadHistory() -> Task<Void, Never>

    var onUpdate: Observer<ShortenedListState>? { get set }
    var urlList: [ShortenedUrlModel] { get }
    var historyLimitCount: Int { get }
}

final class ShortenedListViewModel {
    private let cacheProvider: CacheProviderProtocol
    private let networkProvider: NetworkProviderProtocol

    var onUpdate: Observer<ShortenedListState>?
    var urlList: [ShortenedUrlModel] = []
    var historyLimitCount: Int

    init(
        cacheProvider: CacheProviderProtocol,
        networkProvider: NetworkProviderProtocol,
        historyLimitCount: Int = 10
    ) {
        self.cacheProvider = cacheProvider
        self.networkProvider = networkProvider
        self.historyLimitCount = historyLimitCount
    }
}

// MARK: - ShortenedListViewModelProtocol
extension ShortenedListViewModel: ShortenedListViewModelProtocol {
    @discardableResult
    func shorten(_ url: String) -> Task<Void, Never> {
        let request = ShortenUrlRequest(url: url)
        return Task { [weak self] in
            guard let self else { return }
            do {
                let response: NetworkResponse<ShortenUrlResponse> = try await networkProvider.makeRequest(request)
                // Ideally we could use a NSOrderedSet for bigger datasets
                insertUnique(mapRemoteToDomain(response.content))
                clipUrlListToHistoryLimitCount()
                await self.updateOnMainThread(.success)
            } catch {
                if let error = error as? NetworkError, case .connection = error {
                    await self.updateOnMainThread(.connectionError)
                } else {
                    await self.updateOnMainThread(.error)
                }
            }
        }
    }

    @discardableResult
    func loadHistory() -> Task<Void, Never> {
        Task {
            let history: String? = try? await cacheProvider.get(key: "")
            sortUrlList()
        }
    }
}

// MARK: - Helpers
private extension ShortenedListViewModel {
    func updateOnMainThread(_ state: ShortenedListState) async {
        await MainActor.run { [weak self] in
            guard let self else { return }
            self.onUpdate?(state)
        }
    }

    func mapRemoteToDomain(_ remote: ShortenUrlResponse) -> ShortenedUrlModel {
        ShortenedUrlModel(
            id: remote.alias,
            original: remote.links.original,
            shortened: remote.links.shortened,
            date: Date()
        )
    }

    func insertUnique(_ model: ShortenedUrlModel) {
        urlList = urlList.filter { $0.id != model.id }
        urlList.insert(model, at: 0)
    }

    func sortUrlList() {
        urlList.sort { $0.date > $1.date }
    }

    func clipUrlListToHistoryLimitCount() {
        if urlList.count > historyLimitCount {
            _ = urlList.popLast()
        }
    }
}
