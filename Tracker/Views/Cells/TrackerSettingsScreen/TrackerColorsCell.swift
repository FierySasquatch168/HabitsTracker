//
//  TrackerColorsCell.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 27.03.2023.
//

import UIKit

final class TrackerColorsCell: UICollectionViewCell {
    lazy var colorLabel: UILabel = {
        let label = UILabel()
        // color
        label.backgroundColor = .clear
        // layer
        label.layer.cornerRadius = 8
        label.layer.borderWidth = 3
        label.layer.borderColor = UIColor.YPBlack?.cgColor
        label.layer.masksToBounds = true
        
        return label
    }()
    
    var cellIsSelected: Bool = false {
        didSet {
            layer.borderColor = cellIsSelected ? UIColor.YPLightGray?.cgColor : UIColor.clear.cgColor
            layer.borderWidth = cellIsSelected ? 3 : 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Constraints
private extension TrackerColorsCell {
    func setupConstraints() {
        setupColorButton()
    }
    
    func setupColorButton() {
        contentView.addSubview(colorLabel)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorLabel.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            colorLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            colorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            colorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3)
        ])
    }
}
