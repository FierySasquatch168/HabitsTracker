//
//  TrackerSelectionViewController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 25.03.2023.
//

import UIKit

class TrackerSelectionViewController: UIViewController {
    
    var returnOnCancel: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Создание трекера"
        
    }
}
