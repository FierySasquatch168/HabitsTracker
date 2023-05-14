//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 07.05.2023.
//

import UIKit

final class OnboardingViewController: UIViewController {
    lazy var backgroundImageView = UIImageView()
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        label.textColor = .stableBlack
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    init(color: OnboardingColor) {
        super.init(nibName: nil, bundle: nil)
        switch color {
        case .blue:
            backgroundImageView.image = UIImage(named: Constants.Icons.onboardingBackgroundBlue)
            textLabel.text = Constants.Strings.blueOnboardingText
        case .red:
            backgroundImageView.image = UIImage(named: Constants.Icons.onboardingBackgroundRed)
            textLabel.text = Constants.Strings.redOnboardingText
        }        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    
    func setupUI() {
        setupBackgroundImage()
        setupTextLabel()
    }
    

}

extension OnboardingViewController {
    enum OnboardingColor {
        case blue, red
    }
}

private extension OnboardingViewController {
    func setupTextLabel() {
        view.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
       
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 400),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -250)
        ])
    }
    
    func setupBackgroundImage() {
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
