//
//  ShortenedListViewController.swift
//  UrlShortener
//
//  Created by Edson Yudi Toma on 09/07/25.
//

import UIKit

final class ShortenedListViewController: UIViewController {
    // MARK: - Properties
    private typealias DataSource = UITableViewDiffableDataSource<Int, ShortenedUrlModel>
    private let viewModel: ShortenedListViewModelProtocol

    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(tableView: tableView) { tableView, indexPath, model in
            guard let viewCell = tableView.dequeueReusableCell(
                withIdentifier: ShortenedListCell.reuseIdentifier,
                for: indexPath
            ) as? ShortenedListCell else {
                return UITableViewCell()
            }
            viewCell.setup(model)
            return viewCell
        }
        dataSource.defaultRowAnimation = .fade
        return dataSource
    }()

    // MARK: - Views
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "https://www.linkedin.com/in/edyuto/",
            attributes: [.foregroundColor: UIColor.systemGray]
        )
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 16
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    lazy var sendButton: UIButton = {
        let button = UIButton(configuration: .bordered())
        button.addTarget(self, action: #selector(shortenUrl), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [textField, sendButton])
        stack.axis = .horizontal
        stack.spacing = SpacingInsets.x08.value
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.register(ShortenedListCell.self, forCellReuseIdentifier: ShortenedListCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    // MARK: - Life cycle
    init(viewModel: ShortenedListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITextFieldDelegate
extension ShortenedListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        shortenUrl()
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - ViewCodeProtocol
extension ShortenedListViewController: ViewCodeProtocol {
    func setupHierarchy() {
        view.addSubview(stackView)
        view.addSubview(tableView)
        sendButton.addSubview(activityIndicator)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SpacingInsets.x16.value),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SpacingInsets.x16.value),

            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: SpacingInsets.x16.value),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            sendButton.widthAnchor.constraint(equalToConstant: SpacingInsets.x64.value),
            sendButton.heightAnchor.constraint(equalTo: textField.heightAnchor),

            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: SpacingInsets.x44.value),

            activityIndicator.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor)
        ])
    }

    func setupConfigurations() {
        title = viewModel.viewTitle
        view.backgroundColor = .systemBackground
        setupDataSource()
        setupBinds()
        viewModel.loadHistory()
        showNormalButton()
    }
}

// MARK: - UITableViewDelegate
extension ShortenedListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let model = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        AlertView.show(
            AlertModel(
                title: Localizable.originalUrlAlertTitle.localized,
                description: model.original,
                buttonTitle: Localizable.originalUrlAlertButtonTitle.localized
            ),
            on: navigationController
        )
    }
}

// MARK: - Helpers
private extension ShortenedListViewController {
    func setupDataSource() {
        tableView.dataSource = dataSource
        var snapshot = NSDiffableDataSourceSnapshot<Int, ShortenedUrlModel>()
        snapshot.appendSections([0])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func setupBinds() {
        viewModel.onUpdate = { [weak self] state in
            guard let self else { return }
            switch state {
            case let .error(model):
                showNormalButton()
                displayError(model)
            case .loading:
                showLoadingButton()
            case .success:
                showNormalButton()
                var snapshot = NSDiffableDataSourceSnapshot<Int, ShortenedUrlModel>()
                snapshot.appendSections([0])
                snapshot.appendItems(viewModel.urlList)
                dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
    }

    @objc
    func shortenUrl() {
        if let text = textField.text, !text.isEmpty {
            viewModel.shorten(text)
        }
    }

    func displayError(_ model: AlertModel) {
        AlertView.show(model, on: navigationController) { [weak self] in
            guard let self else { return }
            shortenUrl()
        }
    }

    func showLoadingButton() {
        sendButton.configuration?.image = nil
        activityIndicator.startAnimating()
        sendButton.isUserInteractionEnabled = false
    }

    func showNormalButton() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        let image = UIImage(systemName: "paperplane.fill")?.rotated(radians: .pi/4)
        sendButton.configuration?.image = image
        sendButton.isUserInteractionEnabled = true
    }
}
