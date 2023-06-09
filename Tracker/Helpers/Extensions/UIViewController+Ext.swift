//
//  UIViewController+Ext.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 26.03.2023.
//

import UIKit

protocol Presentable {
    func toPresent() -> UIViewController?
}

extension UIViewController: Presentable {
    func toPresent() -> UIViewController? {
        return self
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround(completion: (() -> Void)? = nil) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
