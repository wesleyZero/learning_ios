import SwiftUI
import Combine

struct GameRootView: View {
    @State private var heroName: String = "Arin"
    @State private var selectedPersonality: Personality = .brave
    @State private var started: Bool = false

    var body: some View {
        if started {
            GamePlayView(viewModel: GameViewModel(heroName: heroName.isEmpty ? "Arin" : heroName, personality: selectedPersonality))
        } else {
            SetupView(heroName: $heroName, selectedPersonality: $selectedPersonality, started: $started)
        }
    }
}

struct SetupView: View {
    @Binding var heroName: String
    @Binding var selectedPersonality: Personality
    @Binding var started: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("A Tale of Ten Trials")
                    .font(.largeTitle).bold()
                Text("Create your hero. Choose a personality that nudges their strengths.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("First Name")
                        .font(.headline)
                    TextField("Enter a name", text: $heroName)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Personality")
                        .font(.headline)
                    Picker("Personality", selection: $selectedPersonality) {
                        ForEach(Personality.allCases) { p in
                            VStack(alignment: .leading) {
                                Text(p.displayName).bold()
                                Text(p.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(p)
                        }
                    }
                    .pickerStyle(.wheel)
                    HStack(spacing: 16) {
                        ForEach(Stat.allCases, id: \.self) { stat in
                            VStack {
                                Text(stat.symbol)
                                Text(stat.rawValue)
                                    .font(.caption)
                                let bonus = selectedPersonality.statBias[stat] ?? 0
                                Text(bonus == 0 ? "±0" : (bonus > 0 ? "+\(bonus)" : "\(bonus)"))
                                    .font(.caption2)
                                    .foregroundStyle(bonus >= 0 ? .green : .red)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }

                Button {
                    withAnimation { started = true }
                } label: {
                    Text("Begin Adventure")
                        .font(.title2).bold()
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.blue, in: .capsule)
                        .foregroundStyle(.white)
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding()
        }
    }
}

struct GamePlayView: View {
    @StateObject private var viewModel: GameViewModel

    init(viewModel: GameViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                header
                Divider()
                if viewModel.isFinished {
                    EndingView(hero: viewModel.hero)
                } else {
                    if viewModel.showingStartDialogue {
                        DialogueView(lines: viewModel.dialogueQueue, heroName: viewModel.hero.firstName) {
                            viewModel.advanceStartDialogue()
                        }
                    } else if viewModel.showingEndDialogue {
                        DialogueView(lines: viewModel.dialogueQueue, heroName: viewModel.hero.firstName) {
                            viewModel.advanceEndDialogue()
                        }
                    } else {
                        actionArea
                    }
                }
                Divider()
                logView
            }
            .padding()
            .navigationTitle("Quest \(min(viewModel.currentQuestIndex + 1, 10))/10")
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("\(viewModel.hero.firstName) • \(viewModel.hero.personality.displayName)")
                    .font(.title3).bold()
                HStack(spacing: 12) {
                    ForEach(Stat.allCases, id: \.self) { stat in
                        let val = viewModel.hero.effective(stat: stat)
                        Label("\(val)", systemImage: stat == .strength ? "bolt.fill" : stat == .intellect ? "brain.head.profile" : "heart.text.square.fill")
                            .labelStyle(.iconOnly)
                            .overlay(
                                VStack(spacing: 2) {
                                    Text(stat.symbol)
                                    Text("\(val)")
                                        .font(.caption)
                                }
                            )
                    }
                }
                .font(.headline)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("HP: \(viewModel.hero.hp)")
                if !viewModel.hero.inventory.isEmpty {
                    Text("Gear: " + viewModel.hero.inventory.map { $0.name }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 240, alignment: .trailing)
                }
            }
        }
    }

    private var actionArea: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let q = viewModel.currentQuest { 
                Text(q.title).font(.title2).bold()
                Text(q.synopsis).foregroundStyle(.secondary)
                if let a = viewModel.currentAction {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Action: \(a.title)").bold()
                        HStack {
                            Text("Check: \(a.requiredStat.rawValue) vs \(a.difficulty)")
                            Spacer()
                            Button("Attempt") { viewModel.attemptCurrentAction() }
                                .buttonStyle(.borderedProminent)
                        }
                        if let outcome = viewModel.lastOutcome {
                            OutcomeView(outcome: outcome)
                        }
                        if !a.rewards.isEmpty {
                            Text("Rewards: " + a.rewards.map { $0.name }.joined(separator: ", "))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Text("All actions done. Continue...")
                }
            }
        }
    }

    private var logView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(viewModel.log.enumerated()), id: \.offset) { pair in
                    Text(pair.element)
                        .padding(8)
                        .background(.thinMaterial, in: .capsule)
                }
            }
        }
        .frame(maxHeight: 60)
    }
}

struct DialogueView: View {
    let lines: [DialogueLine]
    let heroName: String
    let onAdvance: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ForEach(lines.prefix(1)) { line in
                VStack(alignment: .leading, spacing: 8) {
                    Text(displayName(line.speaker))
                        .font(.headline)
                    Text(line.text)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.thinMaterial, in: .rect(cornerRadius: 12))
                }
            }
            Button("Continue") { onAdvance() }
                .buttonStyle(.borderedProminent)
        }
    }

    private func displayName(_ token: String) -> String {
        token == "Hero" ? heroName : token
    }
}

struct OutcomeView: View {
    let outcome: GameViewModel.RollOutcome

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(outcome.success ? "Success" : "Failure")
                    .bold()
                    .foregroundStyle(outcome.success ? .green : .red)
                Spacer()
                Text("Roll: \(outcome.roll) + \(outcome.bonus) = \(outcome.total) vs \(outcome.target)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(outcome.text)
        }
        .padding(8)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }
}

struct EndingView: View {
    let hero: Character

    var body: some View {
        VStack(spacing: 16) {
            Text("The End")
                .font(.largeTitle).bold()
            Text("With courage and wit, \(hero.firstName) braved ten quests, faced a dragon, and saved the princess.")
                .multilineTextAlignment(.center)
            Text("The kingdom remembers your name, \(hero.firstName).")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview("Setup") {
    GameRootView()
}

#Preview("Gameplay") {
    GamePlayView(viewModel: GameViewModel(heroName: "Arin", personality: .brave))
}
