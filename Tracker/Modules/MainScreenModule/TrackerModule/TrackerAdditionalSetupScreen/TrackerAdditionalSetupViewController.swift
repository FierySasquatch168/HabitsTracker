//
//  TrackerAdditionalSetupViewController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 30.03.2023.
//

import UIKit

protocol TrackerAdditionalSetupToCoordinatorProtocol: AnyObject {
    var additionalTrackerSetupDelegate: AdditionalTrackerSetupProtocol? { get set }
    var timetableSelected: Bool? { get set }
    var returnOnCancel: (() -> Void)? { get set }
    var returnOnTimetableReady: (([WeekDays]) -> Void)? { get set }
    var returnOnCategoryReady: ((String) -> Void)? { get set }
}

final class TrackerAdditionalSetupViewController: UIViewController, TrackerAdditionalSetupToCoordinatorProtocol {
    weak var additionalTrackerSetupDelegate: AdditionalTrackerSetupProtocol?
    var timetableSelected: Bool?
    var returnOnCancel: (() -> Void)?
    var returnOnTimetableReady: (([WeekDays]) -> Void)?
    var returnOnCategoryReady: ((String) -> Void)?
    
    private var headerTitle: String?
    private var readyButtonTitle: String?
    
    private var timetableScreenTitle = NSLocalizedString(Constants.LocalizableStringsKeys.schedule, comment: "Schedule")
    private var categoryScreenTitle = NSLocalizedString(Constants.LocalizableStringsKeys.category, comment: "Category")
    private var timetableDoneButtonTitle = NSLocalizedString(Constants.LocalizableStringsKeys.ready, comment: "When the tracker is ready to be saved")
    private var categoryDoneButtonTitle = NSLocalizedString(Constants.LocalizableStringsKeys.addCategory, comment: "To add a category")
    
    // data for transfering between the screens
    private var selectedWeekDays: [WeekDays] = []
    private var selectedCategory: String = ""
        
    private lazy var backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .YPBackground
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private lazy var headerLabel: CustomHeaderLabel = {
        let label = CustomHeaderLabel(headerText: headerTitle ?? "Header transferringError")
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
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        // cell
        collectionView.register(TrackerAdditionalSetupCell.self, forCellWithReuseIdentifier: TrackerAdditionalSetupCell.reuseIdentifier)
        // delegate + dataSource
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.allowsMultipleSelection = false
        
        return collectionView
    }()
    
    private lazy var readyButton: CustomActionButton = {
        let button = CustomActionButton(title: readyButtonTitle ?? "ButtonTitleTransferError", appearance: .confirm)
        button.addTarget(self, action: #selector(readyDidTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .YPWhite
        chooseHeader()
        chooseReadyButtonTitle()
        setupConstraints()
        presentationController?.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timetableSelected = nil
    }
    
    private func chooseHeader() {
        guard let timetableSelected = timetableSelected else { return }
        headerTitle = timetableSelected ? timetableScreenTitle : categoryScreenTitle
    }
    
    private func chooseReadyButtonTitle() {
        guard let timetableSelected = timetableSelected else { return }
        readyButtonTitle = timetableSelected ? timetableDoneButtonTitle : categoryDoneButtonTitle
    }
    
    private func addTimetableIfNeeded(day: WeekDays) {
        // works, appends and removes .tuesday or etc
        selectedWeekDays.contains(day) ? selectedWeekDays.removeAll(where: { $0 == day }) : selectedWeekDays.append(day)
    }
    
    @objc
    private func dismissDidTapped() {
        returnOnCancel?()
    }
    
    @objc
    private func readyDidTap() {
        guard let timetableSelected = timetableSelected else { return }
        timetableSelected ? returnOnTimetableReady?(selectedWeekDays) : returnOnCategoryReady?(selectedCategory)
        
    }

}

// MARK: - Ext DataSource
extension TrackerAdditionalSetupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let timetableSelected = timetableSelected else { return 0 }
        return timetableSelected ? WeekDays.allCases.count : Categories.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let timetableSelected = timetableSelected,
              let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerAdditionalSetupCell.reuseIdentifier,
                for: indexPath) as? TrackerAdditionalSetupCell
        else { return UICollectionViewCell() }
        
        cell.trackerTimeTableCellDelegate = self
        let isFirstRow = indexPath.row == 0
        
        if timetableSelected {
            let isLastRow = indexPath.row == WeekDays.allCases.count - 1
            cell.configTimeTableCell(
                title: WeekDays.allCases[indexPath.row].description,
                isFirst: isFirstRow,
                isLast: isLastRow,
                timetableSelected: timetableSelected
            )
            
        } else {
            let isLastRow = indexPath.row == Categories.allCases.count - 1
            cell.configTimeTableCell(
                title: Categories.allCases[indexPath.row].description,
                isFirst: isFirstRow,
                isLast: isLastRow,
                timetableSelected: timetableSelected
            )
            
        }
        
        return cell
    }
}

// MARK: - Ext CV Delegate
extension TrackerAdditionalSetupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 75)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let timetableSelected = timetableSelected else { return }
        if !timetableSelected {
            selectedCategory = Categories.allCases[indexPath.row].description
        }
    }
}

// MARK: - Ext Cell delegate
extension TrackerAdditionalSetupViewController: TrackerTimeTableCellDelegate {
    func didToggleSwitch(text: String?) {
        guard let text = text, let weekDay = WeekDays.getWeekDay(from: text) else { return }
        addTimetableIfNeeded(day: weekDay)
    }
}

// MARK: - Ext UIAdaptivePresentationControllerDelegate
extension TrackerAdditionalSetupViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        returnOnCancel?()
    }
}

// MARK: - Constraints
private extension TrackerAdditionalSetupViewController {
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
            collectionView.bottomAnchor.constraint(greaterThanOrEqualTo: readyButton.topAnchor, constant: -47)
        ])
    }
}
