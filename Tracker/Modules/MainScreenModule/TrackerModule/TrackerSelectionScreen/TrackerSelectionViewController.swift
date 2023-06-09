//
//  TrackerSelectionViewController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 25.03.2023.
//

import UIKit

protocol TrackerSelectionCoordinatorProtocol: AnyObject {
    var headToHabit: (() -> Void)? { get set }
    var headToSingleEvent: (() -> Void)? { get set }
    var returnOnCancel: (() -> Void)? { get set }
}

final class TrackerSelectionViewController: UIViewController & TrackerSelectionCoordinatorProtocol {
    
    var headToHabit: (() -> Void)?
    var headToSingleEvent: (() -> Void)?
    var returnOnCancel: (() -> Void)?
    
    private var headerLabeltext = NSLocalizedString(K.LocalizableStringsKeys.trackerCreation, comment: "Creation of a new tracker")
    private var habitsButtonHeader = NSLocalizedString(K.LocalizableStringsKeys.habbit, comment: "Habbit to plan")
    private var singleEventButtonHeader = NSLocalizedString(K.LocalizableStringsKeys.singleEvent, comment: "Single event with no firm schedule")
    
    private lazy var headerLabel: CustomHeaderLabel = {
        let label = CustomHeaderLabel(headerText: headerLabeltext)
        return label
    }()
    
    private lazy var habitsButton: CustomActionButton = {
        let button = CustomActionButton(title: habitsButtonHeader, appearance: .confirm)
        button.addTarget(self, action: #selector(didSelectTracker), for: .touchUpInside)
        return button
    }()
    
    private lazy var singleEventButton: CustomActionButton = {
        let button = CustomActionButton(title: singleEventButtonHeader, appearance: .confirm)
        button.addTarget(self, action: #selector(didSelectTracker), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        
        stackView.addArrangedSubview(habitsButton)
        stackView.addArrangedSubview(singleEventButton)
        
        return stackView
    }()
    
    private lazy var dismissButton: CustomDismissButton = {
        let button = CustomDismissButton()
        button.addTarget(self, action: #selector(dismissDidTapped), for: .touchUpInside)
        return button
    }()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .YPWhite
        
        setupConstraints()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentationController?.delegate = self
    }
    
    @objc
    private func dismissDidTapped() {
        returnOnCancel?()
    }
    
    @objc
    private func didSelectTracker(_ sender: UIButton) {
        switch sender.titleLabel?.text {
        case habitsButtonHeader:
            headToHabit?()
        case singleEventButtonHeader:
            headToSingleEvent?()
        default:
            break
        }
    }
}

// MARK: - Constraints
private extension TrackerSelectionViewController {
    func setupConstraints() {
        setupButtonsStackView()
        setupDismissButton()
        setupHeaderLabel()
    }
    
    func setupButtonsStackView() {
        view.addSubview(buttonsStackView)
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 136),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    func setupDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dismissButton.widthAnchor.constraint(equalToConstant: 50),
            dismissButton.heightAnchor.constraint(equalToConstant: 50),
            dismissButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
    }
    
    func setupHeaderLabel() {
        view.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension TrackerSelectionViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        returnOnCancel?()
    }
}
