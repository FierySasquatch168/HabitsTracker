//
//  TrackerNameCell.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 27.03.2023.
//

import UIKit

final class TrackerNameCell: UICollectionViewCell {
    
    private lazy var textField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Введите название трекера"
        textField.textInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        textField.backgroundColor = .YPBackground
        textField.font = UIFont(name: CustomFonts.YPRegular.rawValue, size: 17)
        textField.contentVerticalAlignment = .center
        textField.contentHorizontalAlignment = .left
        textField.layer.cornerRadius = 10
        return textField
    }()
    
    func setupUI() {
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
    }
    
}
