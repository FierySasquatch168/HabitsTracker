//
//  HeaderView.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 28.03.2023.
//

import UIKit

final class HeaderView: UICollectionReusableView {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .YPBlack
        label.textAlignment = .left
        label.font = UIFont(name: CustomFonts.YPBold.rawValue, size: 19)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
