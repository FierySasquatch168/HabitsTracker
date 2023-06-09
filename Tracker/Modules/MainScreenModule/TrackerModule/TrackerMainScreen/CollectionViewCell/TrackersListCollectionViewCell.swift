//
//  TrackersListCollectionViewCell.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 23.03.2023.
//

import UIKit

protocol TrackersListCollectionViewCellDelegate: AnyObject {
    func plusTapped(trackerID: String?)
}

final class TrackersListCollectionViewCell: UICollectionViewCell {
    weak var trackersListCellDelegate: TrackersListCollectionViewCellDelegate?
    
    var trackerID: String?
    
    lazy var cellBackgroundColorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 13
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var emojieLabel: UILabel = {
        let label = UILabel()
        // text
        label.font = UIFont(name: CustomFonts.YPMedium.rawValue, size: 16)
        label.textAlignment = .center
        // layer
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.backgroundColor = .YPEmojiBackground
        return label
    }()
    
    lazy var trackerNameLabel: UILabel = {
        let label = UILabel()
        // text
        label.font = UIFont(name: CustomFonts.YPMedium.rawValue, size: 12)
        label.textColor = .YPBlack
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    lazy var daysLabel: UILabel = {
        let label = UILabel()
        // text
        label.font = UIFont(name: CustomFonts.YPMedium.rawValue, size: 12)
        label.textColor = .YPBlack
        return label
    }()
    
    lazy var plusButton: UIButton = {
        let button = UIButton()
        // image
        button.setImage(UIImage(systemName: K.Icons.plus), for: .normal)
        button.tintColor = .YPWhite
        button.clipsToBounds = true
        // layer
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        // target
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
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
    
    var daysAmount: Int? {
        didSet {
            if let daysAmount {
                let daysString = String.localizedStringWithFormat(
                    NSLocalizedString("numberOfDays", comment: "Number of days when the tracker was completed"),
                    daysAmount)
                daysLabel.text = daysString
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell(with tracker: Tracker, image: UIImage, count: Int) {
        trackerID = tracker.stringID
        emojieLabel.text = tracker.emoji
        cellBackgroundColorImageView.backgroundColor = tracker.color
        trackerNameLabel.text = tracker.name
        plusButton.backgroundColor = tracker.color
        
        plusButton.setImage(image, for: .normal)
        daysAmount = count
    }
}

// MARK: - Ext @objc func
private extension TrackersListCollectionViewCell {
    @objc func plusButtonTapped(_ sender: UIButton) {
        trackersListCellDelegate?.plusTapped(trackerID: trackerID)
    }
}

// MARK: - Ext Constraints
private extension TrackersListCollectionViewCell {
    func setupConstraints() {
        setupBackgroundColorImageView()
        setupBottomStackView()
    }
    
    func setupBackgroundColorImageView() {
        addSubview(cellBackgroundColorImageView)
        cellBackgroundColorImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellBackgroundColorImageView.topAnchor.constraint(equalTo: topAnchor),
            cellBackgroundColorImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellBackgroundColorImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellBackgroundColorImageView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        cellBackgroundColorImageView.addSubview(emojieLabel)
        
        emojieLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojieLabel.topAnchor.constraint(equalTo: cellBackgroundColorImageView.topAnchor, constant: 12),
            emojieLabel.leadingAnchor.constraint(equalTo: cellBackgroundColorImageView.leadingAnchor, constant: 12),
            emojieLabel.heightAnchor.constraint(equalToConstant: 24),
            emojieLabel.widthAnchor.constraint(equalToConstant: 24)
        ])
        
        cellBackgroundColorImageView.addSubview(trackerNameLabel)
        
        trackerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trackerNameLabel.topAnchor.constraint(equalTo: cellBackgroundColorImageView.topAnchor, constant: 44),
            trackerNameLabel.leadingAnchor.constraint(equalTo: cellBackgroundColorImageView.leadingAnchor, constant: 12),
            trackerNameLabel.trailingAnchor.constraint(equalTo: cellBackgroundColorImageView.trailingAnchor, constant: -12),
            trackerNameLabel.bottomAnchor.constraint(equalTo: cellBackgroundColorImageView.bottomAnchor, constant: -12)
        ])
        
    }
    
    func setupBottomStackView() {
        addSubview(bottomStackView)
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // stackView
            bottomStackView.topAnchor.constraint(equalTo: cellBackgroundColorImageView.bottomAnchor, constant: 8),
            bottomStackView.heightAnchor.constraint(equalToConstant: 34),
            bottomStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            bottomStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            //buttonSize
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
}
