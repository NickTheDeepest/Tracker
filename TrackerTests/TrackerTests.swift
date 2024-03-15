//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Никита on 13.03.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackersVCLight() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let vc = TabBarController()
        window.rootViewController = vc
        window.makeKeyAndVisible()
        
        let trackersVC = (vc.children.first as? UINavigationController)?.viewControllers.first
        print(String(describing: trackersVC))
        guard let view = trackersVC?.view else { return }
        assertSnapshot(matching: view, as: .image)
    }
}
