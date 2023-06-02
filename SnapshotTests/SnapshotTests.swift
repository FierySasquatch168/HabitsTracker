//
//  SnapshotTests.swift
//  SnapshotTests
//
//  Created by Aleksandr Eliseev on 31.05.2023.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class SnapshotTests: XCTestCase {

    func testViewControllerLightMode() {
        let dataStore = DataStoreMock()
        let viewModel = TrackersViewModel(dataStore: dataStore)
        let vc = TrackersViewController(viewModel: viewModel)
        let trackerCreationVC = TrackerCreationVCSpy()
        trackerCreationVC.trackerMainScreenDelegate = viewModel
        
        trackerCreationVC.saveTracker()
        
        assertSnapshots(matching: vc, as: [.image(traits: .init(userInterfaceStyle: .light))])
    }
    
    func testViewControllerDarkMode() {
        let dataStore = DataStoreMock()
        let viewModel = TrackersViewModel(dataStore: dataStore)
        let vc = TrackersViewController(viewModel: viewModel)
        let trackerCreationVC = TrackerCreationVCSpy()
        trackerCreationVC.trackerMainScreenDelegate = viewModel
        
        trackerCreationVC.saveTracker()
        
        assertSnapshots(matching: vc, as: [.image(traits: .init(userInterfaceStyle: .dark))])
    }
}



