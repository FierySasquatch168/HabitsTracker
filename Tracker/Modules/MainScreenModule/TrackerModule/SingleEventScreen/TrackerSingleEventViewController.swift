//
//  TrackerSingleEventViewController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 26.03.2023.
//

import UIKit

protocol TrackerSingleEventToCoordinatorProtocol {
    var returnOnCancel: (() -> Void)? { get set }
}

final class TrackerSingleEventViewController: UIViewController & TrackerSingleEventToCoordinatorProtocol {
    var returnOnCancel: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        presentationController?.delegate = self
        // Do any additional setup after loading the view.
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension TrackerSingleEventViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        returnOnCancel?()
    }
}
