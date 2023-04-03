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
    var subtitles: String { get set }
    func createDataSource(collectionView: UICollectionView)
    func getTitle() -> String
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
    
    // initialized after user picks up timetable
    var subtitles: String = ""
    
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
        
        dataSource?.apply(createSnapshot())
    }
}

// MARK: - Ext Snapshot
private extension DataSourceManager {
    func createSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.trackerName, .trackerSettings, .emojies, .colors])
        snapshot.appendItems([""], toSection: .trackerName)
        snapshot.appendItems(titles, toSection: .trackerSettings)
        
        snapshot.appendItems(emojieModel.emojies, toSection: .emojies)
        snapshot.appendItems(colorModel.colors, toSection: .colors)
        print("createSnapshot finished")
        return snapshot
    }
}

// MARK: - Ext Cell creation
private extension DataSourceManager {
    func cell(collectionView: UICollectionView, indexPath: IndexPath, item: AnyHashable) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerNameCell.reuseIdentifier, for: indexPath) as? TrackerNameCell else { return UICollectionViewCell() }
            cell.delegate = trackerNameCellDelegate
            cell.setupUI()
            return cell
            
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerSettingsCell.reuseIdentifier, for: indexPath) as? TrackerSettingsCell else { return UICollectionViewCell() }
            cell.delegate = settingsCellDelegate
            cell.setupTitle(title: titles[indexPath.row])
            
            if indexPath.row > 0 {
                cell.setupCellSeparator()
                print("indexPath.row = \(indexPath.row), cellSeparator is set up")
            }
            
            if indexPath.row == 1 && !subtitles.isEmpty {
                cell.setupCellSubtitle(subtitle: subtitles)
            }
            return cell
            
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerEmojieCell.reuseIdentifier, for: indexPath) as? TrackerEmojieCell else { return UICollectionViewCell() }
            cell.emojieCellDelegate = emojieCelldelegate
            cell.setupCellWithValuesOf(item: item)
            return cell
            
        case 3:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerColorsCell.reuseIdentifier, for: indexPath) as? TrackerColorsCell else { return UICollectionViewCell() }
            cell.colorCellDelegate = colorCellDelegate
            cell.colorLabel.backgroundColor = colorModel.getColor(for: indexPath.row)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}
