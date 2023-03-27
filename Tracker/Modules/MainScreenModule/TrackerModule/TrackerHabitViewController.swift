//
//  TrackerHabitViewController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 26.03.2023.
//

import UIKit

protocol TrackerHabitToCoordinatorProtocol {
    var returnOnCancel: (() -> Void)? { get set }
}

final class TrackerHabitViewController: UIViewController & TrackerHabitToCoordinatorProtocol {
    var returnOnCancel: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
        presentationController?.delegate = self
        // Do any additional setup after loading the view.
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension TrackerHabitViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        returnOnCancel?()
    }
}
