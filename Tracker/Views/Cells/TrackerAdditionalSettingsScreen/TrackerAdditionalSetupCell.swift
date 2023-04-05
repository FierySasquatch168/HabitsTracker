//
//  TrackerAdditionalSetupCell.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 30.03.2023.
//

import UIKit

protocol TrackerTimeTableCellDelegate: AnyObject {
    func didToggleSwitch(text: String?)
}

final class TrackerAdditionalSetupCell: UICollectionViewCell {
    weak var trackerTimeTableCellDelegate: TrackerTimeTableCellDelegate?
    
    var switchToggled: Bool = false {
        didSet {
            trackerTimeTableCellDelegate?.didToggleSwitch(text: cellTextLabel.text)
        }
    }
    
    private lazy var cellTextLabel: UILabel = {
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
    
    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .YPBlue
        imageView.image = UIImage(systemName: Constants.Icons.checkmark)
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var timetableStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.addArrangedSubview(cellTextLabel)
        stackView.addArrangedSubview(switcher)
        
        return stackView
    }()
    
    private lazy var categoryStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.addArrangedSubview(cellTextLabel)
        stackView.addArrangedSubview(checkImageView)
        return stackView
    }()
    
    private lazy var cellSeparator: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "BottomDivider")
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override var isSelected: Bool {
        didSet {
            checkImageView.isHidden = isSelected ? false : true
        }
    }
    
    func configTimeTableCell(title: String, for row: Int, timetableSelected: Bool) {
        cellTextLabel.text = title
        
        if row > 0 {
            installSeparator()
        }
        
        timetableSelected ? setupTimeTableConstraints() : setupCategoryConstraints()
        
    }
    
    @objc
    private func toggleSwitch(_ sender: UISwitch) {
        switchToggled = sender.isOn
    }
}

// MARK: - Separator installation
private extension TrackerAdditionalSetupCell {
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
private extension TrackerAdditionalSetupCell {
    func setupTimeTableConstraints() {
        setupTimetableStackView()
    }
    
    func setupTimetableStackView() {
        addSubview(timetableStackView)
        timetableStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timetableStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            timetableStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            timetableStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}

private extension TrackerAdditionalSetupCell {
    func setupCategoryConstraints() {
        setupCategoryStackView()
    }
    
    func setupCategoryStackView() {
        addSubview(categoryStackView)
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryStackView.topAnchor.constraint(equalTo: topAnchor),
            categoryStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            categoryStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            categoryStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
