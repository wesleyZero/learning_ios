//
//  BattleEngine.swift
//  llll
//
//  Created by Assistant on 12/9/25.
//

import Foundation
import SwiftUI
import Combine

enum BattleAction: String, CaseIterable, Identifiable {
    case strike = "Strike"
    case guardUp = "Guard"
    case throwSpark = "Spark"
    case capture = "Capture"
    
    var id: String { rawValue }
}

struct BattleLog: Identifiable {
    let id = UUID()
    let text: String
}

@MainActor
final class GameState: ObservableObject {
    enum Screen { case explore, battle, team }
    
    @Published var screen: Screen = .explore
    @Published var playerTeam: [Creature]
    @Published var bag: Int // capture orbs
    @Published var wild: Creature? // current encounter
    @Published var logs: [BattleLog] = []
    
    init() {
        // Starter inspired by yellow theme
        let starter = Creature(
            id: UUID(),
            name: "Sparko",
            level: 5,
            maxHP: 28,
            currentHP: 28,
            attack: 10,
            defense: 6,
            emoji: "⚡️",
            color: .yellow
        )
        self.playerTeam = [starter]
        self.bag = 3
        self.wild = nil
    }
    
    func exploreTallGrass() {
        logs.removeAll()
        let level = max(3, (playerTeam.first?.level ?? 3) + Int.random(in: -2...2))
        let encounter = Creature.randomWild(level: max(1, level))
        wild = encounter
        screen = .battle
        logs.append(BattleLog(text: "A wild \(encounter.name) appeared!"))
    }
    
    func runAway() {
        guard wild != nil else { retur thisn
    
    func endBattle() {
        wild = nil
        screen = .explore
    }
    
    func perform(_ action: BattleAction) {
        guard var wild = wild, var hero = playerTeam.first else { return }
        logs.removeAll()
        
        switch action {
        case .strike:
            let dmg = max(1, hero.attack - Int.random(in: 0...wild.defense/2))
            wild.currentHP -= dmg
            logs.append(BattleLog(text: "\(hero.name) used Strike! It dealt \(dmg)."))
        case .guardUp:
            let heal = Int.random(in: 2...5)
            hero.currentHP = min(hero.maxHP, hero.currentHP + heal)
            logs.append(BattleLog(text: "\(hero.name) braced! Restored \(heal) HP."))
        case .throwSpark:
            let dmg = max(1, hero.attack + 2 - Int.random(in: 0...wild.defense))
            wild.currentHP -= dmg
            logs.append(BattleLog(text: "\(hero.name) used Spark! \(dmg) damage."))
        case .capture:
            attemptCapture()
            return
        }
        
        // Check faint
        if wild.currentHP <= 0 {
            logs.append(BattleLog(text: "The wild \(wild.name) fainted!"))
            rewardAndEnd()
            return
        }
        
        // Enemy turn
        let enemyDmg = max(1, wild.attack - Int.random(in: 0...max(1, hero.defense - 1)))
        hero.currentHP -= enemyDmg
        logs.append(BattleLog(text: "Wild \(wild.name) attacked! You took \(enemyDmg)."))
        
        // Update back to state
        self.wild = wild
        self.playerTeam[0] = hero
        
        if hero.currentHP <= 0 {
            logs.append(BattleLog(text: "Your \(hero.name) fainted! You fled to safety."))
            endBattle()
        }
    }
    
    private func attemptCapture() {
        guard var wild = wild else { return }
        guard bag > 0 else {
            logs = [BattleLog(text: "You have no capture orbs!")]
            return
        }
        bag -= 1
        let hpFactor = 1.0 - wild.hpFraction
        let baseChance = 0.25 + 0.5 * hpFactor // up to 75% when very low
        let roll = Double.random(in: 0...1)
        if roll < baseChance {
            logs = [BattleLog(text: "Gotcha! \(wild.name) was captured." )]
            wild.currentHP = max(1, wild.currentHP)
            playerTeam.append(wild)
            rewardAndEnd()
        } else {
            logs = [BattleLog(text: "Oh no! \(wild.name) broke free.")]
            // enemy counter
            if var hero = playerTeam.first {
                let enemyDmg = max(1, wild.attack - Int.random(in: 0...max(1, hero.defense - 1)))
                hero.currentHP -= enemyDmg
                playerTeam[0] = hero
                logs.append(BattleLog(text: "Wild \(wild.name) retaliated for \(enemyDmg)!"))
                if hero.currentHP <= 0 {
                    logs.append(BattleLog(text: "Your \(hero.name) fainted! You fled to safety."))
                    endBattle()
                }
            }
            self.wild = wild
        }
    }
    
    private func rewardAndEnd() {
        // Simple level up for first creature
        if var hero = playerTeam.first {
            hero.level += 1
            hero.maxHP += 2
            hero.attack += 1
            hero.defense += 1
            hero.healFull()
            playerTeam[0] = hero
            logs.append(BattleLog(text: "\(hero.name) grew to Lv. \(hero.level)!"))
        }
        endBattle()
    }
}

