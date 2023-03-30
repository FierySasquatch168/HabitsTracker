//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 27.03.2023.
//

import UIKit

protocol TrackerCreationToCoordinatorProtocol {
    var returnOnCancel: (() -> Void)? { get set }
    var saveTracker: (() -> Void)? { get set }
    var timeTableTapped: (() -> Void)? { get set }
}

// MARK: REFACTOR!

final class TrackerCreationViewController: UIViewController & TrackerCreationToCoordinatorProtocol {
    
    var returnOnCancel: (() -> Void)?
    var saveTracker: (() -> Void)?
    var timeTableTapped: (() -> Void)?
    
    var layoutManager: LayoutManagerProtocol?
    var dataSourceManager: DataSourceManagerProtocol?
    
    private var cancelButtonTitle = "Отменить"
    private var createButtonTitle = "Создать"
       
    private lazy var headerLabel: CustomHeaderLabel = {
        let label = CustomHeaderLabel(headerText: dataSourceManager?.getTitle() ?? "Error")
        return label
    }()
    
    private lazy var cancelButton: CustomActionButton = {
        let button = CustomActionButton(title: cancelButtonTitle, backGroundColor: .clear, titleColor: .YPRed)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.YPRed?.cgColor
        button.addTarget(self, action: #selector(cancelDidTap), for: .touchUpInside)
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
        
        // settings
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .YPWhite
        setupConstraints()
        
        dataSourceManager?.createDataSource(collectionView: collectionView)
        
        presentationController?.delegate = self
    }
    
    @objc
    private func cancelDidTap() {
        returnOnCancel?()
    }
    
    @objc
    private func saveDidTap() {
        // add trackerCreation
        saveTracker?()
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

// MARK: - Ext CollectionViewDelegate
extension TrackerCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            dataSourceManager?.trackerNameCellDelegate = self
            print("\(indexPath)")
        case 1:
            if indexPath.row == 1 {
                timeTableTapped?()
            }
        case 2:
            print("\(indexPath)")
        case 3:
            print("\(indexPath)")
        default:
            print("TrackerCreationViewController didSelectItemAt failed")
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

// MARK: - Ext TextFieldDelegate
extension TrackerCreationViewController: TrackerNameCellDelegate {
    func textDidChange(text: String?) {
        print(text)
    }
}
