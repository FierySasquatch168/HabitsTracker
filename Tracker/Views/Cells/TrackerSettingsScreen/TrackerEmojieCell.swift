//
//  TrackerEmojieCell.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 27.03.2023.
//

import UIKit

final class TrackerEmojieCell: UICollectionViewCell {    
    lazy var emojieLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: CustomFonts.YPBold.rawValue, size: 32)
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        return label
    }()
    
    var cellIsSelected: Bool = false {
        didSet {
            emojieLabel.backgroundColor = cellIsSelected ? .YPLightGray : .clear
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupCellWithValuesOf(item: AnyHashable) {
        emojieLabel.text = item.description
    }
}

// MARK: - Constraints
private extension TrackerEmojieCell {
    func setupUI() {
        addSubview(emojieLabel)
        emojieLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojieLabel.topAnchor.constraint(equalTo: topAnchor),
            emojieLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            emojieLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            emojieLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
