//
//  ContentView.swift
//  Flappy Burg
//
//  Created by Wesley Johanson on 12/9/25.
//

import SwiftUI
import Combine
import AVFoundation

struct ContentView: View {
    @State private var game = GameState()
    @State private var isRunning = false
    @State private var lastUpdate = Date()
    @State private var timer: Timer? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @StateObject private var highScores = HighScores()
    @State private var showingSettings = false
    @State private var showingHighScores = false
    @StateObject private var chiptune = ChiptunePlayer()
    @State private var showingMainMenu = true
    @State private var showPrideMessage = false

    var body: some View {
        ZStack {
            CyclingBackgroundView(speed: reduceMotion ? 0.02 : 0.06)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack(spacing: 16) {
                HStack {
                    Text("Flappy Friends")
                        .font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    Menu {
                        Button {
                            start()
                        } label: {
                            Label("Start New Game", systemImage: "play.fill")
                        }
                        Button {
                            showingHighScores = true
                        } label: {
                            Label("High Scores", systemImage: "trophy.fill")
                        }
                        Button {
                            showingSettings = true
                        } label: {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                    } label: {
                        Label("Menu", systemImage: "ellipsis.circle")
                            .labelStyle(.iconOnly)
                            .imageScale(.large)
                            .accessibilityLabel("Menu")
                    }
                }
                .padding(.horizontal)

                ZStack {
                    GameView(game: $game)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(.white.opacity(0.2)))
                        .shadow(radius: 10)
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if isRunning { game.isPressing = true }
                                }
                                .onEnded { _ in
                                    game.release()
                                }
                        )
                        .accessibilityAction { flap() }
                        .accessibilityLabel("Game area. Press and hold to fly up; release to fall.")
                        .accessibilityHint("Press and hold to fly up; release to fall.")

                    if !isRunning {
                        VStack(spacing: 12) {
                            Text(game.isGameOver ? "Game Over" : "Ready")
                                .font(.title.bold())
                            Text("Press and hold anywhere to fly up. Release to fall.")
                                .font(.callout)
                            if game.isGameOver {
                                Text("Score: \(game.score)")
                                    .font(.headline)
                            }
                            HStack(spacing: 8) {
                                AvatarPicker(selected: $game.avatar)
                            }
                            .padding(.top, 8)

                            Button {
                                start()
                            } label: {
                                Label("Start Round", systemImage: "play.fill")
                                    .font(.headline)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .accessibilityLabel("Start Round")
                            .padding(.top, 4)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(game.isGameOver ? "Game over. Score \(game.score). Press Start Round to play again." : "Press Start Round to begin. Press and hold to fly up; release to fall.")
                    }
                    if showPrideMessage {
                        VStack {
                            PrideBanner()
                            Spacer()
                        }
                        .padding()
                        .transition(.opacity)
                        .zIndex(1)
                    }
                }
                .aspectRatio(9.0/16.0, contentMode: .fit)
                .padding(.horizontal)

                HStack {
                    Label("Score: \(game.score)", systemImage: "star.fill")
                        .font(.headline)
                        .accessibilityLabel("Score \(game.score)")
                    Spacer()
                    HStack(spacing: 8) {
                        Text("Difficulty: \(game.difficulty)")
                            .font(.headline)
                        Stepper("Difficulty", value: $game.difficulty, in: 1...5)
                            .labelsHidden()
                            .accessibilityLabel("Adjust difficulty. Current \(game.difficulty)")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .onChange(of: reduceMotion) { _, newValue in
            game.reducedMotion = newValue
        }
        .onAppear {
            game.reducedMotion = reduceMotion
            chiptune.playMenu()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(reducedMotion: $game.reducedMotion, difficulty: $game.difficulty)
        }
        .sheet(isPresented: $showingHighScores) {
            HighScoresView(highScores: highScores)
        }
        .fullScreenCover(isPresented: $showingMainMenu) {
            MainMenuView(
                startAction: {
                    showingMainMenu = false
                    chiptune.playGame()
                    start()
                },
                highScoresAction: {
                    showingMainMenu = false
                    DispatchQueue.main.async { showingHighScores = true }
                },
                settingsAction: {
                    showingMainMenu = false
                    DispatchQueue.main.async { showingSettings = true }
                }
            )
        }
        .onChange(of: showingMainMenu) { _, isShowing in
            if isShowing { chiptune.playMenu() }
        }
        .onDisappear {
            stop()
            chiptune.stop()
        }
    }

    private func start() {
        stop()
        game.reset()
        isRunning = true
        lastUpdate = Date()
        chiptune.playGame()
        showPrideMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showPrideMessage = false
        }
        // Spawn a pipe quickly on start
        game.timeSinceLastPipe = game.pipeInterval
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            let now = Date()
            let dt = now.timeIntervalSince(lastUpdate)
            lastUpdate = now
            game.update(dt: dt)
            if game.isGameOver {
                highScores.add(time: game.elapsed, screens: game.score)
                stop()
            }
        }
    }

    private func stop() {
        isRunning = false
        game.isPressing = false
        timer?.invalidate()
        timer = nil
    }

    private func flap() {
        guard isRunning else { return }
        game.flap()
    }
}

// MARK: - Game State

struct GameState {
    // World
    var size: CGSize = .zero
    var gravity: CGFloat = 1200
    var bird = Bird()
    var pipes: [Pipe] = []
    var timeSinceLastPipe: TimeInterval = 0
    var pipeInterval: TimeInterval = 1.8
    var pipeSpeed: CGFloat = 220
    var gapHeight: CGFloat = 170
    var elapsed: TimeInterval = 0

    // Visuals
    var hue: Double = 0
    var hueSpeed: Double = 0.6

    // Trail
    var trails: [TrailParticle] = []
    var trailInterval: TimeInterval = 0.03
    var trailAccumulator: TimeInterval = 0

    // Controls
    var isPressing: Bool = false
    var thrust: CGFloat = 3600
    var maxUpwardSpeed: CGFloat = -1800
    var maxDownwardSpeed: CGFloat = 1200

    // Gameplay
    var score: Int = 0
    var isGameOver: Bool = false
    var reducedMotion: Bool = false
    var difficulty: Int = 2 { didSet { applyDifficulty() } }

    // Avatar
    var avatar: Avatar = .rainbow

    mutating func reset() {
        bird = Bird()
        pipes.removeAll()
        timeSinceLastPipe = 0
        score = 0
        isGameOver = false
        elapsed = 0
        isPressing = false
        applyDifficulty()
        trails.removeAll()
        hue = 0
        trailAccumulator = 0
    }

    mutating func applyDifficulty() {
        let level = CGFloat(difficulty)
        pipeInterval = max(0.88, (2.2 - 0.2 * Double(level)) * 0.8)
        pipeSpeed = 180 + 40 * level
        gapHeight = max(120, 200 - 12 * level)
        gravity = 1100 + 80 * level
    }

    mutating func update(dt: TimeInterval) {
        guard !isGameOver else { return }
        elapsed += dt

        hue += hueSpeed * dt
        if hue > 1 { hue -= 1 }

        let netAcceleration = gravity - (isPressing ? thrust : 0)
        bird.velocityY += netAcceleration * dt
        bird.velocityY = max(maxUpwardSpeed, min(maxDownwardSpeed, bird.velocityY))
        bird.y += bird.velocityY * dt

        trailAccumulator += dt
        while trailAccumulator >= trailInterval {
            trailAccumulator -= trailInterval
            trails.append(TrailParticle(x: bird.x, y: bird.y, size: bird.size * 0.5, hue: hue))
        }

        // Floor/ceiling
        if bird.y < 0 { bird.y = 0; bird.velocityY = 0 }
        if bird.y > max(0, size.height - bird.size) { bird.y = max(0, size.height - bird.size); isGameOver = true }

        // Pipes spawn/move
        timeSinceLastPipe += dt
        if timeSinceLastPipe >= pipeInterval {
            timeSinceLastPipe = 0
            let minY: CGFloat = 80
            let maxY: CGFloat = max(minY + gapHeight, size.height - 80)
            let centerY = CGFloat.random(in: minY...(maxY - gapHeight))
            let pipeX = size.width + 40
            pipes.append(Pipe(x: pipeX, gapY: centerY, gapHeight: gapHeight, passed: false))
        }

        for i in pipes.indices {
            pipes[i].x -= pipeSpeed * CGFloat(dt)
        }
        for i in trails.indices {
            trails[i].x -= pipeSpeed * CGFloat(dt)
        }
        trails.removeAll { $0.x < -$0.size }

        // Remove offscreen
        pipes.removeAll { $0.x < -80 }

        // Scoring and collisions
        for i in pipes.indices {
            if !pipes[i].passed && pipes[i].x + Pipe.width < bird.x {
                pipes[i].passed = true
                score += 1
            }
            if intersects(bird: bird, pipe: pipes[i]) {
                isGameOver = true
            }
        }
    }

    mutating func flap() {
        guard !isGameOver else { return }
        bird.velocityY = -800
    }
    mutating func release() {
        isPressing = false
        bird.velocityY = 0
    }

    private func intersects(bird: Bird, pipe: Pipe) -> Bool {
        let birdRect = CGRect(x: bird.x, y: bird.y, width: bird.size, height: bird.size)
        let topRect = CGRect(x: pipe.x, y: 0, width: Pipe.width, height: pipe.gapY)
        let bottomRect = CGRect(x: pipe.x, y: pipe.gapY + pipe.gapHeight, width: Pipe.width, height: size.height - (pipe.gapY + pipe.gapHeight))
        return birdRect.intersects(topRect) || birdRect.intersects(bottomRect)
    }
}

struct Bird {
    var x: CGFloat = 80
    var y: CGFloat = 200
    var size: CGFloat = 34
    var velocityY: CGFloat = 0
}

struct Pipe: Identifiable {
    static let width: CGFloat = 60
    let id = UUID()
    var x: CGFloat
    var gapY: CGFloat
    var gapHeight: CGFloat
    var passed: Bool
}

struct TrailParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var hue: Double
}

// MARK: - Views

struct GameView: View {
    @Binding var game: GameState

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                Color.clear
                // Pipes
                ForEach(game.pipes) { pipe in
                    PipeView(pipe: pipe, containerHeight: geo.size.height)
                        .offset(x: pipe.x)
                        .accessibilityHidden(true)
                }
                // Vapor trail
                ForEach(game.trails) { t in
                    Circle()
                        .fill(Color(hue: t.hue, saturation: 1, brightness: 1))
                        .frame(width: t.size, height: t.size)
                        .position(x: t.x + t.size/2, y: t.y + t.size/2)
                        .accessibilityHidden(true)
                }
                // Bird
                BirdView(avatar: game.avatar, colorOverride: Color(hue: game.hue, saturation: 1, brightness: 1))
                    .frame(width: game.bird.size, height: game.bird.size)
                    .position(x: game.bird.x + game.bird.size/2, y: game.bird.y + game.bird.size/2)
                    .accessibilityLabel("Bird avatar")
                    .accessibilityHint("Press and hold to fly up; release to fall.")
            }
            .onAppear { game.size = geo.size }
            .onChange(of: geo.size) { _, newSize in game.size = newSize }
        }
        .background(.thinMaterial)
    }
}

struct PipeView: View {
    let pipe: Pipe
    let containerHeight: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Top pipe
            RoundedRectangle(cornerRadius: 8)
                .fill(.green.gradient)
                .frame(width: Pipe.width, height: max(0, pipe.gapY))
            // Bottom pipe
            RoundedRectangle(cornerRadius: 8)
                .fill(.green.gradient)
                .frame(width: Pipe.width, height: max(0, containerHeight - (pipe.gapY + pipe.gapHeight)))
                .offset(y: pipe.gapY + pipe.gapHeight)
        }
    }
}

// Inclusive, respectful avatars
enum Avatar: CaseIterable, Identifiable {
    case rainbow, highContrast, pastel, transPride, nonbinaryPride
    var id: String { String(describing: self) }
}

struct AvatarPicker: View {
    @Binding var selected: Avatar

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Avatar.allCases) { avatar in
                BirdView(avatar: avatar)
                    .frame(width: 28, height: 28)
                    .padding(6)
                    .background(RoundedRectangle(cornerRadius: 8).fill(selected == avatar ? Color.white.opacity(0.25) : Color.clear))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(selected == avatar ? Color.white : Color.white.opacity(0.25), lineWidth: 1))
                    .onTapGesture { selected = avatar }
                    .accessibilityElement()
                    .accessibilityLabel(label(for: avatar))
                    .accessibilityAddTraits(selected == avatar ? .isSelected : [])
            }
        }
    }

    private func label(for avatar: Avatar) -> String {
        switch avatar {
        case .rainbow: return "Rainbow skin"
        case .highContrast: return "High contrast skin"
        case .pastel: return "Pastel skin"
        case .transPride: return "Trans pride skin"
        case .nonbinaryPride: return "Nonbinary pride skin"
        }
    }
}

struct BirdView: View {
    let avatar: Avatar
    var colorOverride: Color? = nil
    @State private var wiggle = false

    var body: some View {
        ZStack {
            Circle()
                .fill(fillStyle)
                .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))
            // Simple beak and eye for character
            Triangle()
                .fill(.orange)
                .frame(width: 10, height: 10)
                .offset(x: 10)
            Circle()
                .fill(.white)
                .frame(width: 8, height: 8)
                .offset(x: -4, y: -4)
            Circle()
                .fill(.black)
                .frame(width: 3, height: 3)
                .offset(x: -3, y: -4)
        }
        .overlay(alignment: .trailing) {
            Text("🍆")
                .font(.system(size: 16))
                .padding(2)
                .offset(y: wiggle ? -5 : 5)
                .accessibilityHidden(true)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                wiggle.toggle()
            }
        }
    }

    private var fillStyle: AnyShapeStyle {
        if let override = colorOverride {
            return AnyShapeStyle(override)
        } else {
            return AnyShapeStyle(gradient)
        }
    }

    private var gradient: LinearGradient {
        switch avatar {
        case .rainbow:
            return LinearGradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .highContrast:
            return LinearGradient(colors: [.black, .white], startPoint: .top, endPoint: .bottom)
        case .pastel:
            return LinearGradient(colors: [Color(red: 0.9, green: 0.8, blue: 1.0), Color(red: 0.8, green: 1.0, blue: 0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .transPride:
            return LinearGradient(colors: [Color(red: 0.91, green: 0.64, blue: 0.78), Color(red: 0.64, green: 0.86, blue: 0.98), .white, Color(red: 0.64, green: 0.86, blue: 0.98), Color(red: 0.91, green: 0.64, blue: 0.78)], startPoint: .top, endPoint: .bottom)
        case .nonbinaryPride:
            return LinearGradient(colors: [Color.yellow, Color.white, Color.purple, Color.black], startPoint: .top, endPoint: .bottom)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

struct PrideBanner: View {
    var body: some View {
        Text("Happy Pride! Fly proud 🏳️‍🌈")
            .font(.headline)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .accessibilityLabel("Happy Pride! Fly proud.")
    }
}

// MARK: - High Scores

struct HighScoreEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let time: TimeInterval
    let screens: Int

    init(id: UUID = UUID(), date: Date = Date(), time: TimeInterval, screens: Int) {
        self.id = id
        self.date = date
        self.time = time
        self.screens = screens
    }
}

final class HighScores: ObservableObject {
    @Published var entries: [HighScoreEntry] = []
    private let storageKey = "HighScores"

    init() {
        load()
    }

    func add(time: TimeInterval, screens: Int) {
        let entry = HighScoreEntry(time: time, screens: screens)
        entries.append(entry)
        entries.sort { $0.time > $1.time } // highest time first
        if entries.count > 5 { entries = Array(entries.prefix(5)) }
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Ignore save errors for now
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([HighScoreEntry].self, from: data)
            entries = decoded
        } catch {
            entries = []
        }
    }
}

struct HighScoresView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var highScores: HighScores

    var body: some View {
        NavigationStack {
            List {
                if highScores.entries.isEmpty {
                    Text("No scores yet. Play a round to set your first high score!")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(highScores.entries) { entry in
                        HStack {
                            Text(formatTime(entry.time))
                                .font(.headline)
                            Spacer()
                            Text("Screens: \(entry.screens)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Time \(formatTime(entry.time)), screens passed \(entry.screens)")
                    }
                }
            }
            .navigationTitle("High Scores")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func formatTime(_ t: TimeInterval) -> String {
        let minutes = Int(t) / 60
        let seconds = Int(t) % 60
        let hundredths = Int((t - floor(t)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var reducedMotion: Bool
    @Binding var difficulty: Int

    var body: some View {
        NavigationStack {
            Form {
                Section("Gameplay") {
                    Stepper("Difficulty: \(difficulty)", value: $difficulty, in: 1...5)
                }
                Section("Accessibility") {
                    Toggle("Reduced Motion", isOn: $reducedMotion)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Cycling Background

struct CyclingBackgroundView: View {
    @State private var hue: Double = 0
    let speed: Double

    var body: some View {
        Rectangle()
            .fill(Color(hue: hue, saturation: 0.6, brightness: 0.9))
            .task {
                // Smoothly cycle hue 0...1
                while true {
                    try? await Task.sleep(nanoseconds: 30_000_000) // ~33 fps
                    hue += speed / 60
                    if hue > 1 { hue -= 1 }
                }
            }
            .animation(.linear(duration: 0.2), value: hue)
    }
}

// MARK: - Chiptune Music

final class ChiptunePlayer: ObservableObject {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100
    private var menuBuffer: AVAudioPCMBuffer?
    private var gameBuffer: AVAudioPCMBuffer?

    init() {
        engine.attach(player)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)
    }

    func playMenu() {
        prepareSession()
        startEngine()
        if menuBuffer == nil { menuBuffer = makeMenuBuffer() }
        guard let buffer = menuBuffer else { return }
        schedule(buffer)
    }

    func playGame() {
        prepareSession()
        startEngine()
        if gameBuffer == nil { gameBuffer = makeGameBuffer() }
        guard let buffer = gameBuffer else { return }
        schedule(buffer)
    }

    func stop() {
        player.stop()
        engine.pause()
    }

    private func schedule(_ buffer: AVAudioPCMBuffer) {
        if player.isPlaying { player.stop() }
        player.scheduleBuffer(buffer, at: nil, options: [.loops], completionHandler: nil)
        player.play()
    }

    private func prepareSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { /* ignore */ }
    }

    private func startEngine() {
        if !engine.isRunning {
            do { try engine.start() } catch { /* ignore */ }
        }
    }

    private func makeMenuBuffer() -> AVAudioPCMBuffer? {
        // Calm, upbeat C major motif
        let melody: [(Double, Double)] = [
            (261.63, 0.5), (329.63, 0.5), (392.00, 0.5), (523.25, 0.5),
            (392.00, 0.5), (329.63, 0.5), (261.63, 0.5), (196.00, 0.5),
            (261.63, 0.5), (329.63, 0.5), (392.00, 1.0),
            (349.23, 0.5), (392.00, 0.5), (329.63, 1.0)
        ]
        return makeBuffer(melody: melody, bpm: 120)
    }

    private func makeGameBuffer() -> AVAudioPCMBuffer? {
        // More energetic variant
        let melody: [(Double, Double)] = [
            (523.25, 0.25), (493.88, 0.25), (440.00, 0.25), (392.00, 0.25),
            (440.00, 0.25), (493.88, 0.25), (523.25, 0.5),
            (659.25, 0.25), (587.33, 0.25), (523.25, 0.25), (493.88, 0.25),
            (523.25, 0.25), (587.33, 0.25), (659.25, 0.5)
        ]
        return makeBuffer(melody: melody, bpm: 160)
    }

    private func makeBuffer(melody: [(freq: Double, len: Double)], bpm: Double) -> AVAudioPCMBuffer? {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let beat = 60.0 / bpm
        let totalDuration = melody.reduce(0.0) { $0 + $1.len * beat }
        let totalFrames = AVAudioFrameCount(totalDuration * sampleRate)
        guard let pcm = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames) else { return nil }
        pcm.frameLength = totalFrames
        let ptr = pcm.floatChannelData![0]
        var writeIndex = 0
        for (freq, lengthBeats) in melody {
            let dur = lengthBeats * beat
            let frames = Int(dur * sampleRate)
            writeIndex = renderSquare(to: ptr, start: writeIndex, frames: frames, frequency: freq, amplitude: 0.22)
        }
        return pcm
    }

    @discardableResult
    private func renderSquare(to buffer: UnsafeMutablePointer<Float>, start: Int, frames: Int, frequency: Double, amplitude: Float) -> Int {
        let period = sampleRate / frequency
        let attackFrames = Int(0.004 * sampleRate)
        let releaseFrames = Int(0.010 * sampleRate)
        for i in 0..<frames {
            let idx = start + i
            let phase = fmod(Double(i), period) / period
            let sample: Float = phase < 0.5 ? amplitude : -amplitude
            var env: Float = 1.0
            if i < attackFrames {
                env = Float(i) / Float(max(1, attackFrames))
            } else if i > frames - releaseFrames {
                let rel = frames - i
                env = Float(rel) / Float(max(1, releaseFrames))
            }
            buffer[idx] = sample * env
        }
        return start + frames
    }
}

// MARK: - Main Menu View

struct MainMenuView: View {
    let startAction: () -> Void
    let highScoresAction: () -> Void
    let settingsAction: () -> Void

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                Text("Flappy Friends")
                    .font(.largeTitle.bold())
                VStack(spacing: 12) {
                    Button(action: startAction) {
                        Label("New Game", systemImage: "play.fill")
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button(action: highScoresAction) {
                        Label("High Scores", systemImage: "trophy.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(action: settingsAction) {
                        Label("Settings", systemImage: "gearshape.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

