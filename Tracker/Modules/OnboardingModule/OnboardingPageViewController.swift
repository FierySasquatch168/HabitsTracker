//
//  OnboardingController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 07.05.2023.
//

import UIKit

protocol OnboardingProtocol {
    var onFinish: (() -> Void)? { get set }
}

final class OnboardingPageViewController: UIPageViewController, OnboardingProtocol {
    var onFinish: (() -> Void)?
    
    private lazy var pageControl: UIPageControl = {
       let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .YPBlack
        pageControl.pageIndicatorTintColor = .YPBlack?.withAlphaComponent(0.3)
        return pageControl
    }()
    
    private lazy var finishButton: CustomActionButton = {
        let button = CustomActionButton(title: "Вот это технологии!", appearance: .confirm)
        button.addTarget(self, action: #selector(finishdButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var pages: [UIViewController] = [
        OnboardingViewController(color: .blue),
        OnboardingViewController(color: .red)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        dataSource = self
        delegate = self
        setPageViewControllers()
        setupConstraints()
        
    }
    
    private func setPageViewControllers() {
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true)
        }
    }
    
    private func setupConstraints() {
        setupPageControl()
        setupFinishButton()
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return pages.last
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return pages.first
        }
        
        return pages[nextIndex]
    }
    
    
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

@objc private extension OnboardingPageViewController {
     func finishdButtonTapped() {
        onFinish?()
    }
}

private extension OnboardingPageViewController {
    func setupPageControl() {
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
    }
    
    func setupFinishButton() {
        view.addSubview(finishButton)
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            finishButton.heightAnchor.constraint(equalToConstant: 60),
            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70)
        ])
    }
}
