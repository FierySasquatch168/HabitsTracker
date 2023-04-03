//
//  LayoutManager.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 29.03.2023.
//

import UIKit

protocol LayoutManagerProtocol {
    var headerCreator: HeaderCreatorProtocol { get set }
    func createCompositionalLayout() -> UICollectionViewLayout
}

final class LayoutManager: LayoutManagerProtocol, LayoutDataProtocol {
    var headerCreator: HeaderCreatorProtocol
    var headers: [String]
    var settings: [String]
    
    init(headerCreator: HeaderCreatorProtocol, headers: [String], settings: [String]) {
        self.headerCreator = headerCreator
        self.headers = headers
        self.settings = settings
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            return self?.sectionFor(index: sectionIndex, environment: environment, headers: self?.headers ?? [""])
        }
    }
}

// MARK: - Ext Sections creation
private extension LayoutManager {
    func sectionFor(index: Int, environment: NSCollectionLayoutEnvironment, headers: [String]) -> NSCollectionLayoutSection {
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
    
    func createTextFieldSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(75)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.bottom = 24
        return section
    }
    
    func createCategorieSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/CGFloat(settings.count))))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(75 * CGFloat(settings.count))), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: RoundedBackgroundView.reuseIdentifier)
        section.decorationItems = [decorationItem]
        return section
    }
    
    func createEmojieSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/7), heightDimension: .fractionalWidth(1/7)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(144)), subitems: [item])
        group.interItemSpacing = NSCollectionLayoutSpacing.flexible(10)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.top = 60
        headerCreator.addStandardHeader(to: section)
        
        return section
    }
    
    func createColorSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/7), heightDimension: .fractionalWidth(1/7)))
        item.contentInsets.bottom = 1
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(144)), subitems: [item])
        group.interItemSpacing = NSCollectionLayoutSpacing.flexible(1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.top = 70
        headerCreator.addStandardHeader(to: section)
        return section
    }
}
