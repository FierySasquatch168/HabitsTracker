//
//  HeaderCreator.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 29.03.2023.
//

import UIKit

protocol HeaderCreatorProtocol {
    func addStandardHeader(to section: NSCollectionLayoutSection)
}

struct HeaderCreator: HeaderCreatorProtocol {
    func addStandardHeader(to section: NSCollectionLayoutSection) {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(18))
        let headerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        headerElement.contentInsets.top = 30
        headerElement.contentInsets.bottom = 30
        section.boundarySupplementaryItems = [headerElement]
    }
}
