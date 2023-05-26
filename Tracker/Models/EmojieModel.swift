//
//  EmojieModel.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 27.03.2023.
//

import Foundation

struct EmojieModel: Hashable {
    var emojies: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    func getEmojie(for row: Int) -> String {
        return emojies[row]
    }
    
    func getEmojieIndex(for emojie: String) -> Int {
        return emojies.firstIndex(where: { $0 == emojie }) ?? 0
    }
}
