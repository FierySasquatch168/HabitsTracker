//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 03.06.2023.
//

import YandexMobileMetrica

final class AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: K.APIKey.apiKeyString) else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: ReportEvents, params: ReportParameters) {
        switch (event, params) {
        case (.open, _):
            YMMYandexMetrica.reportEvent(event.rawValue)
        case (.close, _):
            YMMYandexMetrica.reportEvent(event.rawValue)
        case (.click, _):
            YMMYandexMetrica.reportEvent(event.rawValue, parameters: params.parameters) { error in
                fatalError("REPORT ERROR: %@ \(error.localizedDescription)")
            }
        }
    }
}
