//
//  DataSourceManager.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 29.03.2023.
//

import UIKit

protocol DataSourceManagerProtocol {
    func createDataSource(collectionView: UICollectionView)
    func cell(collectionView: UICollectionView, indexPath: IndexPath, item: AnyHashable) -> UICollectionViewCell
    func getTitle() -> String
}

final class DataSourceManager: DataSourceManagerProtocol, LayoutDataProtocol {
    weak var trackerNameCellDelegate: TrackerNameCellDelegate?
    var headers: [String]
    
    // initialized in ModuleFactory
    var emojieModel: EmojieModel
    var colorModel: ColorModel
    var settings: [String]
    var headerLabeltext: String
    
    typealias DataSource = UICollectionViewDiffableDataSource<String, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<String, AnyHashable>
    
    var dataSource: DataSource?
    
    init(headers: [String], emojieModel: EmojieModel, colorModel: ColorModel, settings: [String], headerLabeltext: String) {
        self.headers = headers
        self.emojieModel = emojieModel
        self.colorModel = colorModel
        self.settings = settings
        self.headerLabeltext = headerLabeltext
    }
    
    func getTitle() -> String {
        return headerLabeltext
    }
    
    func createDataSource(collectionView: UICollectionView) {
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
    
    private func createSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections(headers)
        snapshot.appendItems([""], toSection: headers[0])
        snapshot.appendItems(settings, toSection: headers[1])
        
        snapshot.appendItems(emojieModel.emojies, toSection: headers[2])
        snapshot.appendItems(colorModel.colors, toSection: headers[3])
        
        return snapshot
    }
    
    func cell(collectionView: UICollectionView, indexPath: IndexPath, item: AnyHashable) -> UICollectionViewCell {
        switch headers[indexPath.section] {
        case "TextView":
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerNameCell.reuseIdentifier, for: indexPath) as? TrackerNameCell else { return UICollectionViewCell() }
            cell.delegate = trackerNameCellDelegate
            cell.setupUI()
            return cell
            
        case "TextField":
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerSettingsCell.reuseIdentifier, for: indexPath) as? TrackerSettingsCell else { return UICollectionViewCell() }
            cell.setupCategory(title: settings[indexPath.row], for: indexPath.row)
            return cell
            
        case "Emojie":
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerEmojieCell.reuseIdentifier, for: indexPath) as? TrackerEmojieCell else { return UICollectionViewCell() }
            cell.emojieLabel.text = emojieModel.getEmojie(for: indexPath.row)
            return cell
            
        case "Цвет":
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerColorsCell.reuseIdentifier, for: indexPath) as? TrackerColorsCell else { return UICollectionViewCell() }
            cell.colorImage.backgroundColor = colorModel.getColor(for: indexPath.row)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}
