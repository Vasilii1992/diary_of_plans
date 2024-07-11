//
//  Note.swift
//  Diary of plans
//
//  Created by Василий Тихонов on 11.07.2024.
//

import Foundation

struct Note: Codable, Identifiable, Equatable {
    
    var id = UUID()
    var title: String
    var isComplete: Bool
    var date: Date
    var notes: String
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

