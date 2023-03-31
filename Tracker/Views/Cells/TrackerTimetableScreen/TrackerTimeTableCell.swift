//
//  TrackerTimeTableCell.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 30.03.2023.
//

import UIKit

protocol TrackerTimeTableCellDelegate: AnyObject {
    func didToggleSwitch(text: String?)
}

final class TrackerTimeTableCell: UICollectionViewCell {
    weak var delegate: TrackerTimeTableCellDelegate?
    
    var switchToggled: Bool = false {
        didSet {
            delegate?.didToggleSwitch(text: weekDayLabel.text)
        }
    }
    
    private lazy var weekDayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .YPBlack
        label.font = UIFont(name: CustomFonts.YPRegular.rawValue, size: 17)
        return label
    }()
    
    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = .YPBlue
        switcher.addTarget(self, action: #selector(toggleSwitch), for: .valueChanged)
        return switcher
    }()
    
    private lazy var mainStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.addArrangedSubview(weekDayLabel)
        stackView.addArrangedSubview(switcher)
        
        return stackView
    }()
    
    private lazy var cellSeparator: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "BottomDivider")
        imageView.clipsToBounds = true
        return imageView
    }()
    
    func configCellWith(title: String, for row: Int) {
        weekDayLabel.text = title
        
        if row > 0 {
            installSeparator()
        }
        
        setupConstraints()
    }
    
    @objc
    private func toggleSwitch(_ sender: UISwitch) {
        switchToggled = sender.isOn
    }
}

// MARK: - Separator installation
private extension TrackerTimeTableCell {
    // is set up from collectionView when separator is needed
    func installSeparator() {
        contentView.addSubview(cellSeparator)
        cellSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellSeparator.topAnchor.constraint(equalTo: topAnchor),
            cellSeparator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            cellSeparator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            cellSeparator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

// MARK: - Constraints
private extension TrackerTimeTableCell {
    func setupConstraints() {
        setupStackView()
    }
    
    func setupStackView() {
        addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
