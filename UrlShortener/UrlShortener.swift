//
//  UrlShortener.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 09/07/25.
//

import CacheProvider
import NetworkProvider
import UIKit

@main
final class UrlShortener: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let networkProvider = NetworkProvider()
        let networkDebugDecorator = NetworkDebugDecorator(provider: networkProvider)

        let cacheProvider = CacheProvider(storagePath: cacheDirectory())
        let cacheDebugDecorator = CacheDebugDecorator(provider: cacheProvider)

        let viewController = UIViewController()

        let navigationController = UINavigationController(rootViewController: viewController)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

    private func cacheDirectory() -> URL {
        let defaultUrl = URL(fileURLWithPath: "/dev/null")
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
              let bundleId = Bundle.main.bundleIdentifier else {
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
