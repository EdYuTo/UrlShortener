//
//  SceneDelegate.swift
//  UrlShortener
//

import CacheProvider
import NetworkProvider
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)

        let networkProvider = NetworkProvider()
        let networkDebugDecorator = NetworkDebugDecorator(provider: networkProvider)

        let cacheProvider = CacheProvider(storagePath: cacheDirectory())
        let cacheDebugDecorator = CacheDebugDecorator(provider: cacheProvider)

        let viewModel = ShortenedListViewModel(
            cacheProvider: cacheDebugDecorator,
            networkProvider: networkDebugDecorator
        )
        let viewController = ShortenedListViewController(viewModel: viewModel)

        let navigationController = UINavigationController(rootViewController: viewController)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window
    }
}

// MARK: - Helpers
private extension SceneDelegate {
    func cacheDirectory() -> URL {
        let defaultUrl = URL(fileURLWithPath: "/dev/null")
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
              let bundleId = Bundle.main.bundleIdentifier,
              !CommandLine.arguments.contains("-disable-cache") else {
            return defaultUrl
        }
        do {
            let directory = url
                .appendingPathComponent(bundleId)
                .appendingPathComponent("Application")
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            return directory
        } catch {
            return defaultUrl
        }
    }
}
