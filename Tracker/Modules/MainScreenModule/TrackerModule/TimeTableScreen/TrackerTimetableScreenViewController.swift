//
//  TrackerTimetableScreenViewController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 30.03.2023.
//

import UIKit

protocol TrackerTimeTableToCoordinatorProtocol {
    var timetableTransferDelegate: TimetableTransferDelegate? { get set }
    var returnOnCancel: (() -> Void)? { get set }
    var returnOnReady: (([Substring]) -> Void)? { get set }
}

final class TrackerTimetableScreenViewController: UIViewController, TrackerTimeTableToCoordinatorProtocol {
    var timetableTransferDelegate: TimetableTransferDelegate?
    
    var returnOnCancel: (() -> Void)?
    var returnOnReady: (([Substring]) -> Void)?
    
    private var headerTitle: String = "Расписание"
    private var readyButtonTitle: String = "Готово"
    
    private var selectedWeekDays: [Substring] = []
        
    private lazy var backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .YPBackground
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private lazy var headerLabel: CustomHeaderLabel = {
        let label = CustomHeaderLabel(headerText: headerTitle)
        return label
    }()
    
    private lazy var dismissButton: CustomDismissButton = {
        let button = CustomDismissButton()
        button.addTarget(self, action: #selector(dismissDidTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(TrackerTimeTableCell.self, forCellWithReuseIdentifier: TrackerTimeTableCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundView = backgroundView
        
        return collectionView
    }()
    
    private lazy var readyButton: CustomActionButton = {
        let button = CustomActionButton(title: readyButtonTitle, backGroundColor: .YPBlack, titleColor: .YPWhite)
        button.addTarget(self, action: #selector(readyDidTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .YPWhite
        setupConstraints()
        presentationController?.delegate = self
    }
    
    private func convertStringToShortWeekDay(day: String) -> Substring {
        return WeekDays(rawValue: day)?.shortName ?? "Error"
    }
    
    private func addTimetableIfNeeded(shortName: Substring) {
        if !selectedWeekDays.contains(shortName) {
            selectedWeekDays.append(shortName)
        } else {
            selectedWeekDays.removeAll(where: { $0 == shortName })
        }
    }
    
    @objc
    private func dismissDidTapped() {
        returnOnCancel?()
    }
    
    @objc
    private func readyDidTap() {
        // 
        returnOnReady?(selectedWeekDays)
    }

}

// MARK: - Ext DataSource
extension TrackerTimetableScreenViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return WeekDays.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerTimeTableCell.reuseIdentifier, for: indexPath) as? TrackerTimeTableCell else { return UICollectionViewCell() }
        cell.trackerTimeTableCellDelegate = self
        cell.configCellWith(title: WeekDays.allCases.map({ $0.rawValue })[indexPath.row], for: indexPath.row)
        return cell
    }
}

// MARK: - Ext CV Delegate
extension TrackerTimetableScreenViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height / Double(WeekDays.allCases.count + 1))
    }
}

// MARK: - Ext Cell delegate
extension TrackerTimetableScreenViewController: TrackerTimeTableCellDelegate {
    func didToggleSwitch(text: String?) {
        guard let text = text else { return }
        let shortName = convertStringToShortWeekDay(day: text)
        addTimetableIfNeeded(shortName: shortName)
    }
}

// MARK: - Ext UIAdaptivePresentationControllerDelegate
extension TrackerTimetableScreenViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        returnOnCancel?()
    }
}

// MARK: - Constraints
private extension TrackerTimetableScreenViewController {
    func setupConstraints() {
        setupDismissButton()
        setupHeaderLabel()
        setupReadyButton()
        setupCollectionVIew()
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
    
    func setupReadyButton() {
        view.addSubview(readyButton)
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            readyButton.heightAnchor.constraint(equalToConstant: 60),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupCollectionVIew() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 30),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: readyButton.topAnchor, constant: -47)
        ])
    }
}
