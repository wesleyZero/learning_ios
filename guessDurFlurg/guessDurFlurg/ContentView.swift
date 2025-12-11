import SwiftUI
import Foundation

struct Country: Hashable {
    let code: String
    let name: String

    var emoji: String {
        code.flagEmoji
    }

    // All ISO 3166-1 alpha-2 regions with localized names, sorted by name.
    static let world: [Country] = {
        let locale = Locale.current
        let codes = Locale.isoRegionCodes
        // Keep only two-letter alphabetic region codes (A–Z).
        let filtered = codes.filter { $0.count == 2 && $0.range(of: "^[A-Za-z]{2}$", options: .regularExpression) != nil }
        let list = filtered.compactMap { code -> Country? in
            let upper = code.uppercased()
            guard let name = locale.localizedString(forRegionCode: upper) else { return nil }
            return Country(code: upper, name: name)
        }
        return list.sorted { $0.name < $1.name }
    }()
}

private extension String {
    // Convert a two-letter ISO region code to a flag emoji.
    var flagEmoji: String {
        let upper = self.uppercased()
        guard upper.count == 2 else { return "🏳️" }
        var scalars = String.UnicodeScalarView()
        for scalar in upper.unicodeScalars {
            // Ensure A–Z
            guard scalar.value >= 65 && scalar.value <= 90 else { return "🏳️" }
            guard let flagScalar = UnicodeScalar(127397 + scalar.value) else { return "🏳️" }
            scalars.append(flagScalar)
        }
        return String(scalars)
    }
}

// Provides a per-country risk percentage (0...100). This is a placeholder
// set of sample values and a deterministic fallback so the game works out of the box.
// Replace or extend `riskByCode` with your own data if desired.
private enum RiskProvider {
    static let riskByCode: [String: Double] = [
        // Example subset (percent estimates). Replace with your own data.
        "ZA": 13.9,
        "BW": 20.3,
        "SZ": 27.0,
        "LS": 21.1,
        "NA": 12.6,
        "ZW": 11.5,
        "UG": 5.2,
        "KE": 4.0,
        "NG": 1.3,
        "US": 0.4,
        "GB": 0.2,
        "FR": 0.3
    ]

    static func risk(for code: String) -> Double {
        if let value = riskByCode[code.uppercased()] {
            return value
        }
        // Deterministic fallback in 0...5% range if no data is provided
        let sum = code.uppercased().unicodeScalars.map { Int($0.value) }.reduce(0, +)
        return Double(sum % 6) // 0,1,2,3,4,5 percent
    }
}

struct ContentView: View {
    @State private var countries: [Country] = Country.world.shuffled()

    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var scoreTitle = ""
    @State private var scoreMessage = ""
    @State private var showingScore = false
    @State private var showingGameOver = false
    @State private var score = 0
    @State private var roundsSurvived = 0

    @State private var selectedFlag: Int? = nil
    @State private var flagWasTapped = false

    @State private var health = 100

    private var roundRisk: Double {
        RiskProvider.risk(for: countries[correctAnswer].code)
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue.opacity(0.6), .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer(minLength: 8)

                Text("Guess the Flag")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)

                // Health
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text("Mode:")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.secondary)
                        Text("Survival")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                    }

                    HStack(spacing: 12) {
                        ProgressView(value: Double(health), total: 100)
                            .tint(health > 50 ? .green : (health > 20 ? .orange : .red))
                        Text("\(health)%")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.primary)
                            .frame(width: 44, alignment: .trailing)
                            .accessibilityLabel("Health \(health) percent")
                    }
                }
                .padding(.horizontal)

                VStack(spacing: 10) {
                    Text("Tap the flag of")
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(.secondary)

                    Text(countries[correctAnswer].name)
                        .font(.title.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text("Risk this round: \(roundRisk, format: .number.precision(.fractionLength(1)))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Risk this round \(Int(roundRisk)) percent")
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)

                VStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { number in
                        Button {
                            flagTapped(number)
                        } label: {
                            FlagImage(emoji: countries[number].emoji)
                                .accessibilityLabel("Flag of \(countries[number].name)")
                        }
                        .rotation3DEffect(.degrees(selectedFlag == number && flagWasTapped && number == correctAnswer ? 360 : 0),
                                          axis: (x: 0, y: 1, z: 0))
                        .opacity(!flagWasTapped || selectedFlag == number ? 1 : 0.25)
                        .scaleEffect(!flagWasTapped || selectedFlag == number ? 1 : 0.92)
                        .saturation(!flagWasTapped || selectedFlag == number ? 1 : 0.6)
                        .overlay {
                            if flagWasTapped, selectedFlag == number, selectedFlag != correctAnswer {
                                Capsule()
                                    .stroke(.red, lineWidth: 4)
                                    .shadow(color: .red.opacity(0.5), radius: 8)
                            }
                        }
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: selectedFlag)
                        .animation(.easeInOut(duration: 0.25), value: flagWasTapped)
                    }
                }
                .padding(.horizontal)

                Spacer()

                HStack {
                    Text("Round \(roundsSurvived + 1)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Score: \(score)")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            Text(scoreMessage)
        }
        .alert("Game Over", isPresented: $showingGameOver) {
            Button("Play Again", action: resetGame)
        } message: {
            Text("You survived \(roundsSurvived) rounds. Final score: \(score). Final health: \(health)%.")
        }
    }

    private func flagTapped(_ number: Int) {
        selectedFlag = number
        withAnimation {
            flagWasTapped = true
        }

        let askedCountry = countries[correctAnswer]
        let risk = RiskProvider.risk(for: askedCountry.code)
        let correct = (number == correctAnswer)

        if correct {
            scoreTitle = "Correct"
            score += 1
        } else {
            scoreTitle = "Wrong"
        }

        // Deterministic damage on wrong answer: double the country's estimated population percentage
        let damage = correct ? 0 : Int((2 * risk).rounded())
        if damage > 0 {
            health = max(health - damage, 0)
        }

        // Compose message
        var parts: [String] = []
        parts.append("Risk this round: \(risk.formatted(.number.precision(.fractionLength(1))))%.")
        if correct {
            parts.append("You avoided damage.")
        } else {
            parts.append("Wrong answer — you lost \(damage) health.")
        }
        if !correct {
            parts.append("That was the flag of \(countries[number].name).")
        }
        scoreMessage = parts.joined(separator: "\n")

        if health <= 0 {
            showingGameOver = true
        } else {
            showingScore = true
        }
    }

    private func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        roundsSurvived += 1
        selectedFlag = nil
        flagWasTapped = false
    }

    private func resetGame() {
        score = 0
        roundsSurvived = 0
        countries = Country.world.shuffled()
        correctAnswer = Int.random(in: 0...2)
        selectedFlag = nil
        flagWasTapped = false
        health = 100
    }
}

private struct FlagImage: View {
    let emoji: String

    var body: some View {
        ZStack {
            LinearGradient(colors: [.white.opacity(0.9), .gray.opacity(0.2)],
                           startPoint: .top, endPoint: .bottom)
            Text(emoji)
                .font(.system(size: 72))
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(12)
        }
        .frame(height: 120)
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(radius: 5)
    }
}

#Preview {
    ContentView()
}
