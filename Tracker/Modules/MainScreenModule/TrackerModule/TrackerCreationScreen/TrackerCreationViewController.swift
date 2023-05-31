//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 27.03.2023.
//

import UIKit

protocol TrackerCreationToCoordinatorProtocol {
    var returnOnCancel: (() -> Void)? { get set }
    var saveTrackerTapped: (() -> Void)? { get set }
    var scheduleTapped: (() -> Void)? { get set }
    var categoryTapped: (() -> Void)? { get set }
}

protocol AdditionalTrackerSetupProtocol: AnyObject {
    var selectedCategory: String? { get }
    var selectedCategoryIndexPath: IndexPath? { get }
    var selectedWeekDays: [WeekDays]? { get }
    var editingTapped: Bool? { get set }
    func transferTimeTable(from selectedWeekdays: [WeekDays])
    func transferCategory(from selectedCategory: String, at indexPath: IndexPath?)
    func populateTheTemplatesWithSelectedTrackerToModify(with tracker: Tracker?, for categoryName: String?)
}

final class TrackerCreationViewController: UIViewController & TrackerCreationToCoordinatorProtocol {
    var returnOnCancel: (() -> Void)?
    var saveTrackerTapped: (() -> Void)?
    var scheduleTapped: (() -> Void)?
    var categoryTapped: (() -> Void)?
    
    weak var mainScreenDelegate: TrackerMainScreenDelegate?
    var layoutManager: LayoutManagerProtocol?
    var dataSourceManager: DataSourceManagerProtocol?
    
    private var cancelButtonTitle = NSLocalizedString(Constants.LocalizableStringsKeys.cancel, comment: "Abort the operation")
    private var createButtonTitle = NSLocalizedString(Constants.LocalizableStringsKeys.create, comment: "Create a new tracker")
    
    // properties for cell single selection
    private var emojieSelectedItem: Int? {
        didSet {
            updateSelectedEmoji()
        }
    }
    private var colorSelectedItem: Int? {
        didSet {
            updateSelectedColor()
        }
    }
    private var selectedItem: IndexPath?
    private var templateCategoryIndexPath: IndexPath?
    private var isEditingTracker: Bool?
    
    // tracker properties for model
    private var templateName: String = "" {
        didSet {
            updateSelectedTrackerName()
            checkForCorrectTrackerInfo()
        }
    }
    private var templateColor: UIColor = .clear {
        didSet {
            checkForCorrectTrackerInfo()
        }
    }
    private var templateEmojie: String = "" {
        didSet {
            checkForCorrectTrackerInfo()
        }
    }
    
    private var templateCategory: String = "" {
        didSet {
            updateCategorySubtitles()
            checkForCorrectTrackerInfo()
            collectionView.reloadData()
        }
    }
    private var templateSchedule: [WeekDays] = [] {
        didSet {
            updateScheduleView()
            collectionView.reloadData()
        }
    }
    
    private var templateStringID: String?
    
       
    private lazy var headerLabel: CustomHeaderLabel = {
        let label = CustomHeaderLabel(headerText: dataSourceManager?.getTitle() ?? "Error")
        return label
    }()
    
    private lazy var cancelButton: CustomActionButton = {
        let button = CustomActionButton(title: cancelButtonTitle, appearance: .cancel)
        button.addTarget(self, action: #selector(cancelDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: CustomActionButton = {
        let button = CustomActionButton(title: createButtonTitle, appearance: .disabled)
        button.addTarget(self, action: #selector(saveDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var bottomButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)
        
        return stackView
    }()
    
    private lazy var collectionView: UICollectionView = {
        // layout
        let compositionalLayout = layoutManager?.createCompositionalLayout()
        compositionalLayout?.register(RoundedBackgroundView.self, forDecorationViewOfKind: RoundedBackgroundView.reuseIdentifier)
        
        // collectionView
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout ?? UICollectionViewFlowLayout())
        
        // cells
        collectionView.register(TrackerNameCell.self, forCellWithReuseIdentifier: TrackerNameCell.reuseIdentifier)
        collectionView.register(TrackerSettingsCell.self, forCellWithReuseIdentifier: TrackerSettingsCell.reuseIdentifier)
        collectionView.register(TrackerEmojieCell.self, forCellWithReuseIdentifier: TrackerEmojieCell.reuseIdentifier)
        collectionView.register(TrackerColorsCell.self, forCellWithReuseIdentifier: TrackerColorsCell.reuseIdentifier)
        
        // header
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier)
        
        // delegate
        collectionView.delegate = self
        
        // titles
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsMultipleSelection = false
        
        return collectionView
    }()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .YPWhite
        setupConstraints()
        
        // dataSource
        createDataSource()
        // dataSource delegates
        setDataSourceDelegates()
        // swipe down delegate
        presentationController?.delegate = self
        
    }
    
    // MARK: Methods
    
    private func createDataSource() {
        dataSourceManager?.createDataSource(collectionView: collectionView)
    }
    
    private func setDataSourceDelegates() {
        dataSourceManager?.trackerNameCellDelegate = self
        dataSourceManager?.emojieCelldelegate = self
        dataSourceManager?.colorCellDelegate = self
    }
    
    private func updateScheduleView() {
        dataSourceManager?.scheduleSubtitles = WeekDays.populateShortWeekDaysSubtitle(from: templateSchedule)
    }
    
    private func updateCategorySubtitles() {
        dataSourceManager?.categorySubtitles = templateCategory
    }
    
    private func updateSelectedEmoji() {
        dataSourceManager?.emojieSelectedItem = emojieSelectedItem
    }
    
    private func updateSelectedColor() {
        dataSourceManager?.colorSelectedItem = colorSelectedItem
    }
    
    private func updateSelectedTrackerName() {
        dataSourceManager?.selectedTrackerName = templateName
    }
    
    private func findIndexOfSelectedCategory(with categoryName: String) -> Int {
        return Categories
            .allCases
            .compactMap({ $0.description })
            .firstIndex(of: categoryName) ?? 4
    }
}

// MARK: - Ext CollectionViewDelegate
extension TrackerCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            // proceed to category
            if indexPath.row == 0 {
                categoryTapped?()
            }
            // proceed to schedule
            if indexPath.row == 1 {
                scheduleTapped?()
            }
            
        case 2:
            // select emojie
            guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerEmojieCell else { return }
            cell.cellIsSelected = true
            emojieSelectedItem = indexPath.item
        case 3:
            // select color
            guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerColorsCell else { return }
            cell.cellIsSelected = true
            colorSelectedItem = indexPath.item
            
        default:
            print("TrackerCreationViewController didSelectItemAt failed")
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        selectedItem = indexPath
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let section = selectedItem?.section else { return }
        switch section {
        case 0:
            break
        case 1:
            break
        case 2:
            guard let item = emojieSelectedItem, let cell = collectionView.cellForItem(at: IndexPath(item: item, section: section)) as? TrackerEmojieCell else { return }
            cell.cellIsSelected = false
        case 3:
            guard let item = colorSelectedItem, let cell = collectionView.cellForItem(at: IndexPath(item: item, section: section)) as? TrackerColorsCell else { return }
            cell.cellIsSelected = false
        default:
            break
        }
    }
}

// MARK: - Ext UIAdaptivePresentationControllerDelegate
extension TrackerCreationViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        returnOnCancel?()
    }
}

// MARK: - Ext Timetable delegate
extension TrackerCreationViewController: AdditionalTrackerSetupProtocol {
    var editingTapped: Bool? {
        get {
            return self.isEditingTracker
        }
        set {
            isEditingTracker = newValue
        }
    }
    
    var selectedWeekDays: [WeekDays]? {
        return templateSchedule
    }
    
    var selectedCategory: String? {
        return templateCategory
    }
    
    var selectedCategoryIndexPath: IndexPath? {
        return templateCategoryIndexPath
    }
        
    func transferTimeTable(from selectedWeekdays: [WeekDays]) {
        templateSchedule = selectedWeekdays
    }
    
    func transferCategory(from selectedCategory: String, at indexPath: IndexPath?) {
        templateCategory = selectedCategory
        templateCategoryIndexPath = indexPath
    }
    
    func populateTheTemplatesWithSelectedTrackerToModify(with tracker: Tracker?, for categoryName: String?) {
        guard let tracker, let categoryName else { return }
        templateName = tracker.name
        templateCategory = categoryName
        templateSchedule = tracker.schedule
        templateStringID = tracker.stringID
        templateColor = tracker.color
        templateEmojie = tracker.emoji
        
        colorSelectedItem = dataSourceManager?.getColorIndex(from: tracker.color)
        emojieSelectedItem = dataSourceManager?.getEmojieIndex(from: tracker.emoji)
        
        let selectedCategoryIndex = findIndexOfSelectedCategory(with: categoryName)
        templateCategoryIndexPath = IndexPath(item: selectedCategoryIndex, section: 0)
    }
}

// MARK: - Ext TextFieldDelegate
extension TrackerCreationViewController: TrackerNameCellDelegate {
    func textDidChange(text: String?) {
        guard let text = text else { return }
        templateName = text
    }
}

// MARK: - Ext EmojieCellDelegate
extension TrackerCreationViewController: EmojieCellDelegate {
    func didSelectEmojie(emojie: String?) {
        guard let emojie = emojie else { return }
        templateEmojie = emojie
    }
}

// MARK: - Ext ColorCellDelegate
extension TrackerCreationViewController: ColorCellDelegate {
    func didSelectColor(color: UIColor?) {
        guard let color = color else { return }
        templateColor = color
    }
}

// MARK: - Ext WeekDay management
private extension TrackerCreationViewController {
    func scheduleAllDaysIfEmpty() {
        templateSchedule.isEmpty ? templateSchedule = WeekDays.allCases : ()
    }
}

// MARK: - Ext TrackerProperties check
private extension TrackerCreationViewController {
    func checkForCorrectTrackerInfo() {
        if !templateName.isEmpty
        && templateColor != .clear
        && !templateEmojie.isEmpty
        && !templateCategory.isEmpty {
            createButton.setAppearance(for: .confirm)
        } else {
            createButton.setAppearance(for: .disabled)
        }
    }
}

// MARK: - Ext Saving data
private extension TrackerCreationViewController {
    func saveTracker() {
        // check if schedule is empty
        scheduleAllDaysIfEmpty()
        // create tracker
        let tracker = createTracker(name: templateName, color: templateColor, emoji: templateEmojie, schedule: templateSchedule)
        // delegate - save tracker
        editingTapped ?? false ? mainScreenDelegate?.updateTracker(tracker: tracker, at: templateCategory) : mainScreenDelegate?.saveTracker(tracker: tracker, to: templateCategory)
        
    }
    
    func createTracker(name: String, color: UIColor, emoji: String, schedule: [WeekDays]) -> Tracker {
        return Tracker(name: name, color: color, emoji: emoji, schedule: schedule, stringID: templateStringID, isPinned: false)
    }
}

// MARK: - Ext OBJS
@objc private extension TrackerCreationViewController {
    func cancelDidTap() {
        returnOnCancel?()
    }
    
    func saveDidTap() {
        saveTracker()
        saveTrackerTapped?()
    }
}

// MARK: - Ext Constraints
private extension TrackerCreationViewController {
    func setupConstraints() {
        setupHeaderLabel()
        setupButtonStackView()
        setupCollectionView()
    }
    
    func setupHeaderLabel() {
        view.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -127)
        ])
    }
    
    func setupButtonStackView() {
        view.addSubview(bottomButtonStackView)
        bottomButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomButtonStackView.heightAnchor.constraint(equalToConstant: 60),
            bottomButtonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bottomButtonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bottomButtonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -21)
        ])
    }
}
