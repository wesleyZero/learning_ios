//
//  GameViews.swift
//  llll
//
//  Created by Assistant on 12/9/25.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var game: GameState
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.yellow.opacity(0.5), .orange.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                VStack(spacing: 24) {
                    Text("Sunfield Plains")
                        .font(.largeTitle).bold()
                        .foregroundStyle(.yellow)
                        .shadow(color: .orange.opacity(0.6), radius: 8, x: 0, y: 4)
                    
                    if let lead = game.playerTeam.first {
                        HStack(spacing: 16) {
                            Text(lead.emoji).font(.system(size: 48))
                            VStack(alignment: .leading) {
                                Text("Lead: \(lead.name) Lv. \(lead.level)").bold()
                                HealthBar(fraction: lead.hpFraction, color: .yellow)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    HStack(spacing: 16) {
                        Button {
                            game.exploreTallGrass()
                        } label: {
                            Label("Explore", systemImage: "leaf.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.yellow)
                        
                        NavigationLink(value: "team") {
                            Label("Team", systemImage: "person.3.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Capture Orbs: \(game.bag)")
                    }
                    .font(.headline)
                    .padding(10)
                    .background(.thinMaterial)
                    .clipShape(Capsule())
                    
                    Spacer()
                }
                .padding()
            }
            .navigationDestination(for: String.self) { value in
                if value == "team" {
                    TeamView()
                }
            }
        }
    }
}

struct BattleView: View {
    @EnvironmentObject var game: GameState
    
    var body: some View {
        VStack(spacing: 12) {
            if let wild = game.wild, let hero = game.playerTeam.first {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("You: \(hero.name) Lv. \(hero.level)").bold()
                            HealthBar(fraction: hero.hpFraction, color: .yellow)
                        }
                        Spacer()
                        Text(hero.emoji).font(.system(size: 44))
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    HStack {
                        Text(wild.emoji).font(.system(size: 44))
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Wild: \(wild.name) Lv. \(wild.level)").bold()
                            HealthBar(fraction: wild.hpFraction, color: wild.color)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(game.logs) { log in
                            Text("• \(log.text)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 160)
                
                VStack(spacing: 10) {
                    HStack {
                        BattleButton(title: "Strike", systemImage: "bolt.fill", color: .yellow) {
                            game.perform(.strike)
                        }
                        BattleButton(title: "Guard", systemImage: "shield.fill", color: .orange) {
                            game.perform(.guardUp)
                        }
                    }
                    HStack {
                        BattleButton(title: "Spark", systemImage: "sparkles", color: .yellow) {
                            game.perform(.throwSpark)
                        }
                        BattleButton(title: "Capture", systemImage: "circle.grid.2x2", color: .yellow) {
                            game.perform(.capture)
                        }
                    }
                    Button("Run Away", role: .cancel) { game.runAway() }
                        .buttonStyle(.bordered)
                }
                .padding()
            } else {
                Text("No encounter.")
                Button("Back") { game.endBattle() }
            }
            Spacer()
        }
        .background(
            LinearGradient(colors: [.yellow.opacity(0.6), .orange.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
    }
}

struct TeamView: View {
    @EnvironmentObject var game: GameState
    
    var body: some View {
        List {
            Section("Your Team") {
                ForEach(game.playerTeam) { c in
                    HStack(spacing: 12) {
                        Text(c.emoji).font(.title)
                        VStack(alignment: .leading) {
                            Text("\(c.name) Lv. \(c.level)").bold()
                            HealthBar(fraction: c.hpFraction, color: c.color)
                        }
                        Spacer()
                        Text("ATK \(c.attack)  DEF \(c.defense)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Team")
    }
}

struct BattleButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .tint(color)
    }
}

struct HealthBar: View {
    var fraction: Double
    var color: Color
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.black.opacity(0.08))
                Capsule().fill(color.gradient)
                    .frame(width: max(0, geo.size.width * fraction))
            }
        }
        .frame(height: 10)
        .clipShape(Capsule())
    }
}

