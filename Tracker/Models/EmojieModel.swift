//
//  EmojieModel.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 27.03.2023.
//

import Foundation

struct EmojieModel: Hashable {
    var emojies: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
//    var emojies: [String] = ["1", "2", "3", "4", "5", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    func getEmojie(for row: Int) -> String {
        return emojies[row]
    }
}
