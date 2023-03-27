//
//  CustomHeaderLabel.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 27.03.2023.
//

import UIKit

class CustomHeaderLabel: UILabel {

    init(headerText: String) {
        super.init(frame: .zero)
        textColor = .YPBlack
        font = UIFont(name: CustomFonts.YPMedium.rawValue, size: 16)
        text = headerText
        textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
