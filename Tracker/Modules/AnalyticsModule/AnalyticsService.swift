//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 03.06.2023.
//

import YandexMobileMetrica

final class AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "0c756c19-a93c-45a0-95c7-5d158a879bd1") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: ReportEvents, params: ReportParameters) {
        switch (event, params) {
        case (.open, _):
            YMMYandexMetrica.reportEvent(event.name)
        case (.close, _):
            YMMYandexMetrica.reportEvent(event.name)
        case (.click, _):
            YMMYandexMetrica.reportEvent(event.name, parameters: params.parameters) { error in
                print("REPORT ERROR: %@", error.localizedDescription)
            }
        }
    }
}
