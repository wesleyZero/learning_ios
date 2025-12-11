Creature//
//  Creature.swift
//  llll
//
//  Created by Assistant on 12/9/25.
//

import SwiftUI

struct Creature: Identifiable, Hashable {
    let id: UUID
    var name: String
    var level: Int
    var maxHP: Int
    var currentHP: Int
    var attack: Int
    var defense: Int
    var emoji: String
    var color: Color
    
    var isFainted: Bool { currentHP <= 0 }
    var hpFraction: Double { max(0.0, min(1.0, Double(currentHP) / Double(maxHP))) }
}

extension Creature {
    static func randomWild(level: Int) -> Creature {
        // Yellow-forward palette and friendly names
        let templates: [(String, String, Color, Int, Int)] = [
            ("Sparko", "⚡️", .yellow, 9, 5),
            ("Bumble", "🐝", .yellow, 7, 6),
            ("Amberling", "🟡", .orange, 8, 7),
            ("Canaryx", "🐤", .yellow, 8, 6),
            ("Sunfox", "🦊", .orange, 10, 5)
        ]
        let t = templates.randomElement()!
        let hp = Int.random(in: 22...30) + level * 2
        let atk = t.3 + level
        let def = t.4 + max(0, level / 2)
        return Creature(
            id: UUID(),
            name: t.0,
            level: level,
            maxHP: hp,
            currentHP: hp,
            attack: atk,
            defense: def,
            emoji: t.1,
            color: t.2
        )
    }
    
    mutating func healFull() {
        currentHP = maxHP
    }
}
