//
//  ShortenedListViewModel.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 08/07/25.
//

import CacheProvider
import NetworkProvider

protocol ShortenedListViewModelProtocol: AnyObject {
    typealias Observer<T> = (T) -> Void

    @discardableResult
    func shorten(_ url: String) -> Task<Void, Never>
    @discardableResult
    func loadHistory() -> Task<Void, Never>

    var onUpdate: Observer<ShortenedListState>? { get set }
}

final class ShortenedListViewModel {
    private let cacheProvider: CacheProviderProtocol
    private let networkProvider: NetworkProviderProtocol

    var onUpdate: Observer<ShortenedListState>?

    init(
        cacheProvider: CacheProviderProtocol,
        networkProvider: NetworkProviderProtocol
    ) {
        self.cacheProvider = cacheProvider
        self.networkProvider = networkProvider
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
                await self.updateOnMainThread(.success)
            } catch {
                if let error = error as? NetworkError, case .connectionError = error {
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
}
