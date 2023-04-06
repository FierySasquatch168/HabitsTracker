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
    func saveTracker(tracker: Tracker, to category: String)
}

final class TrackersViewController: UIViewController & TrackerToCoordinatorProtocol {
    
    private let titleFontSize: CGFloat = 34
    private let datePickerCornerRadius: CGFloat = 8
        
    var addTrackerButtonPressed: (() -> Void)?
        
    var currentDate: Date? {
        didSet {
            
        }
    }
    
    //TODO: move to separate class
    var completedTrackerIDsSet: Set<UUID> = []
    
    var visibleCategories: [TrackerCategory] = [] {
        didSet {
            checkForEmptyState()
            collectionView.reloadData()
        }
    }
    
    var completedTrackers: [TrackerRecord] = []
    
    var categories: [TrackerCategory] = [] {
        didSet {
            visibleCategories = categories
        }
    }
    
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
                
        return collectionView
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = "Search"
        textField.delegate = self
        textField.addTarget(self, action: #selector(editingChanged), for: .valueChanged)
        return textField
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.backgroundColor = .YPBackground
        datePicker.tintColor = .YPBlack
        datePicker.layer.cornerRadius = datePickerCornerRadius
        datePicker.layer.masksToBounds = true
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
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
        checkForEmptyState()
        visibleCategories = categories
        
    }
    
    //TODO: move to separate checker
    private func checkForEmptyState() {
        emptyStateStackView.isHidden = categories.isEmpty ? false : true
    }
    
    private func filterTheTrackers() {
        
    }
    
    @objc
    private func addTracker() {
        // сообщить о событии
        addTrackerButtonPressed?()
    }
    
    @objc
    private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
    }
    
    @objc
    private func editingChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        if text.isEmpty {
            visibleCategories = categories
            collectionView.reloadData()
        } else {
            visibleCategories = categories.filter({ $0.name.localizedCaseInsensitiveContains(text) }).sorted(by: {
                if let range0 = $0.name.range(of: text, options: [.caseInsensitive], range: $0.name.startIndex..<$0.name.endIndex, locale: nil),
                   let range1 = $0.name.range(of: text, options: [.caseInsensitive], range: $1.name.startIndex..<$1.name.endIndex, locale: nil) {
                    return range0.lowerBound < range1.lowerBound
                } else {
                    return false
                }
            })
            collectionView.reloadData()
        }
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
        cell.trackersListCellDelegate = self
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        cell.configCell(with: tracker)
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
    func saveTracker(tracker: Tracker, to category: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if !categories.contains(where: { $0.name == category }) {
                let newCategory = TrackerCategory(name: category, trackers: [tracker])
                var temporaryCategories = categories
                temporaryCategories.append(newCategory)
                categories = temporaryCategories
            }
            else {
                var newCategoryTrackers = categories.first(where: { $0.name == category })?.trackers
                let newCategoryIndex = categories.firstIndex(where: { $0.name == category })
                newCategoryTrackers?.append(tracker)
                var temporaryCategories = categories
                temporaryCategories[newCategoryIndex!] = TrackerCategory(name: category, trackers: newCategoryTrackers!)
                categories = temporaryCategories
            }
            collectionView.reloadData()
        }
    }
}

// MARK: - Ext TrackersListCellDelegate
extension TrackersViewController: TrackersListCollectionViewCellDelegate {
    func plusTapped(trackerID: UUID?) {
        guard let trackerID = trackerID else { return }
        let dateOfCompletion = Date().toString()
        let completedTracker = TrackerRecord(id: trackerID, date: dateOfCompletion)
        
        if !completedTrackers.contains(where: { $0.id == trackerID }) {
            completedTrackers.append(completedTracker)
            completedTrackerIDsSet.insert(completedTracker.id)
        } else {
            completedTrackers.removeAll(where: { $0.id == trackerID })
            completedTrackerIDsSet.remove(trackerID)
        }
    }
}

// MARK: - Ext TextFieldDelegate
extension TrackersViewController: UITextFieldDelegate {
    // TODO: apply filtering of the trackers later
    
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
