//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 23.03.2023.
//

import UIKit

protocol TrackerToCoordinatorProtocol {
    var addTrackerButtonPressed: (() -> Void)? { get set }
}

protocol TrackerMainScreenDelegate: AnyObject {
    func saveTracker(tracker: Tracker, to categoryName: String)
}

final class TrackersViewController: UIViewController & TrackerToCoordinatorProtocol {
    
    private lazy var coreDataManager: CoreDataManagerProtocol = {
        coreDataManager = CoreDataManager(coreDataManagerDelegate: self)
        return coreDataManager
    }()
    
    private let titleFontSize: CGFloat = 34
    private let datePickerCornerRadius: CGFloat = 8
        
    var addTrackerButtonPressed: (() -> Void)?
    
    var currentDate: Date? {
        datePicker.date.customlyFormatted()
    }
    
    //TODO: move to separate class
    var completedTrackers: Set<TrackerRecord> = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    var visibleCategories: [TrackerCategory] = [] {
        didSet {
            checkForEmptyState()
            collectionView.reloadData()
        }
    }

    
    var categories: [TrackerCategory] = [
//        TrackerCategory(name: "Важное", trackers: [
//            Tracker(name: "Play", color: .red, emoji: "🙂", schedule: [.tuesday, .thursday]),
//            Tracker(name: "Run", color: .blue, emoji: "😻", schedule: [.thursday, .friday])
//        ]),
//        TrackerCategory(name: "Самочувствие", trackers: [
//            Tracker(name: "Jump", color: .green, emoji: "🌺", schedule: [.tuesday, .wednesday, .thursday]),
//            Tracker(name: "Fly", color: .gray, emoji: "🐶", schedule: [.thursday, .friday])
//        ])
    ]
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.addArrangedSubview(searchTextField)
        stackView.addArrangedSubview(collectionView)
        return stackView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        // cell
        collectionView.register(TrackersListCollectionViewCell.self, forCellWithReuseIdentifier: TrackersListCollectionViewCell.reuseIdentifier)
        // header
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier)
        
        collectionView.showsVerticalScrollIndicator = false
                
        return collectionView
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = "Поиск"
        textField.delegate = self
        return textField
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.backgroundColor = .YPBackground
        datePicker.tintColor = .YPBlue
        datePicker.layer.cornerRadius = datePickerCornerRadius
        datePicker.layer.masksToBounds = true
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(reloadTheDate), for: .valueChanged)
        
        return datePicker
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.Icons.emptyState)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emptyStateTextLabel: UILabel = {
        let label = UILabel()
        let text = "Что будем отслеживать?"
        let attrs = [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.YPMedium.rawValue, size: 12),
            NSAttributedString.Key.foregroundColor : UIColor.YPBlack
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attrs as [NSAttributedString.Key : Any])
        
        return label
    }()
    
    private lazy var emptyStateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.addArrangedSubview(emptyStateImageView)
        stackView.addArrangedSubview(emptyStateTextLabel)
        
        return stackView
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = .systemBackground
        setupConstraints()
        setupNavigationAttributes()
        
        // загрузка трекеров и записей
        fetchTrackers()
        fetchRecords()
        
        
        checkForEmptyState()
        checkForScheduledTrackers()
        
        
    }
    
    //MARK: Methods
    
    private func fetchTrackers() {
        if let savedCategories = try? coreDataManager.fetchTrackerCategories() {
            visibleCategories = savedCategories
            categories = savedCategories
        } else {
            print("No saved categories")
        }
    }
    
    private func fetchRecords() {
        completedTrackers = coreDataManager.fetchedRecords
    }
    
    private func checkForEmptyState() {
        emptyStateStackView.isHidden = visibleCategories.isEmpty ? false : true
    }
    
    // TODO: move to coreDataManager
    private func checkForScheduledTrackers() {
        // TODO: rewrite to do everything through CoreData
        guard let stringDayOfWeek = currentDate?.weekdayNameStandalone, let weekDay = WeekDays.getWeekDay(from: stringDayOfWeek) else { return }
        var temporaryCategories: [TrackerCategory] = []
        
        for category in categories {
            let filteredTrackers = category.trackers.filter({ $0.schedule.contains(weekDay) })
            if !filteredTrackers.isEmpty {
                let filteredCategory = TrackerCategory(name: category.name, trackers: filteredTrackers)
                temporaryCategories.append(filteredCategory)
                visibleCategories = temporaryCategories
            } else {
                visibleCategories = temporaryCategories
            }
        }
    }
    
    private func chooseTrackerImage(for tracker: Tracker) -> UIImage {
        for completedTracker in completedTrackers {
            if completedTracker.id == tracker.id && completedTracker.date == currentDate {
                return UIImage(systemName: Constants.Icons.checkmark) ?? UIImage()
            }
        }
        
        return UIImage(systemName: Constants.Icons.plus) ?? UIImage()
    }
    
    private func updateCellCounter(at indexPath: IndexPath) -> Int {
        let id = visibleCategories[indexPath.section].trackers[indexPath.row].id
        return completedTrackers.filter({ $0.id == id }).count
    }
    
    private func closeTheDatePicker() {
        presentedViewController?.dismiss(animated: false)
    }
    
    @objc
    private func addTracker() {
        // сообщить о событии
        addTrackerButtonPressed?()
    }
    
    @objc
    private func reloadTheDate() {
        checkForScheduledTrackers()
        closeTheDatePicker()
    }

}

// MARK: - Ext Data Source
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersListCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackersListCollectionViewCell else { return UICollectionViewCell() }
        // cell delegate
        cell.trackersListCellDelegate = self
        // properties for the cell
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let image = chooseTrackerImage(for: tracker)
        let count = updateCellCounter(at: indexPath)
        // cell configuration
        cell.configCell(with: tracker, image: image, count: count)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as? HeaderView else { return UICollectionReusableView() }
        view.configure(with: visibleCategories[indexPath.section].name)
        return view
    }
}

// MARK: - Ext DelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / 2 - 5
        return CGSize(width: cellWidth,
                      height: cellWidth * 0.8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 36)
    }
}

// MARK: - Ext TrackerMainScreenDelegate
extension TrackersViewController: TrackerMainScreenDelegate {
    func saveTracker(tracker: Tracker, to categoryName: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            do {
                try self.coreDataManager.saveTracker(tracker: tracker, to: categoryName)
            } catch {
                print("saveTracker failed")
            }
            
            checkForScheduledTrackers()
        }
    }
}

// MARK: - Ext CoreDataManagerDelegate
extension TrackersViewController: CoreDataManagerDelegate {
    func didUpdateCategory(_ updatedCategories: [TrackerCategory], _ updates: CategoryUpdates) {
        visibleCategories = updatedCategories
        categories = updatedCategories
    }
    
    func didUpdateRecords(_ updatedRecords: Set<TrackerRecord>, _ updates: RecordUpdates) {
        completedTrackers = updatedRecords
    }
}

// MARK: - Ext TrackersListCellDelegate
extension TrackersViewController: TrackersListCollectionViewCellDelegate {
    func plusTapped(trackerID: UUID?) {
        guard let trackerID = trackerID, let currentDate = currentDate, currentDate <= Date() else { return }
        
        do {
            try coreDataManager.updateRecords(trackerID, with: currentDate)
        } catch {
            print("Saving of record failed")
        }
        print("completedTrackers.count is: \(completedTrackers.count)")
    }
}

// MARK: - Ext TextFieldDelegate
extension TrackersViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            checkForScheduledTrackers()
        }
        else {
            var temporaryCategories: [TrackerCategory] = []
            
            for category in visibleCategories {
                let filteredTrackers = category.trackers.filter({ $0.name.lowercased().contains(string.lowercased()) })
                if !filteredTrackers.isEmpty {
                    let filteredCategory = TrackerCategory(name: category.name, trackers: filteredTrackers)
                    temporaryCategories.append(filteredCategory)
                    visibleCategories = temporaryCategories
                } else {
                    visibleCategories = temporaryCategories
                }
            }
        }
        
        return true
    }
}


// MARK: - Ext NavigationAttributes
private extension TrackersViewController {
    func setupNavigationAttributes() {
        setupLeftButtonItem()
        setupRightButtonItem()
        setupNavigationTitleAttributes()
    }
    
    func setupLeftButtonItem() {
        let leftItem = UIBarButtonItem(image: UIImage(systemName: Constants.Icons.plus), style: .plain, target: self, action: #selector(addTracker))
        leftItem.tintColor = .YPBlack
        navigationItem.leftBarButtonItem = leftItem
    }
    
    func setupRightButtonItem() {
        let rightItem = UIBarButtonItem(customView: datePicker)
        rightItem.customView?.layer.cornerRadius = datePickerCornerRadius
        navigationItem.rightBarButtonItem = rightItem
    }
    
    func setupNavigationTitleAttributes() {
        guard let font = UIFont(name: CustomFonts.YPBold.rawValue, size: titleFontSize) else { return }
        let attrs = [NSAttributedString.Key.font : font]
        navigationController?.navigationBar.largeTitleTextAttributes = attrs
    }
}

// MARK: - Ext Constraints
private extension TrackersViewController {
    func setupConstraints() {
        setupMainStackView()
        setupEmptyStateStackView()
        setupDatePicker()
    }
    
    func setupMainStackView() {
        view.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    func setupEmptyStateStackView() {
        view.addSubview(emptyStateStackView)
        emptyStateStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyStateStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setupDatePicker() {
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
}
