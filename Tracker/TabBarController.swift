//
//  ViewController.swift
//  Tracker
//
//  Created by Никита on 21.02.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    
    let trackerViewController = UINavigationController(rootViewController: TrackersViewController())
    
    let statisticViewController = UINavigationController(rootViewController: StatisticViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let statTitle = NSLocalizedString("statistics", comment: "statistics")
        let trackTitle = NSLocalizedString("trackersTitle", comment: "trackersTitle")
        trackerViewController.tabBarItem = UITabBarItem(title: trackTitle, image: UIImage(named: "record.circle.fill"), selectedImage: nil)
        statisticViewController.tabBarItem = UITabBarItem(title: statTitle, image: UIImage(named: "hare.fill"), selectedImage: nil)
        tabBar.layer.borderWidth = 0.3
        tabBar.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        tabBar.clipsToBounds = true
        
        self.viewControllers = [trackerViewController, statisticViewController]
    }
}

