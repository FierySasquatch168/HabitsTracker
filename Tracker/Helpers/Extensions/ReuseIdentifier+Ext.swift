//
//  ReuseIdentifier.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 23.03.2023.
//

import UIKit

extension UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
