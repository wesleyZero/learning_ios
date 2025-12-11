import Foundation

enum Stat: String, CaseIterable, Hashable, Codable {
    case strength = "Strength"
    case intellect = "Intellect"
    case charm = "Charm"

    var symbol: String { 
        switch self {
        case .strength: return "🗡️"
        case .intellect: return "📚"
        case .charm: return "🕊️"
        }
    }
}

enum Personality: String, CaseIterable, Identifiable, Codable {
    case brave, clever, compassionate, stoic, witty

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .brave: return "Brave"
        case .clever: return "Clever"
        case .compassionate: return "Compassionate"
        case .stoic: return "Stoic"
        case .witty: return "Witty"
        }
    }

    var description: String {
        switch self {
        case .brave: return "Runs toward danger with a grin."
        case .clever: return "Solves problems three moves ahead."
        case .compassionate: return "Leads with empathy and heart."
        case .stoic: return "Calm in storm, steady in battle."
        case .witty: return "Always a quip ready, even in peril."
        }
    }

    // Personality nudges base stats
    var statBias: [Stat: Int] {
        switch self {
        case .brave: return [.strength: 2, .intellect: 0, .charm: 0]
        case .clever: return [.strength: 0, .intellect: 2, .charm: 0]
        case .compassionate: return [.strength: 0, .intellect: 0, .charm: 2]
        case .stoic: return [.strength: 1, .intellect: 1, .charm: 0]
        case .witty: return [.strength: 0, .intellect: 1, .charm: 1]
        }
    }
}

struct Item: Identifiable, Hashable, Codable {
    let id: UUID = UUID()
    let name: String
    let description: String
    let statBoosts: [Stat: Int]
}

struct DialogueLine: Identifiable, Codable {
    let id: UUID = UUID()
    // Use "Hero" as a special speaker token that will be rendered as the player's first name
    let speaker: String
    let text: String
}

struct QuestAction: Identifiable, Codable {
    let id: UUID = UUID()
    let title: String
    let requiredStat: Stat
    let difficulty: Int // target number: d20 + effectiveStat must be >= difficulty
    let successText: String
    let failureText: String
    let rewards: [Item]
}

struct Quest: Identifiable, Codable {
    let id: UUID = UUID()
    let title: String
    let synopsis: String
    let startDialogue: [DialogueLine]
    let endDialogue: [DialogueLine]
    let actions: [QuestAction]
    var isCompleted: Bool = false
}

struct Character: Identifiable, Codable {
    var id: UUID = UUID()
    var firstName: String
    var personality: Personality
    var baseStats: [Stat: Int] // starting at small values, improved by items
    var inventory: [Item] = []
    var hp: Int = 100

    func effective(stat: Stat) -> Int {
        let base = baseStats[stat] ?? 0
        let boost = inventory.reduce(0) { partial, item in
            partial + (item.statBoosts[stat] ?? 0)
        }
        return base + boost
    }

    mutating func add(item: Item) {
        inventory.append(item)
    }
}
