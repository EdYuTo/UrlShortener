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
    var viewTitle: String { get }
}

final class ShortenedListViewModel {
    private let cacheProvider: CacheProviderProtocol
    private let networkProvider: NetworkProviderProtocol

    var onUpdate: Observer<ShortenedListState>?
    var urlList: [ShortenedUrlModel] = []
    var historyLimitCount: Int
    var viewTitle: String {
        Localizable.shortenedListTitle.localized
    }

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
            await self.updateOnMainThread(
                .loading
            )
            do {
                let response: NetworkResponse<ShortenUrlResponse> = try await networkProvider.makeRequest(request)
                // Ideally we could use a NSOrderedSet for bigger datasets
                insertUnique(mapRemoteToDomain(response.content))
                clipUrlListToHistoryLimitCount()
                await self.saveUrlListToCache()
                await self.updateOnMainThread(.success)
            } catch {
                if let error = error as? NetworkError, case .connection = error {
                    await self.updateOnMainThread(
                        .error(connectionError())
                    )
                } else {
                    await self.updateOnMainThread(
                        .error(genericError())
                    )
                }
            }
        }
    }

    @discardableResult
    func loadHistory() -> Task<Void, Never> {
        Task {
            if let history: [ShortenedUrlStorage] = try? await cacheProvider.get(key: ShortenedUrlStorage.key) {
                urlList = history.map { mapCacheToDomain($0) }
                sortUrlList()
                clipUrlListToHistoryLimitCount()
                await self.updateOnMainThread(.success)
            }
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

    func mapDomainToCache(_ domain: ShortenedUrlModel) -> ShortenedUrlStorage {
        ShortenedUrlStorage(
            id: domain.id,
            original: domain.original,
            shortened: domain.shortened,
            date: domain.date
        )
    }

    func mapCacheToDomain(_ cache: ShortenedUrlStorage) -> ShortenedUrlModel {
        ShortenedUrlModel(
            id: cache.id,
            original: cache.original,
            shortened: cache.shortened,
            date: cache.date
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
        while urlList.count > historyLimitCount {
            _ = urlList.popLast()
        }
    }

    func saveUrlListToCache() async {
        let cacheList = urlList.map { mapDomainToCache($0) }
        try? await cacheProvider.set(key: ShortenedUrlStorage.key, value: cacheList)
    }

    func connectionError() -> AlertModel {
        AlertModel(
            title: Localizable.connectionErrorTitle.localized,
            description: Localizable.connectionErrorDescription.localized,
            buttonTitle: Localizable.connectionErrorButtonTitle.localized
        )
    }

    func genericError() -> AlertModel {
        AlertModel(
            title: Localizable.genericErrorTitle.localized,
            buttonTitle: Localizable.genericErrorButtonTitle.localized
        )
    }
}
