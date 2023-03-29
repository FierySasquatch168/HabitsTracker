//
//  TrackerHabitViewController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 27.03.2023.
//

import UIKit

protocol TrackerHabitToCoordinatorProtocol {
    var returnOnCancel: (() -> Void)? { get set }
    var emojieModel: EmojieModel? { get set }
    var colorModel: ColorModel? { get set }
}

// MARK: REFACTOR!

final class TrackerHabitViewController: UIViewController & TrackerHabitToCoordinatorProtocol {
    var returnOnCancel: (() -> Void)?
    var emojieModel: EmojieModel?
    var colorModel: ColorModel?
    
    private var dataSource: DataSource?
    
    private typealias DataSource = UICollectionViewDiffableDataSource<String, AnyHashable>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<String, AnyHashable>
    
    private var headerLabeltext = "Новая привычка"
    private var cancelButtonTitle = "Отменить"
    private var createButtonTitle = "Создать"
    
    private var headers = ["TextView", "TextField","Emojie", "Цвет"]
    private var categories = ["Категория", "Расписание"]
   
    private lazy var headerLabel: CustomHeaderLabel = {
        let label = CustomHeaderLabel(headerText: headerLabeltext)
        return label
    }()
    
    private lazy var cancelButton: CustomActionButton = {
        let button = CustomActionButton(title: cancelButtonTitle, backGroundColor: .clear, titleColor: .YPRed)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.YPRed?.cgColor
        return button
    }()
    
    private lazy var createButton: CustomActionButton = {
        let button = CustomActionButton(title: createButtonTitle, backGroundColor: .YPBlack, titleColor: .YPWhite)
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
        let compositionalLayout = createCompositionalLayout()
        compositionalLayout.register(RoundedBackgroundView.self, forDecorationViewOfKind: RoundedBackgroundView.reuseIdentifier)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
                
        collectionView.register(TrackerNameCell.self, forCellWithReuseIdentifier: TrackerNameCell.reuseIdentifier)
        collectionView.register(TrackerCategoryCell.self, forCellWithReuseIdentifier: TrackerCategoryCell.reuseIdentifier)
        collectionView.register(TrackerEmojieCell.self, forCellWithReuseIdentifier: TrackerEmojieCell.reuseIdentifier)
        collectionView.register(TrackerColorsCell.self, forCellWithReuseIdentifier: TrackerColorsCell.reuseIdentifier)
        
        // MARK: UICV header
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier)
        
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .YPWhite
        setupConstraints()
        createDataSource()
        
        presentationController?.delegate = self
    }
    
    private func createDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            return self?.cell(collectionView: collectionView, indexPath: indexPath, item: itemIdentifier)
        })
        
        dataSource?.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) in
            guard let self = self, let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as? HeaderView else { fatalError() }
            if indexPath.section == 2 {
                header.configure(with: self.headers[2])
            }
            
            if indexPath.section == 3 {
                header.configure(with: self.headers[3])
            }
            
            return header
        }
        
        dataSource?.apply(createSnapshot())
    }
    
    private func cell(collectionView: UICollectionView, indexPath: IndexPath, item: AnyHashable) -> UICollectionViewCell {
        switch headers[indexPath.section] {
        case "TextView":
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerNameCell.reuseIdentifier, for: indexPath) as? TrackerNameCell else { return UICollectionViewCell() }
            cell.setupUI()
            return cell
            
        case "TextField":
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCategoryCell.reuseIdentifier, for: indexPath) as? TrackerCategoryCell else { return UICollectionViewCell() }
            cell.setupCategory(title: categories[indexPath.row], for: indexPath.row)
            return cell
            
        case "Emojie":
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerEmojieCell.reuseIdentifier, for: indexPath) as? TrackerEmojieCell else { return UICollectionViewCell() }
            cell.emojieLabel.text = emojieModel?.getEmojie(for: indexPath.row)
            return cell
            
        case "Цвет":
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerColorsCell.reuseIdentifier, for: indexPath) as? TrackerColorsCell else { return UICollectionViewCell() }
            cell.colorImage.backgroundColor = colorModel?.getColor(for: indexPath.row)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    private func createSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections(headers)
        snapshot.appendItems([""], toSection: headers[0])
        snapshot.appendItems(["Категория", "Расписание"], toSection: headers[1])
        
        if let emojies = emojieModel?.emojies, let colors = colorModel?.colors {
            snapshot.appendItems(emojies, toSection: headers[2])
            snapshot.appendItems(colors, toSection: headers[3])
        }
        
        return snapshot
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            return self?.sectionFor(index: sectionIndex, environment: environment)
        }
    }
    
    private func sectionFor(index: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let section = headers[index]
        
        switch section {
        case headers[0]:
            return createTextFieldSection()
        case headers[1]:
            return createCategorieSection()
        case headers[2]:
            return createEmojieSection()
        default:
            return createColorSection()
        }
    }
    
    
    private func createTextFieldSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(75)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.bottom = 24
        return section
    }
    
    private func createCategorieSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: RoundedBackgroundView.reuseIdentifier)
        section.decorationItems = [decorationItem]
        return section
    }
    
    private func createEmojieSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/7), heightDimension: .fractionalWidth(1/7)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(144)), subitems: [item])
        group.interItemSpacing = NSCollectionLayoutSpacing.flexible(10)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.top = 60
        addStandardHeader(to: section)
        
        return section
    }
    
    private func createColorSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/7), heightDimension: .fractionalWidth(1/7)))
        item.contentInsets.bottom = 12
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(144)), subitems: [item])
        group.interItemSpacing = NSCollectionLayoutSpacing.flexible(10)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.top = 70
        addStandardHeader(to: section)
        return section
    }
    
    private func addStandardHeader(to section: NSCollectionLayoutSection) {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(18))
        let headerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        headerElement.contentInsets.top = 30
        headerElement.contentInsets.bottom = 30
        section.boundarySupplementaryItems = [headerElement]
    }
}

// MARK: - Ext Constraints
private extension TrackerHabitViewController {
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

// MARK: - Ext UIAdaptivePresentationControllerDelegate
extension TrackerHabitViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        returnOnCancel?()
    }
}

