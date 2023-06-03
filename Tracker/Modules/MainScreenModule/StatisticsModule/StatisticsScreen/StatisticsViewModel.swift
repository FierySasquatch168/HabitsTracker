//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 02.06.2023.
//

import Foundation

final class StatisticsViewModel {
    
    private var statisticsService: StatisticsServiceProtocol
    
    init(statisticsService: StatisticsServiceProtocol) {
        self.statisticsService = statisticsService
    }
    
    @Observable
    private (set) var statistics: [StatisticsModel] = [] 
    
    func loadStatistics() {
        getStatistics()
    }
}

private extension StatisticsViewModel {
    func getStatistics() {
        do {
            let statistics = try statisticsService.getStatistics().compactMap({
                switch $0 {
                case .finished(let trackersCount):
                    let title = NSLocalizedString(Constants.LocalizableStringsKeys.statisticsTrackersChecked, comment: "Trackers finished")
                    return trackersCount == 0 ? nil : StatisticsModel(number: trackersCount, title: title)
                }
            })
            self.statistics = statistics
        }
        catch {
            print(CoreDataError.failedToLoadStatistics)
        }
    }
}
