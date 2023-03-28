//
//  TrackerColorsCell.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 27.03.2023.
//

import UIKit

final class TrackerColorsCell: UICollectionViewCell {
    lazy var colorImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(colorImage)
        colorImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorImage.topAnchor.constraint(equalTo: topAnchor),
            colorImage.bottomAnchor.constraint(equalTo: bottomAnchor),
            colorImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorImage.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
