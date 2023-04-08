//
//  CustomActionButton.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 26.03.2023.
//

import UIKit

final class CustomActionButton: UIButton {

    init(title: String, appearance: Appearance) {
        super.init(frame: .zero)
        setAppearance(for: appearance)
        setTitle(title, for: .normal)
        layer.cornerRadius = 16
        titleLabel?.font = UIFont(name: CustomFonts.YPMedium.rawValue, size: 16)
        titleLabel?.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomActionButton {
    func setAppearance(for appearance: Appearance) {
        switch appearance {
        case .disabled:
            setTitleColor(.YPBlack, for: .normal)
            backgroundColor = .YPGray
            isEnabled = false
        case .confirm:
            setTitleColor(.YPWhite, for: .normal)
            backgroundColor = .YPBlack
            isEnabled = true
        case .cancel:
            setTitleColor(.YPRed, for: .normal)
            backgroundColor = .YPWhite
            layer.borderWidth = 1
            layer.borderColor = UIColor.YPRed?.cgColor
            isEnabled = true
        }
        
    }
}

extension CustomActionButton {
    enum Appearance {
        case disabled, confirm, cancel
    }
}
