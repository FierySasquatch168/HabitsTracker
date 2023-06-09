//
//  StatisticsService.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 03.06.2023.
//

import Foundation

protocol StatisticsServiceProtocol {
    func getStatistics() throws -> [StatisticsDataModel]
}

final class StatisticsService {
    weak var dataStoreStatisticsDelegate: DataStoreStatisticsDelegate?
    
    private let dataStore: DataStoreStatisticsProviderProtocol
    
    init(dataStore: DataStoreStatisticsProviderProtocol) {
        self.dataStore = dataStore
    }
}

extension StatisticsService: StatisticsServiceProtocol {
    func getStatistics() throws -> [StatisticsDataModel] {
        let records = dataStore.loadDataForStatisticsCheck()
        return [.finished(records.count)]
    }
}
