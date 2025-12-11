import Foundation
import SwiftUI
import Combine

@MainActor
final class GameViewModel: ObservableObject {
    @Published var hero: Character
    @Published private(set) var quests: [Quest]
    @Published var currentQuestIndex: Int = 0
    @Published var currentActionIndex: Int = 0

    // Dialogue handling
    @Published var showingStartDialogue: Bool = true
    @Published var showingEndDialogue: Bool = false
    @Published var dialogueQueue: [DialogueLine] = []

    // Log of recent events
    @Published var log: [String] = []

    // Last roll result for UI feedback
    struct RollOutcome {
        let roll: Int
        let bonus: Int
        let total: Int
        let target: Int
        let success: Bool
        let text: String
    }
    @Published var lastOutcome: RollOutcome? = nil

    var isFinished: Bool { currentQuestIndex >= quests.count }

    init(heroName: String, personality: Personality) {
        var base: [Stat: Int] = [.strength: 3, .intellect: 3, .charm: 3]
        // Apply personality biases to base stats
        for (stat, bonus) in personality.statBias { base[stat, default: 0] += bonus }
        self.hero = Character(firstName: heroName, personality: personality, baseStats: base)
        self.quests = GameViewModel.makeQuests()

        // Begin with the first quest's start dialogue
        if let first = quests.first {
            dialogueQueue = first.startDialogue
            showingStartDialogue = true
            showingEndDialogue = false
        }
    }

    var currentQuest: Quest? {
        guard currentQuestIndex < quests.count else { return nil }
        return quests[currentQuestIndex]
    }

    var currentAction: QuestAction? {
        guard let q = currentQuest, currentActionIndex < q.actions.count else { return nil }
        return q.actions[currentActionIndex]
    }

    func advanceStartDialogue() {
        guard showingStartDialogue else { return }
        if !dialogueQueue.isEmpty {
            dialogueQueue.removeFirst()
        }
        if dialogueQueue.isEmpty {
            showingStartDialogue = false
        }
    }

    func advanceEndDialogue() {
        guard showingEndDialogue else { return }
        if !dialogueQueue.isEmpty {
            dialogueQueue.removeFirst()
        }
        if dialogueQueue.isEmpty {
            showingEndDialogue = false
            completeQuestAndAdvance()
        }
    }

    private func completeQuestAndAdvance() {
        // Mark quest complete
        if currentQuestIndex < quests.count {
            quests[currentQuestIndex].isCompleted = true
        }
        // Move to next quest
        currentQuestIndex += 1
        currentActionIndex = 0
        lastOutcome = nil
        if let next = currentQuest {
            dialogueQueue = next.startDialogue
            showingStartDialogue = true
            showingEndDialogue = false
        } else {
            // No more quests; finished
            dialogueQueue = []
            showingStartDialogue = false
            showingEndDialogue = false
        }
    }

    func attemptCurrentAction() {
        guard let action = currentAction else { return }
        // Roll a d20
        let roll = Int.random(in: 1...20)
        let bonus = hero.effective(stat: action.requiredStat)
        let total = roll + bonus
        let success = total >= action.difficulty
        let outcomeText = success ? action.successText : action.failureText
        lastOutcome = RollOutcome(roll: roll, bonus: bonus, total: total, target: action.difficulty, success: success, text: outcomeText)

        if success {
            // Grant rewards
            for item in action.rewards {
                hero.add(item: item)
            }
            logMessage("✓ \(action.title): \(outcomeText)")
            advanceAction()
        } else {
            hero.hp = max(0, hero.hp - 5)
            logMessage("✗ \(action.title): \(outcomeText) (HP −5)")
        }
    }

    private func advanceAction() {
        guard let q = currentQuest else { return }
        currentActionIndex += 1
        lastOutcome = nil
        if currentActionIndex >= q.actions.count {
            // Completed all actions -> show end dialogue
            dialogueQueue = q.endDialogue
            showingEndDialogue = true
        }
    }

    private func logMessage(_ text: String) {
        withAnimation { log.insert(text, at: 0) }
        // Keep log to a reasonable size
        if log.count > 12 { log.removeLast(log.count - 12) }
    }
}

// MARK: - Data Factory
extension GameViewModel {
    static func makeQuests() -> [Quest] {
        // Common items
        let brooch = Item(name: "Silver Tongue Brooch", description: "+1 Charm", statBoosts: [.charm: 1])
        let gauntlet = Item(name: "Grip Gauntlet", description: "+1 Strength", statBoosts: [.strength: 1])
        let pin = Item(name: "Scholar's Pin", description: "+1 Intellect", statBoosts: [.intellect: 1])
        let cloak = Item(name: "Shadow Cloak", description: "+1 Charm, +1 Intellect", statBoosts: [.charm: 1, .intellect: 1])
        let tonic = Item(name: "Lionheart Tonic", description: "+1 Strength, +1 Charm", statBoosts: [.strength: 1, .charm: 1])
        let circlet = Item(name: "Oracle Circlet", description: "+2 Intellect", statBoosts: [.intellect: 2])
        let blade = Item(name: "Sunspear Blade", description: "+2 Strength", statBoosts: [.strength: 2])
        let signet = Item(name: "Royal Signet", description: "+2 Charm", statBoosts: [.charm: 2])

        return [
            Quest(
                title: "Whispers in the Market",
                synopsis: "Rumors point to a plot brewing in the bazaar.",
                startDialogue: [
                    .init(speaker: "Merchant", text: "Psst! You there—trouble's brewing among the stalls."),
                    .init(speaker: "Hero", text: "I'll help. Tell me everything you know."),
                    .init(speaker: "Merchant", text: "A thief stole a coded note. Catch them and learn who's pulling the strings.")
                ],
                endDialogue: [
                    .init(speaker: "Merchant", text: "You handled that deftly. The city owes you."),
                    .init(speaker: "Hero", text: "This is bigger than a market spat. I'll keep digging.")
                ],
                actions: [
                    QuestAction(title: "Charm the gossiping vendors", requiredStat: .charm, difficulty: 12, successText: "They trust you and spill secrets.", failureText: "They clam up—you're clearly an outsider.", rewards: [brooch]),
                    QuestAction(title: "Sprint after the nimble thief", requiredStat: .strength, difficulty: 13, successText: "You tackle the thief and recover the note.", failureText: "They vault a cart and vanish into the crowd.", rewards: [gauntlet]),
                    QuestAction(title: "Decipher the coded note", requiredStat: .intellect, difficulty: 14, successText: "You crack the cipher: 'Meet at the old clock tower.'", failureText: "The symbols dance mockingly; your head aches.", rewards: [pin])
                ]
            ),
            Quest(
                title: "Goblin Bridge Toll",
                synopsis: "A goblin gang taxes travelers at the bridge.",
                startDialogue: [
                    .init(speaker: "Goblin Chief", text: "Gold for crossin'! Or we rattle ya bones."),
                    .init(speaker: "Hero", text: "How about a deal instead of a brawl?")
                ],
                endDialogue: [
                    .init(speaker: "Goblin Chief", text: "Hrrm. You ain't so bad. We'll guard the bridge proper."),
                    .init(speaker: "Hero", text: "Just keep travelers safe. That's all I ask.")
                ],
                actions: [
                    QuestAction(title: "Negotiate a fair treaty", requiredStat: .charm, difficulty: 13, successText: "You win them over to lawful work.", failureText: "They jeer and demand even more.", rewards: [signet]),
                    QuestAction(title: "Reinforce the broken planks", requiredStat: .strength, difficulty: 12, successText: "You secure the bridge with sturdy beams.", failureText: "A plank snaps; you nearly fall in.", rewards: [blade]),
                    QuestAction(title: "Draft a simple toll ledger", requiredStat: .intellect, difficulty: 12, successText: "You create a system even goblins can follow.", failureText: "The math spirals out of control.", rewards: [pin])
                ]
            ),
            Quest(
                title: "Library of Echoes",
                synopsis: "Ancient halls whisper answers if you listen.",
                startDialogue: [
                    .init(speaker: "Librarian", text: "Mind the echoes—they repeat warnings and wishes alike."),
                    .init(speaker: "Hero", text: "I'm here for warnings, not wishes.")
                ],
                endDialogue: [
                    .init(speaker: "Librarian", text: "You learned what you needed—and what you feared."),
                    .init(speaker: "Hero", text: "Knowledge sharpens the blade you cannot see.")
                ],
                actions: [
                    QuestAction(title: "Interpret a cryptic prophecy", requiredStat: .intellect, difficulty: 15, successText: "You unravel the metaphor—danger in the royal keep.", failureText: "The words contradict themselves.", rewards: [circlet]),
                    QuestAction(title: "Calm a restless spirit", requiredStat: .charm, difficulty: 13, successText: "You soothe the echo with kind words.", failureText: "It wails louder, books tumble from shelves.", rewards: [cloak])
                ]
            ),
            Quest(
                title: "Haunted Mill",
                synopsis: "A mill by the river spins tales of loss.",
                startDialogue: [
                    .init(speaker: "Miller", text: "The wheel turns backward at night. My grain is cursed!"),
                    .init(speaker: "Hero", text: "Curses are knots. Let's untie this one.")
                ],
                endDialogue: [
                    .init(speaker: "Miller", text: "Bless you! The wheel hums steady again."),
                    .init(speaker: "Hero", text: "Let the town sleep easy tonight.")
                ],
                actions: [
                    QuestAction(title: "Hold the wheel against the current", requiredStat: .strength, difficulty: 14, successText: "You muscle it straight.", failureText: "Your arms burn; the current wins.", rewards: [gauntlet]),
                    QuestAction(title: "Appease the river sprite", requiredStat: .charm, difficulty: 14, successText: "You offer lilies and a lullaby.", failureText: "It splashes and sulks—unimpressed.", rewards: [brooch])
                ]
            ),
            Quest(
                title: "Tournament of Swords",
                synopsis: "Steel sings in the capital's arena.",
                startDialogue: [
                    .init(speaker: "Announcer", text: "Champions, salute!"),
                    .init(speaker: "Hero", text: "I fight for more than a crown of laurel.")
                ],
                endDialogue: [
                    .init(speaker: "Announcer", text: "A dazzling display! The crowd roars your name."),
                    .init(speaker: "Hero", text: "Every cheer is a promise to protect them.")
                ],
                actions: [
                    QuestAction(title: "Armored duel", requiredStat: .strength, difficulty: 16, successText: "You disarm your foe with a flourish.", failureText: "Your guard slips; the blow rings your helm.", rewards: [blade])
                ]
            ),
            Quest(
                title: "Courtly Intrigue",
                synopsis: "Whispers curl beneath velvet drapes.",
                startDialogue: [
                    .init(speaker: "Chamberlain", text: "Choose your words as if they were daggers."),
                    .init(speaker: "Hero", text: "Then I'll sheath them in kindness first.")
                ],
                endDialogue: [
                    .init(speaker: "Chamberlain", text: "You've made powerful friends—and defanged foes."),
                    .init(speaker: "Hero", text: "Allies today save lives tomorrow.")
                ],
                actions: [
                    QuestAction(title: "Expose a slanderous rumor", requiredStat: .intellect, difficulty: 14, successText: "You trace lies to their source.", failureText: "The web tangles; truth slips away.", rewards: [circlet]),
                    QuestAction(title: "Charm the dowager duchess", requiredStat: .charm, difficulty: 16, successText: "She laughs and pledges support.", failureText: "She yawns and turns her ring.", rewards: [signet])
                ]
            ),
            Quest(
                title: "The Mountain Pass",
                synopsis: "Snow and stone test every step.",
                startDialogue: [
                    .init(speaker: "Guide", text: "The pass eats the unprepared."),
                    .init(speaker: "Hero", text: "Then we'll travel as if we were its guests.")
                ],
                endDialogue: [
                    .init(speaker: "Guide", text: "You led us true. The valley is safe."),
                    .init(speaker: "Hero", text: "We leave only footprints and goodwill.")
                ],
                actions: [
                    QuestAction(title: "Clear a rockslide", requiredStat: .strength, difficulty: 15, successText: "You heave boulders aside.", failureText: "A stone slips; your back protests.", rewards: [tonic]),
                    QuestAction(title: "Chart the safe route", requiredStat: .intellect, difficulty: 15, successText: "You map windbreaks and avalanche shadows.", failureText: "Your markings fade in blowing snow.", rewards: [cloak])
                ]
            ),
            Quest(
                title: "The Oracle's Trial",
                synopsis: "Wisdom asks a price in riddles.",
                startDialogue: [
                    .init(speaker: "Oracle", text: "Answer without speaking; speak without words."),
                    .init(speaker: "Hero", text: "Then listen to my silence.")
                ],
                endDialogue: [
                    .init(speaker: "Oracle", text: "You carry truth gently. I grant you sight."),
                    .init(speaker: "Hero", text: "May it light the darkest hall.")
                ],
                actions: [
                    QuestAction(title: "Solve the mirror riddle", requiredStat: .intellect, difficulty: 17, successText: "You see the answer in what isn't there.", failureText: "Every solution reflects a flaw.", rewards: [circlet])
                ]
            ),
            Quest(
                title: "Siege of the Castle",
                synopsis: "Shadows gather around the royal keep.",
                startDialogue: [
                    .init(speaker: "Captain", text: "We hold till dawn—or fall trying."),
                    .init(speaker: "Hero", text: "We won't fall. We rise.")
                ],
                endDialogue: [
                    .init(speaker: "Captain", text: "The gate stands. The people live."),
                    .init(speaker: "Hero", text: "Then we press on to the heart of this siege.")
                ],
                actions: [
                    QuestAction(title: "Rally the defenders", requiredStat: .charm, difficulty: 16, successText: "Your words kindle courage.", failureText: "Their eyes stay fixed on the ground.", rewards: [signet]),
                    QuestAction(title: "Shatter the battering ram", requiredStat: .strength, difficulty: 17, successText: "You splinter it with a mighty strike.", failureText: "The ram bucks you back.", rewards: [blade])
                ]
            ),
            Quest(
                title: "The Hidden Catacombs",
                synopsis: "Tunnels beneath the keep hide the true enemy.",
                startDialogue: [
                    .init(speaker: "Spy", text: "Below the throne—passages and plots."),
                    .init(speaker: "Hero", text: "Then below we go.")
                ],
                endDialogue: [
                    .init(speaker: "Spy", text: "I'll spread word. You head for the tower."),
                    .init(speaker: "Hero", text: "This ends where it began: the clock tower.")
                ],
                actions: [
                    QuestAction(title: "Disarm a labyrinth of traps", requiredStat: .intellect, difficulty: 16, successText: "You step where shadows are kind.", failureText: "A dart nicks your shoulder.", rewards: [cloak]),
                    QuestAction(title: "Silently bypass sentries", requiredStat: .charm, difficulty: 15, successText: "You blend with torchlight and whispers.", failureText: "A cough gives you away.", rewards: [brooch])
                ]
            ),
            Quest(
                title: "The Dragon's Keep",
                synopsis: "At the clock tower's peak, a dragon coils around fate itself.",
                startDialogue: [
                    .init(speaker: "Dragon", text: "Little spark, you climbed far to be extinguished."),
                    .init(speaker: "Hero", text: "I'm here for the captive—your fire ends tonight.")
                ],
                endDialogue: [
                    .init(speaker: "Princess", text: "You came for me."),
                    .init(speaker: "Hero", text: "I would cross a thousand storms to reach you."),
                    .init(speaker: "Narrator", text: "And so, together, you save the princess. The kingdom breathes again.")
                ],
                actions: [
                    QuestAction(title: "Withstand the dragon's roar", requiredStat: .strength, difficulty: 18, successText: "You plant your feet; the stones crack before you do.", failureText: "Your knees buckle, vision blurs.", rewards: [tonic]),
                    QuestAction(title: "Predict the flame's pattern", requiredStat: .intellect, difficulty: 18, successText: "You read the rhythm and step between infernos.", failureText: "Heat licks your cloak; you stumble.", rewards: [circlet]),
                    QuestAction(title: "Speak to the dragon's pride", requiredStat: .charm, difficulty: 18, successText: "You offer honor in retreat, not defeat.", failureText: "Your words spark only fury.", rewards: [signet]),
                    QuestAction(title: "Free the princess from her chains", requiredStat: .strength, difficulty: 19, successText: "The last shackle snaps. You save the princess.", failureText: "The lock holds—for now.", rewards: [blade])
                ]
            )
        ]
    }
}
