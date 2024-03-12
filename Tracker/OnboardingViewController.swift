//
//  Onboarding.swift
//  Tracker
//
//  Created by Никита on 09.03.2024.
//

import Foundation
import UIKit

final class OnboardingViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    private lazy var pages: [UIViewController] = {
        return[blueViewController, redViewController]
    }()
    
    private lazy var redViewController: UIViewController = {
        let redViewController = UIViewController()
        let image = "background_red"
        redViewController.view.addBackground(image: image)
        return redViewController
    }()
    
    private lazy var blueViewController: UIViewController = {
        let blueViewController = UIViewController()
        let image = "background_blue"
        blueViewController.view.addBackground(image: image)
        return blueViewController
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = UIColor.ypBlack.withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var blueViewControllerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "Отслеживайте только то, что хотите"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var buttonOnBlueViewController: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(enterButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var redViewControllerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "Даже если это не литры воды и йога"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var buttonOnRedViewController: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(enterButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let first = pages.first { setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        addBlueViewController()
        addRedViewController()
        addPageControl()
    }
    
    private func addBlueViewController() {
        blueViewController.view.addSubview(blueViewControllerLabel)
        blueViewController.view.addSubview(buttonOnBlueViewController)
        
        NSLayoutConstraint.activate([
            blueViewControllerLabel.bottomAnchor.constraint(equalTo: blueViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -290),
            blueViewControllerLabel.centerXAnchor.constraint(equalTo: blueViewController.view.safeAreaLayoutGuide.centerXAnchor),
            blueViewControllerLabel.widthAnchor.constraint(equalToConstant: 343),
            
            buttonOnBlueViewController.heightAnchor.constraint(equalToConstant: 60),
            buttonOnBlueViewController.leadingAnchor.constraint(equalTo: blueViewController.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonOnBlueViewController.trailingAnchor.constraint(equalTo: blueViewController.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonOnBlueViewController.bottomAnchor.constraint(equalTo: blueViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -71)
        ])
    }
    
    private func addRedViewController() {
        redViewController.view.addSubview(redViewControllerLabel)
        redViewController.view.addSubview(buttonOnRedViewController)
        
        NSLayoutConstraint.activate([
            redViewControllerLabel.bottomAnchor.constraint(equalTo: redViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -290),
            redViewControllerLabel.centerXAnchor.constraint(equalTo: redViewController.view.safeAreaLayoutGuide.centerXAnchor),
            redViewControllerLabel.widthAnchor.constraint(equalToConstant: 343),
            
            buttonOnRedViewController.heightAnchor.constraint(equalToConstant: 60),
            buttonOnRedViewController.leadingAnchor.constraint(equalTo: redViewController.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonOnRedViewController.trailingAnchor.constraint(equalTo: redViewController.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonOnRedViewController.bottomAnchor.constraint(equalTo: redViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -71)
        ])
    }
    
    private func addPageControl() {
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -155),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func enterButtonAction() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        window.rootViewController = TabBarController()
        UserDefaults.standard.set(true, forKey: "isOnboardingShown")
    }
        
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
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

extension UIView {
    
    func addBackground(image: String) {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, width, height))
        imageViewBackground.image = UIImage(named: image)
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
}
