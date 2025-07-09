//
//  AlertView.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 09/07/25.
//

import UIKit

struct AlertModel {
    let title: String
    var description: String?
    let buttonTitle: String
    var style: UIAlertController.Style = .alert
}

enum AlertView {
    static func show(
        _ model: AlertModel,
        on navigationController: UINavigationController?,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: model.title,
            message: model.description,
            preferredStyle: model.style
        )
        let action = UIAlertAction(
            title: model.buttonTitle,
            style: .default
        ) { _ in
            completion?()
        }
        alert.addAction(action)
        navigationController?.present(alert, animated: true)
    }
}
