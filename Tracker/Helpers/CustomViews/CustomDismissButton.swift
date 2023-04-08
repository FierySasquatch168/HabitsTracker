//
//  CustomDismissButton.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 26.03.2023.
//

import UIKit

final class CustomDismissButton: UIButton {

    init() {
        super.init(frame: .zero)
        let image = UIImage(systemName: Constants.Icons.xmark)
        setImage(image, for: .normal)
        tintColor = .YPBlack
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
