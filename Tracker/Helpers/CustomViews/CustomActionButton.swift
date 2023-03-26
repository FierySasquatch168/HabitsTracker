//
//  CustomActionButton.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 26.03.2023.
//

import UIKit

class CustomActionButton: UIButton {

    init(title: String) {
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        layer.cornerRadius = 16
        titleLabel?.font = UIFont(name: CustomFonts.YPMedium.rawValue, size: 16)
        setTitleColor(.YPWhite, for: .normal)
        backgroundColor = .YPBlack
        titleLabel?.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
