//
//  RoundedBackgroundView.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 28.03.2023.
//

import UIKit

final class RoundedBackgroundView: UICollectionReusableView {
    
    private var backgroundView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .YPBackground
            view.layer.cornerRadius = 10
            view.clipsToBounds = true
            return view
        }()
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            addSubview(backgroundView)

            NSLayoutConstraint.activate([
                backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
                backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
//                trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
                backgroundView.topAnchor.constraint(equalTo: topAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
