//
//  TrackerColorsCell.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 27.03.2023.
//

import UIKit

protocol ColorCellDelegate: AnyObject {
    func didSelectColor(color: UIColor?)
}

final class TrackerColorsCell: UICollectionViewCell {
    weak var colorCellDelegate: ColorCellDelegate?
    
    lazy var colorLabelBackgroundColor: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 4
        imageView.backgroundColor = .YPWhite
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var colorLabel: UILabel = {
        let label = UILabel()
        // color
        label.backgroundColor = .clear
        // layer
        label.layer.cornerRadius = 8
        label.layer.borderWidth = 3
        label.layer.borderColor = UIColor.clear.cgColor
        label.layer.masksToBounds = true
        
        return label
    }()
    
    var cellIsSelected: Bool = false {
        didSet {
            layer.borderColor = cellIsSelected ? UIColor.YPLightGray?.cgColor : UIColor.clear.cgColor
            layer.borderWidth = cellIsSelected ? 3 : 0
            sendColorIfSelected()
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
    
    private func sendColorIfSelected() {
        if cellIsSelected {
            colorCellDelegate?.didSelectColor(color: colorLabel.backgroundColor)
        }
    }
}

// MARK: - Constraints
private extension TrackerColorsCell {
    func setupConstraints() {
        setupBackgroundView()
        setupColorButton()
    }
    
    func setupBackgroundView() {
        contentView.addSubview(colorLabelBackgroundColor)
        colorLabelBackgroundColor.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorLabelBackgroundColor.topAnchor.constraint(equalTo: topAnchor),
            colorLabelBackgroundColor.bottomAnchor.constraint(equalTo: bottomAnchor),
            colorLabelBackgroundColor.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorLabelBackgroundColor.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func setupColorButton() {
        contentView.addSubview(colorLabel)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorLabel.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            colorLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            colorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            colorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6)
        ])
    }
}
