//
//  ModulesFactory.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 25.03.2023.
//

import UIKit

// Nice place for DI

protocol ModulesFactoryProtocol {
    func makeSplashScreenView() -> Presentable
    func makeOnboardingScreenView() -> OnboardingProtocol & Presentable
    func makeTrackerScreenView() -> Presentable & TrackerToCoordinatorProtocol
    func makeTrackerSelectionScreenView() -> Presentable & TrackerSelectionCoordinatorProtocol
    func makeTrackerHabitScreenView(with mainScreenDelegate: TrackerMainScreenDelegate) -> Presentable & TrackerCreationToCoordinatorProtocol & AdditionalTrackerSetupProtocol
    func makeTrackerSingleEventScreenView(with mainScreenDelegate: TrackerMainScreenDelegate) -> Presentable & TrackerCreationToCoordinatorProtocol & AdditionalTrackerSetupProtocol
    func makeTrackerCategorieScreenView(timetableDelegate: AdditionalTrackerSetupProtocol?) -> Presentable & TrackerAdditionalSetupToCoordinatorProtocol
    func makeTimeTableScreenView(timetableDelegate: AdditionalTrackerSetupProtocol?) -> Presentable & TrackerAdditionalSetupToCoordinatorProtocol
    func makeStatisticsScreenView() -> Presentable
    func makeFiltersScreenView(filtersDelegate: FiltersDelegate?) -> Presentable & TrackerFilterSetupProtocol
}

final class ModulesFactory: ModulesFactoryProtocol {
    
    /// habit or singleEvent settings
    let habitSettings = HabitTrackerModel.settings
    let singleEventSettings = SingleEventTrackerModel.settings
    /// habit or singleEvent header
    let habitLabelText = HabitTrackerModel.title
    let singleEventLabeltext = SingleEventTrackerModel.title
    
    let context = Context()
    let analyticsService = AnalyticsService()
    
    func makeSplashScreenView() -> Presentable {
        return SplashViewController()
    }
    
    func makeOnboardingScreenView() -> OnboardingProtocol & Presentable {
        return OnboardingPageViewController()
    }
    
    func makeTrackerScreenView() -> Presentable & TrackerToCoordinatorProtocol {
        var dataStore: DataStoreProtocol = DataStore(context: context.context)
        let viewModel = TrackersViewModel(dataStore: dataStore)
        let trackerVC = TrackersViewController(viewModel: viewModel)
        trackerVC.analyticsService = analyticsService
        dataStore.dataStoreTrackersDelegate = viewModel
        return trackerVC
    }
    
    func makeStatisticsScreenView() -> Presentable {
        let dataStore: DataStoreStatisticsProviderProtocol = DataStore(context: context.context)
        let statisticsService = StatisticsService(dataStore: dataStore)
        let viewModel = StatisticsViewModel(statisticsService: statisticsService)
        return StatisticsViewController(viewModel: viewModel)
    }
    
    func makeTrackerSelectionScreenView() -> Presentable & TrackerSelectionCoordinatorProtocol {
        return TrackerSelectionViewController()
    }
    
    func makeTrackerHabitScreenView(with mainScreenDelegate: TrackerMainScreenDelegate) -> Presentable & TrackerCreationToCoordinatorProtocol & AdditionalTrackerSetupProtocol {
        let trackerCreationVC = TrackerCreationViewController()
        trackerCreationVC.mainScreenDelegate = mainScreenDelegate
        trackerCreationVC.layoutManager = LayoutManager(headerCreator: HeaderCreator(), settings: habitSettings)
        trackerCreationVC.dataSourceManager = DataSourceManager(emojieModel: EmojieModel(), colorModel: ColorModel(), settings: habitSettings, headerLabeltext: habitLabelText)
        
        return trackerCreationVC
    }
    
    func makeTrackerSingleEventScreenView(with mainScreenDelegate: TrackerMainScreenDelegate) -> Presentable & TrackerCreationToCoordinatorProtocol & AdditionalTrackerSetupProtocol {
        let trackerCreationVC = TrackerCreationViewController()
        trackerCreationVC.mainScreenDelegate = mainScreenDelegate
        trackerCreationVC.layoutManager = LayoutManager(headerCreator: HeaderCreator(), settings: singleEventSettings)
        trackerCreationVC.dataSourceManager = DataSourceManager(emojieModel: EmojieModel(), colorModel: ColorModel(), settings: singleEventSettings, headerLabeltext: singleEventLabeltext)
        
        return trackerCreationVC
    }
    
    func makeTrackerCategorieScreenView(timetableDelegate: AdditionalTrackerSetupProtocol?) -> Presentable & TrackerAdditionalSetupToCoordinatorProtocol {
        let categoryScreenVC = TrackerAdditionalSetupViewController()
        categoryScreenVC.additionalSetupCase = .category(timetableDelegate?.selectedCategory)
        categoryScreenVC.additionalTrackerSetupDelegate = timetableDelegate
        return categoryScreenVC
    }
    
    func makeTimeTableScreenView(timetableDelegate: AdditionalTrackerSetupProtocol?) -> Presentable & TrackerAdditionalSetupToCoordinatorProtocol {
        let scheduleScreenVC = TrackerAdditionalSetupViewController()
        scheduleScreenVC.additionalSetupCase = .schedule(timetableDelegate?.selectedWeekDays)
        scheduleScreenVC.additionalTrackerSetupDelegate = timetableDelegate
//        scheduleScreenVC.selectedWeekDays = timetableDelegate?.selectedWeekDays
        return scheduleScreenVC
    }
    
    func makeFiltersScreenView(filtersDelegate: FiltersDelegate?) -> Presentable & TrackerFilterSetupProtocol {
        let filterVC = TrackerAdditionalSetupViewController()
        filterVC.additionalSetupCase = .filters(filtersDelegate?.selectedFilter)
        filterVC.filterSetupDelegate = filtersDelegate
        return filterVC
    }
}
