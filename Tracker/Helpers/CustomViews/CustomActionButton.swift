//
//  CustomActionButton.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 26.03.2023.
//

import UIKit

final class CustomActionButton: UIButton {

    init(title: String, backGroundColor: UIColor?, titleColor: UIColor?) {
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        layer.cornerRadius = 16
        titleLabel?.font = UIFont(name: CustomFonts.YPMedium.rawValue, size: 16)
        setTitleColor(titleColor, for: .normal)
        backgroundColor = backGroundColor
        titleLabel?.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
