//
//  FirstCollectionViewCell.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 23.03.2023.
//

import UIKit

class FirstCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
