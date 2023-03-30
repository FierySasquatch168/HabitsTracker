//
//  TrackerTimeTableCell.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 30.03.2023.
//

import UIKit

final class TrackerTimeTableCell: UICollectionViewCell {
//    var switchToggled: ((String?) -> Void)?
    private lazy var weekDayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .YPBlack
        label.font = UIFont(name: CustomFonts.YPRegular.rawValue, size: 17)
        return label
    }()
    
    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = .YPBlue
        switcher.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWeekday(title: String, for row: Int) {
        weekDayLabel.text = title
        
        if row > 0 {
            installSeparator()
        }
    }
    
    @objc
    private func switchValueChanged() {
        // doesn't work
//        switchToggled?(weekDayLabel.text)
        print("it works!")
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
