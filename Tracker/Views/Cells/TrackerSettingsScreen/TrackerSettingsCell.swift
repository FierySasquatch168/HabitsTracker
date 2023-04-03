//
//  TrackerSettingsCell.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 27.03.2023.
//

import UIKit

protocol SettingsCellDelegate: AnyObject {
    func textDidChange(text: String?)
}

final class TrackerSettingsCell: UICollectionViewCell {
    weak var delegate: SettingsCellDelegate?
    
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.clipsToBounds = true
        imageView.tintColor = .YPBlack
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .YPBlack
        label.font = UIFont(name: CustomFonts.YPRegular.rawValue, size: 17)
        label.textAlignment = .left
        
        return label
    }()
    
    private lazy var subtitleLabel: UILabel =  {
        let label = UILabel()
        label.textAlignment =  .left
        label.font = UIFont(name: CustomFonts.YPRegular.rawValue, size: 17)
        label.textColor = .YPGray
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
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
    
    // MARK: Main func
    
    func setupTitle(title: String) {
        titleLabel.text = title
    }
    
    func setupCellSubtitle(subtitle: String) {
        subtitleLabel.text = subtitle
    }
    
    func setupCellSeparator(for row: Int) {
        if row > 0 {
            installSeparator()
        }
    }
}

// MARK: - Separator installation
private extension TrackerSettingsCell {
    // is set up from collectionView when separator is needed
    func installSeparator() {
        contentView.addSubview(cellSeparator)
        cellSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellSeparator.topAnchor.constraint(equalTo: topAnchor),
            cellSeparator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cellSeparator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            cellSeparator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

// MARK: - Constraints
private extension TrackerSettingsCell {
    
    func setupConstraints() {
        // wrap main label into stackview with secondary label hidden
        // show secondary label when titles are set
        setupTitleAndSubtitleStackView()
        setupImageView()
    }
    
    func setupTitleAndSubtitleStackView() {
        contentView.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // textView
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16),
        ])
    }
    
    func setupImageView() {
        contentView.addSubview(chevronImageView)
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // imageView
            chevronImageView.heightAnchor.constraint(equalToConstant: 18),
            chevronImageView.widthAnchor.constraint(equalToConstant: 11),
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
        ])
    }
}
