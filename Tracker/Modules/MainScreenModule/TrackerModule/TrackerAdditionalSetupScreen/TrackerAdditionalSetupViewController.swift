//
//  TrackerAdditionalSetupViewController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 30.03.2023.
//

import UIKit

protocol TrackerAdditionalSetupToCoordinatorProtocol: AnyObject {
    var additionalTrackerSetupDelegate: AdditionalTrackerSetupProtocol? { get set }
//    var isTimetableSelected: Bool? { get set }
    var returnOnCancel: (() -> Void)? { get set } // убрать в отдельный протокол
    var returnOnTimetableReady: (([WeekDays]?) -> Void)? { get set }
    var returnOnCategoryReady: ((String?) -> Void)? { get set }
    var selectedCategory: String? { get set }
    var selectedWeekDays: [WeekDays]? { get set }
    var additionalSetupCase: AdditionalSetupEnum? { get set } // убрать в отдельный протокол
}

protocol TrackerFilterSetupProtocol: AnyObject {
    var filterSetupDelegate: FiltersDelegate? { get set }
    var returnOnFiltersReady: ((Filters?) -> Void)? { get set }
    var selectedFilter: Filters? { get set }
    var additionalSetupCase: AdditionalSetupEnum? { get set }
    var returnOnCancel: (() -> Void)? { get set }
}

final class TrackerAdditionalSetupViewController: UIViewController, TrackerAdditionalSetupToCoordinatorProtocol, TrackerFilterSetupProtocol {
    weak var additionalTrackerSetupDelegate: AdditionalTrackerSetupProtocol?
//    var isTimetableSelected: Bool?
    var returnOnCancel: (() -> Void)?
    var returnOnTimetableReady: (([WeekDays]?) -> Void)?
    var returnOnCategoryReady: ((String?) -> Void)?
    // filtersSetupProtocol
    weak var filterSetupDelegate: FiltersDelegate?
    var returnOnFiltersReady: ((Filters?) -> Void)?
    var additionalSetupCase: AdditionalSetupEnum?
    
    private var headerTitle: String?
    private var readyButtonTitle: String?
    
    // data for transfering between the screens
    var selectedWeekDays: [WeekDays]?
    
    var selectedCategory: String?
    var selectedCategoryIndexPath: IndexPath?
    
    var selectedFilter: Filters?
    var selectedFilterIndexPath: IndexPath?
        
    private lazy var backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .YPBackground
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private lazy var headerLabel: CustomHeaderLabel = {
        let label = CustomHeaderLabel(headerText: additionalSetupCase?.headerTitle ?? "Header transferringError")
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
        chooseReadyButtonTitle()
        setupConstraints()
        presentationController?.delegate = self
        checkIfAlreadySelectedItem()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        additionalSetupCase = nil
    }
    
    
    private func chooseReadyButtonTitle() {
        guard let additionalSetupCase else { return }
        readyButtonTitle = additionalSetupCase.readyButtonTitle
    }
    
    private func addTimetableIfNeeded(day: WeekDays) {
        guard let selectedWeekDays else { return }
        selectedWeekDays.contains(day) ? self.selectedWeekDays?.removeAll(where: { $0 == day }) : self.selectedWeekDays?.append(day)
    }
    
    private func checkIfAlreadySelectedItem() {
        guard let additionalSetupCase else { return }
        switch additionalSetupCase {
        case .schedule(let schedule):
            selectedWeekDays = schedule ?? []
        case .category(let category):
            let item = Categories.allCases.firstIndex(where: { $0.description == category?.description }) ?? 0
            selectedCategoryIndexPath = IndexPath(item: item, section: 0)
            self.collectionView.selectItem(
                at: selectedCategoryIndexPath,
                animated: false,
                scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally
            )
        case .filters(let filter):
            let item = Filters.allCases.firstIndex(of: filter ?? .trackersForToday) ?? 0
            selectedFilterIndexPath = IndexPath(item: item, section: 0)
            self.collectionView.selectItem(
                at: selectedFilterIndexPath,
                animated: false,
                scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally
            )
        }
    }
    
    // MARK: - OBJC
    @objc
    private func dismissDidTapped() {
        returnOnCancel?()
    }
    
    @objc
    private func readyDidTap() {
        guard let additionalSetupCase else { return }
        switch additionalSetupCase {
        case .schedule(_):
            returnOnTimetableReady?(selectedWeekDays)
        case .category(_):
            break
        case .filters(_):
            break
        }
    }
}

// MARK: - Ext DataSource
extension TrackerAdditionalSetupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let additionalSetupCase else { return 0 }
        switch additionalSetupCase {
        case .schedule(_):
            return WeekDays.allCases.count
        case .category(_):
            return Categories.allCases.count
        case .filters:
            return Filters.allCases.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let additionalSetupCase,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerAdditionalSetupCell.reuseIdentifier, for: indexPath) as? TrackerAdditionalSetupCell
        else { return UICollectionViewCell() }
        
        let isFirstRow = indexPath.row == 0
        
        switch additionalSetupCase {
        case .schedule(let schedule):
            cell.trackerTimeTableCellDelegate = self
            let isLastRow = indexPath.row == WeekDays.allCases.count - 1
            let isSelected = schedule?.contains(WeekDays.allCases[indexPath.row]) ?? false
            cell.setupCellLayout(title: WeekDays.allCases[indexPath.row].description, isFirst: isFirstRow, isLast: isLastRow)
            cell.configScheduleCell(isSelected: isSelected)
        case .category(let category):
            let isLastRow = indexPath.row == Categories.allCases.count - 1
            let isSelected = category == Categories.allCases[indexPath.row].description
            cell.setupCellLayout(title: Categories.allCases[indexPath.row].description, isFirst: isFirstRow, isLast: isLastRow)
            cell.configCategoryCell(isSelected: isSelected)
        case .filters(let filter):
            let isLastRow = indexPath.row == Filters.allCases.count - 1
            let isSelected = filter == Filters.allCases[indexPath.row]
            cell.setupCellLayout(title: Filters.allCases[indexPath.row].description, isFirst: isFirstRow, isLast: isLastRow)
            cell.configFiltersCell(isSelected: isSelected)
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
        guard let additionalSetupCase,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerAdditionalSetupCell
        else { return }
        
        switch additionalSetupCase {
        case .schedule(_):
            break
        case .category(_):
            selectedCategory = Categories.allCases[indexPath.row].description
            cell.cellIsSelected = true
            returnOnCategoryReady?(selectedCategory)
        case .filters(_):
            selectedFilter = Filters.allCases[indexPath.row]
            cell.cellIsSelected = true
            returnOnFiltersReady?(selectedFilter)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let additionalSetupCase else { return }
        switch additionalSetupCase {
        case .schedule(_):
            break
        case .category(_):
            guard let selectedCategoryIndexPath,
                  let cell = collectionView.cellForItem(at: selectedCategoryIndexPath) as? TrackerAdditionalSetupCell
            else { return }
            cell.cellIsSelected = false
        case .filters(_):
            guard let selectedFilterIndexPath,
                  let cell = collectionView.cellForItem(at: selectedFilterIndexPath) as? TrackerAdditionalSetupCell
            else { return }
            cell.cellIsSelected = false
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
