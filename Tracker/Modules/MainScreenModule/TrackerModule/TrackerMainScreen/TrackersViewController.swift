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
    func saveTracker(tracker: Tracker)
}

final class TrackersViewController: UIViewController & TrackerToCoordinatorProtocol {
    
    private let titleFontSize: CGFloat = 34
    private let datePickerCornerRadius: CGFloat = 8
        
    var addTrackerButtonPressed: (() -> Void)?
    
    //TODO: move to separate class
    var trackers: [Tracker] = [
//        Tracker(name: "Test", color: .blue, emoji: "🙂", timetable: ""),
//        Tracker(name: "Test 2", color: .orange, emoji: "🌺", timetable: ""),
//        Tracker(name: "Test 3", color: .red, emoji: "🥶", timetable: "")
    ] {
        didSet {
            checkForEmptyState()
            reloadCollectionView()
        }
    }
    var visibleTrackers: [Tracker] = [
    
    ]
    var visibleCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var categories: [TrackerCategory] = []
    
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
        
        collectionView.register(TrackersListCollectionViewCell.self, forCellWithReuseIdentifier: TrackersListCollectionViewCell.reuseIdentifier)
        
        return collectionView
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = "Search"
        textField.delegate = self
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
        
    }
    
    //TODO: move to separate checker
    private func checkForEmptyState() {
        emptyStateStackView.isHidden = trackers.isEmpty ? false : true
    }
    
    // collectionView reload
    private func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    @objc
    private func addTracker() {
        // сообщить о событии
        addTrackerButtonPressed?()
    }
}

// MARK: - Ext Data Source
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersListCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackersListCollectionViewCell else { return UICollectionViewCell() }
        let tracker = trackers[indexPath.row]
        cell.configCell(with: tracker)
        return cell
    }
}

// MARK: - Ext DelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / 2 - 5
        return CGSize(width: cellWidth,
                      height: cellWidth * 0.8)
    }
}

// MARK: - Ext TrackerMainScreenDelegate
extension TrackersViewController: TrackerMainScreenDelegate {
    func saveTracker(tracker: Tracker) {
        trackers.append(tracker)
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
