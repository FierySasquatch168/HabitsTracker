//
//  StatisticsTableViewCell.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 02.06.2023.
//

import UIKit

final class StatisticsTableViewCell: UITableViewCell {    
    private lazy var cellCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: CustomFonts.YPBold.rawValue, size: 34)
        return label
    }()
    
    private lazy var cellTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: CustomFonts.YPMedium.rawValue, size: 12)
        return label
    }()
    
    private var gradientImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.addArrangedSubview(cellCountLabel)
        stackView.addArrangedSubview(cellTitleLabel)
        stackView.backgroundColor = .systemBackground
        stackView.layer.cornerRadius = 16
        stackView.spacing = 7
        stackView.layoutMargins = UIEdgeInsets(top: 11, left: 11, bottom: 11, right: 11)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = [
            UIColorMarshalling.color(from: "FD4C49").cgColor,
            UIColorMarshalling.color(from: "46E69D").cgColor,
            UIColorMarshalling.color(from: "007BFA").cgColor
        ]
        
        return gradientLayer
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }
}

// MARK: - Cell configuration
extension StatisticsTableViewCell {
    func setupCellWithValues(count: Int, title: String) {
        cellCountLabel.text = "\(count)"
        cellTitleLabel.text = title
    }
}

// MARK: - Ext CellBorders Gradient
private extension StatisticsTableViewCell {
    func setupLayout() {
        layer.cornerRadius = 16
        gradientImageView.layer.addSublayer(gradientLayer)
        gradientLayer.frame = gradientImageView.bounds
    }
}

// MARK: - Ext Constraints
private extension StatisticsTableViewCell {
    func setupConstraints() {
        setupGradientImageView()
        setupMainStackView()
        
    }
    
    func setupMainStackView() {
        addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1)
        ])
    }
    
    func setupGradientImageView() {
        addSubview(gradientImageView)
        gradientImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            gradientImageView.topAnchor.constraint(equalTo: topAnchor),
            gradientImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
