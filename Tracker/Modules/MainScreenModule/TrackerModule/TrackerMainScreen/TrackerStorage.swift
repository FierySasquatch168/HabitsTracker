//
//  TrackerStorage.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 02.04.2023.
//

import Foundation

protocol TrackerStorageProtocol {
    var notes: [String] { get set }
    func saveNote(note: String)
}

final class TrackerStorage: TrackerStorageProtocol {
    var notes: [String] = []
    
    func saveNote(note: String) {
        print("notes before saving: \(notes)")
        notes.append(note)
        print("notes after saving: \(notes)")
    }
}
