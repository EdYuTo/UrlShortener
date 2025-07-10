//
//  ShortenedListCell.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 09/07/25.
//

import UIKit

final class ShortenedListCell: UITableViewCell, IdentifiableCell {
    // MARK: - Views
    lazy var shortenedUrl: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var creationDate: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .right
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [shortenedUrl, creationDate])
        stack.axis = .vertical
        stack.spacing = SpacingInsets.x08.value
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: Methods
    func setup(_ model: ShortenedUrlModel) {
        shortenedUrl.text = model.shortened
        creationDate.text = model.date.formatted(date: .abbreviated, time: .shortened)
        setupView()
    }
}

// MARK: - ViewCodeProtocol
extension ShortenedListCell: ViewCodeProtocol {
    func setupHierarchy() {
        addSubview(mainStackView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: SpacingInsets.x16.value),
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: SpacingInsets.x16.value),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -SpacingInsets.x16.value),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -SpacingInsets.x16.value)
        ])
    }
}
