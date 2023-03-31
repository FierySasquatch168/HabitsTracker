//
//  TrackersListCollectionViewCell.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 23.03.2023.
//

import UIKit

final class TrackersListCollectionViewCell: UICollectionViewCell {
    
    lazy var cellBackgroundColor: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var emojie: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var trackerName: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var daysLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var plusButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        
        stackView.addArrangedSubview(daysLabel)
        stackView.addArrangedSubview(plusButton)
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Constraints
extension TrackersListCollectionViewCell {
    
}
