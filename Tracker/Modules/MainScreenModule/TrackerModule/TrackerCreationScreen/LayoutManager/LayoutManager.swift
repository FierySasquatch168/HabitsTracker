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
    var titles: [String]
    
    init(headerCreator: HeaderCreatorProtocol, settings: [String]) {
        self.headerCreator = headerCreator
        self.titles = settings
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            return self?.sectionFor(index: sectionIndex, environment: environment, headers: Sections.allCases)
        }
    }
}

// MARK: - Ext Sections creation
private extension LayoutManager {
    func sectionFor(index: Int, environment: NSCollectionLayoutEnvironment, headers: [Sections]) -> NSCollectionLayoutSection {
        let section = Sections.allCases[index]
        switch section {
        case .trackerName:
            return createTextFieldSection()
        case .trackerSettings:
            return createCategorieSection()
        case .emojies:
            return createEmojieSection()
        case .colors:
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
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/CGFloat(titles.count))))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(75 * CGFloat(titles.count))), subitems: [item])
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
