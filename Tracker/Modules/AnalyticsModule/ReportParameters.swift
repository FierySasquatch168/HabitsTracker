//
//  ReportParameters.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 03.06.2023.
//

import Foundation

enum ReportParameters {
    case addTrack
    case checkTrack
    case filter
    case edit
    case delete
    case noParameters
    
    var parameters: [AnyHashable : Any]? {
        switch self {
        case .addTrack:
            return [ "main" : "add_track"]
        case .checkTrack:
            return [ "main" : "track"]
        case .filter:
            return [ "main" : "filter"]
        case .edit:
            return [ "main" : "edit"]
        case .delete:
            return [ "main" : "delete"]
        case .noParameters:
            return nil
        }
    }
}
