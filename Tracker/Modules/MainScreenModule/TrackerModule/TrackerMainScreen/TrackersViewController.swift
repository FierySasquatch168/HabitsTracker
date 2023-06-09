//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 23.03.2023.
//

import UIKit

protocol TrackerToCoordinatorProtocol: AnyObject {
    var addTrackerButtonPressed: (() -> Void)? { get set }
    var modifyTrackerButtonPressed: ((Tracker, String) -> Void)? { get set }
    var filterButtonPressed: (() -> Void)? { get set }
    var viewModel: TrackersViewModel { get }
}

final class TrackersViewController: UIViewController & TrackerToCoordinatorProtocol {
        
    private let titleFontSize: CGFloat = 34
    private let datePickerCornerRadius: CGFloat = 8
        
    var addTrackerButtonPressed: (() -> Void)?
    var modifyTrackerButtonPressed: ((Tracker, String) -> Void)?
    var filterButtonPressed: (() -> Void)?
    
    var analyticsService: AnalyticsService?
    
    let viewModel: TrackersViewModel
    
    var currentDate: Date? {
        viewModel.getCurrentDate(from: datePicker.date)
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
        
        collectionView.showsVerticalScrollIndicator = false
                
        return collectionView
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = NSLocalizedString(K.LocalizableStringsKeys.search, comment: "Search")
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
        imageView.image = UIImage(named: K.Icons.emptyState)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emptyStateTextLabel: UILabel = {
        let label = UILabel()
        let text = NSLocalizedString(K.LocalizableStringsKeys.emptyStateTitle, comment: "String showed when there is no trackers to show")
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
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .YPBlue
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.layer.masksToBounds = true
        button.setTitleColor(.YPWhite, for: .normal)
        button.setTitle(NSLocalizedString(K.LocalizableStringsKeys.filterButtonTitle, comment: "Filter"), for: .normal)
        button.titleLabel?.font = UIFont(name: CustomFonts.YPRegular.rawValue, size: 17)
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: Lifecycle
    
    init(viewModel: TrackersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = .systemBackground
        setupConstraints()
        setupNavigationAttributes()
        
        bind()
        transferTheCurrentDateToViewModel()
        checkTheCollectionViewState()
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        analyticsService?.report(event: .open, params: .noParameters)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        analyticsService?.report(event: .close, params: .noParameters)
    }
    
    //MARK: Methods
    
    private func bind() {
        viewModel.$visibleCategories.bind(action: { [weak self] trackerCategories in
            self?.emptyStateStackView.isHidden = !trackerCategories.isEmpty
            self?.collectionView.reloadData()
        })
        
        viewModel.$completedTrackers.bind(action: { [weak self] trackerRecords in
            self?.collectionView.reloadData()
        })
        
        viewModel.$selectedTrackerForModifycation.bind { [weak self] tracker, categoryName in
            guard let self, let tracker, let categoryName else { return }
            self.modifyTrackerButtonPressed?(tracker, categoryName)
        }
        
        viewModel.$filterSelected.bind { [weak self] filter in
            guard let self else { return }
            self.checkTheCollectionViewState()
            if let date = filter.date { self.datePicker.date = date }
        }
    }
    
    private func checkTheCollectionViewState() {
        viewModel.filterVisibleCategoriesBySelectedFilter()
    }
    
    private func transferTheCurrentDateToViewModel() {
        viewModel.selectedDate = datePicker.date
    }
    
    private func closeTheDatePicker() {
        presentedViewController?.dismiss(animated: false)
    }
    
    private func choosePinActionName(for indexPath: IndexPath) -> String {
        let isPinned = viewModel.visibleCategories[indexPath.section].trackers[indexPath.row].isPinned
        return isPinned ? NSLocalizedString(K.LocalizableStringsKeys.contextMenuOperatorUnpin, comment: "Unpin") : NSLocalizedString(K.LocalizableStringsKeys.contextMenuOperatorPin, comment: "Pin")
    }
}

// MARK: - Ext Data Source
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackersListCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? TrackersListCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        // cell delegate
        cell.trackersListCellDelegate = self
        // properties for the cell
        let properties = viewModel.configureCellProperties(with: currentDate, at: indexPath)
        let trackerImage = properties.completed ? UIImage(systemName: K.Icons.checkmark) ?? UIImage() : UIImage(systemName: K.Icons.plus) ?? UIImage()
        // cell configuration
        cell.configCell(with: properties.tracker, image: trackerImage, count: properties.count)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HeaderView.reuseIdentifier,
            for: indexPath
        ) as? HeaderView
        else {
            return UICollectionReusableView()
        }
        view.configure(with: viewModel.visibleCategories[indexPath.section].name)
        return view
    }
}

// MARK: - Ext OBJS
@objc private extension TrackersViewController {
    func addTracker() {
        addTrackerButtonPressed?()
        analyticsService?.report(event: .click, params: .addTrack)
    }
    
    func reloadTheDate() {
        transferTheCurrentDateToViewModel()
        checkTheCollectionViewState()
        closeTheDatePicker()
    }
    
    func filterButtonTapped() {
        filterButtonPressed?()
        analyticsService?.report(event: .click, params: .filter)
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

// MARK: - Ext CollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0,
                let indexPath = indexPaths.first
        else { return nil }
                
        return UIContextMenuConfiguration( actionProvider: { [weak self] actions in
            guard let self else { return UIMenu() }
            return UIMenu(children: [
                UIAction(
                    title: self.choosePinActionName(for: indexPath),
                    handler: { _ in
                        self.viewModel.pinTapped(at: indexPath)
                    }),
                UIAction(
                    title: NSLocalizedString(
                        K.LocalizableStringsKeys.contextMenuOperatorModify, comment: "Modify the tracker"
                    ), handler: { _ in
                        self.viewModel.modifyTapped(at: indexPath)
                        // Analytics
                        self.analyticsService?.report(event: .click, params: .edit)
                }),
                UIAction(
                    title: NSLocalizedString(
                        K.LocalizableStringsKeys.contextMenuOperatorDelete, comment: "Delete the tracker"),
                    attributes: .destructive,
                    handler: { _ in
                        self.viewModel.deleteTapped(at: indexPath)
                        // Analytics
                        self.analyticsService?.report(event: .click, params: .delete)
                    })
            ])
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackersListCollectionViewCell else { return nil }
        return UITargetedPreview(view: cell.cellBackgroundColorImageView)
    }
}

// MARK: - Ext TrackersListCellDelegate
extension TrackersViewController: TrackersListCollectionViewCellDelegate {
    func plusTapped(trackerID: String?) {
        viewModel.plusTapped(trackerID: trackerID, currentDate: currentDate)
        analyticsService?.report(event: .click, params: .checkTrack)
    }
}

// MARK: - Ext TextFieldDelegate
extension TrackersViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        string.isEmpty ? viewModel.filterVisibleCategoriesBySelectedFilter() : viewModel.filterTrackersBy(string)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.filterVisibleCategoriesBySelectedFilter()
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
        let leftItem = UIBarButtonItem(image: UIImage(systemName: K.Icons.plus), style: .plain, target: self, action: #selector(addTracker))
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
        setupFilterButton()
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
    
    func setupFilterButton() {
        view.addSubview(filterButton)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            filterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 130),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -130),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
