//
//  ContentView.swift
//  llll
//
//  Created by Wesley Johanson on 12/9/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameState()
    
    var body: some View {
        Group {
            switch game.screen {
            case .explore:
                ExploreView()
            case .battle:
                BattleView()
            case .team:
                TeamView()
            }
        }
        .environmentObject(game)
    }
}

#Preview {
    ContentView()
}
