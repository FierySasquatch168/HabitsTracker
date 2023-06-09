//
//  SplashViewController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 24.03.2023.
//

import UIKit

final class SplashViewController: UIViewController {
    weak var coordinator: CoordinatorProtocol?
    
    private lazy var splashImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: K.Icons.splashImage)
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVcUI()
        setupSplashImageView()
    }
}

private extension SplashViewController {
    func configureVcUI() {
        view.backgroundColor = .YPBlue
    }
    
    func setupSplashImageView() {
        view.addSubview(splashImageView)
        splashImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
