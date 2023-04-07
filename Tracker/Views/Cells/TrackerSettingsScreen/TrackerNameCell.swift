//
//  TrackerNameCell.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 27.03.2023.
//

import UIKit

protocol TrackerNameCellDelegate: AnyObject {
    func textDidChange(text: String?)
}

final class TrackerNameCell: UICollectionViewCell {
    weak var delegate: TrackerNameCellDelegate?
    
    private lazy var textField: CustomTextField = {
        let textField = CustomTextField()
        // view
        textField.backgroundColor = .YPBackground
        textField.layer.cornerRadius = 10
        // text
        textField.placeholder = "Введите название трекера"
        textField.textInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        textField.font = UIFont(name: CustomFonts.YPRegular.rawValue, size: 17)
        // alignment
        textField.contentVerticalAlignment = .center
        textField.contentHorizontalAlignment = .left
        // tools
        textField.clearButtonMode = .whileEditing
        
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - TextFieldDelegate
extension TrackerNameCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // TODO: fix the lack of last button
        if let delegate = delegate {
            // lacks last character of the text
            delegate.textDidChange(text: textField.text)
        }
        return true
    }
}

// MARK: - Constraints
extension TrackerNameCell {
    // gets called in CollectionView
    func setupUI() {
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
