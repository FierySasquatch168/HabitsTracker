//
//  TrackerCategoryScreen.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 31.03.2023.
//

import UIKit

protocol TrackerCategoryToCoordinatorProtocol {
    var returnOnCancel: (() -> Void)? { get set }
}

final class TrackerCategoryScreen: UIViewController & TrackerCategoryToCoordinatorProtocol {
    var returnOnCancel: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
        presentationController?.delegate = self
    }
}

// MARK: - Ext UIAdaptivePresentationControllerDelegate
extension TrackerCategoryScreen: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        returnOnCancel?()
    }
}
