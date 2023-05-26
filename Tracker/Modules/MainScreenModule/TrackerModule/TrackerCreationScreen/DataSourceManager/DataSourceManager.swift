//
//  DataSourceManager.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 29.03.2023.
//

import UIKit

protocol DataSourceManagerProtocol {
    var trackerNameCellDelegate: TrackerNameCellDelegate? { get set }
    var settingsCellDelegate: SettingsCellDelegate? { get set }
    var emojieCelldelegate: EmojieCellDelegate? { get set }
    var colorCellDelegate: ColorCellDelegate? { get set }
    var categorySubtitles: String { get set }
    var scheduleSubtitles: String { get set }
    var emojieSelectedItem: Int? { get set }
    var colorSelectedItem: Int? { get set }
    var selectedTrackerName: String? { get set }
    func createDataSource(collectionView: UICollectionView)
    func getTitle() -> String
    func getColorIndex(from color: UIColor) -> Int
    func getEmojieIndex(from emojie: String) -> Int
}

final class DataSourceManager: DataSourceManagerProtocol, LayoutDataProtocol {
    
    
    weak var trackerNameCellDelegate: TrackerNameCellDelegate?
    weak var settingsCellDelegate: SettingsCellDelegate?
    weak var emojieCelldelegate: EmojieCellDelegate?
    weak var colorCellDelegate: ColorCellDelegate?
    
    // initialized in ModuleFactory
    var emojieModel: EmojieModel
    var colorModel: ColorModel
    var titles: [String]
    var emojieSelectedItem: Int?
    var colorSelectedItem: Int?
    var selectedTrackerName: String?
    
    // initialized after user picks up category
    var categorySubtitles: String = ""
    
    // initialized after user picks up schedule
    var scheduleSubtitles: String = ""
    
    var headerLabeltext: String
    
    typealias DataSource = UICollectionViewDiffableDataSource<Sections, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Sections, AnyHashable>
    
    var dataSource: DataSource?
    
    init(emojieModel: EmojieModel, colorModel: ColorModel, settings: [String], headerLabeltext: String) {
        self.emojieModel = emojieModel
        self.colorModel = colorModel
        self.titles = settings
        self.headerLabeltext = headerLabeltext
    }
    
    func getTitle() -> String {
        return headerLabeltext
    }
    
    func getColorIndex(from color: UIColor) -> Int {
        return colorModel.getIndex(for: color)
    }
    
    func getEmojieIndex(from emojie: String) -> Int {
        return emojieModel.getEmojieIndex(for: emojie)
    }
    
    func createDataSource(collectionView: UICollectionView) {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            return self?.cell(collectionView: collectionView, indexPath: indexPath, item: itemIdentifier)
        })
        
        dataSource?.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as? HeaderView else { fatalError() }
            if indexPath.section == 2 {
                header.configure(with: Sections.emojies.name)
            }
            
            if indexPath.section == 3 {
                header.configure(with: Sections.colors.name)
            }
            
            return header
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dataSource?.apply(createSnapshot())
        }
        
    }
}

// MARK: - Ext snapshot
private extension DataSourceManager {
    func createSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.trackerName, .trackerSettings, .emojies, .colors])
        snapshot.appendItems([""], toSection: .trackerName)
        snapshot.appendItems(titles, toSection: .trackerSettings)
        
        snapshot.appendItems(emojieModel.emojies, toSection: .emojies)
        snapshot.appendItems(colorModel.colors, toSection: .colors)
        return snapshot
    }
}

// MARK: - Ext Cell creation
private extension DataSourceManager {
    func cell(collectionView: UICollectionView, indexPath: IndexPath, item: AnyHashable) -> UICollectionViewCell {
        
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
        
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerNameCell.reuseIdentifier, for: indexPath) as? TrackerNameCell else { return UICollectionViewCell() }
            cell.delegate = trackerNameCellDelegate
            cell.setupUI()
            cell.textField.text = selectedTrackerName
            
            return cell
            
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerSettingsCell.reuseIdentifier, for: indexPath) as? TrackerSettingsCell else { return UICollectionViewCell() }
            cell.delegate = settingsCellDelegate
            cell.setupTitle(title: titles[indexPath.row])
            
            if indexPath.row > 0 {
                cell.setupCellSeparator()
            }
            
            if indexPath.row == 0 && !categorySubtitles.isEmpty {
                cell.setupCellSubtitle(subtitle: categorySubtitles)
            }
            
            if indexPath.row == 1 && !scheduleSubtitles.isEmpty {
                cell.setupCellSubtitle(subtitle: scheduleSubtitles)
            }
            
            return cell
            
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerEmojieCell.reuseIdentifier, for: indexPath) as? TrackerEmojieCell else { return UICollectionViewCell() }
            cell.emojieCellDelegate = emojieCelldelegate
            cell.setupCellWithValuesOf(item: item)
            cell.cellIsSelected = indexPath.item == emojieSelectedItem
            return cell
            
        case 3:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerColorsCell.reuseIdentifier, for: indexPath) as? TrackerColorsCell else { return UICollectionViewCell() }
            cell.colorCellDelegate = colorCellDelegate
            cell.colorLabel.backgroundColor = colorModel.getColor(for: indexPath.row)
            cell.cellIsSelected = indexPath.item == colorSelectedItem
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}
