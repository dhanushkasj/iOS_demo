//
//  LightItUpView.swift
//  iOS_Demo

import SwiftUI

struct Card: Identifiable {
    let id: Int
    var isLit = false
}

enum Level: Int, CaseIterable {
    case l1, l2, l3, l4

    static func forProgress(_ progress: Double) -> Level {
        switch progress {
        case ..<0.25: return .l1
        case ..<0.50: return .l2
        case ..<0.75: return .l3
        default:      return .l4
        }
    }

    var cardCount: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 6
        case .l4: return 9
        }
    }

    var columns: Int {
        switch self {
        case .l1: return 3
        case .l2: return 2
        case .l3: return 3
        case .l4: return 3
        }
    }

    var litWindow: Double {
        switch self {
        case .l1: return 1.5
        case .l2: return 1.2
        case .l3: return 1.0
        case .l4: return 0.8
        }
    }

    var litCount: Int { self == .l4 ? 2 : 1 }

    var color: Color {
        switch self {
        case .l1: return .green
        case .l2: return .blue
        case .l3: return .yellow
        case .l4: return .red
        }
    }

    var label: String { "L\(rawValue + 1)" }
}

@Observable
final class LightItUpModel {
    private(set) var cards: [Card] = []
    private(set) var score = 0
    private(set) var countDown: Double
    private(set) var level: Level = .l1
    var isRunning = false
    var showResults = false

    private(set) var levelUpFlash = 0

    let roundLength: Double

    private var endDate: Date?
    private var nextTickAt: Date?
    private var gameTask: Task<Void, Never>?

    init(roundLength: Double = 60) {
        self.roundLength = roundLength
        self.countDown = roundLength
        self.cards = LightItUpModel.makeCards(Level.l1.cardCount)
    }

    var progress: Double {
        max(0, min(1, 1 - countDown / roundLength))
    }

    func start() {
        isRunning = true
        showResults = false
        score = 0
        level = .l1
        countDown = roundLength
        cards = LightItUpModel.makeCards(level.cardCount)

        let begin = Date()
        endDate = begin.addingTimeInterval(roundLength)
        nextTickAt = begin

        gameTask?.cancel()
        gameTask = Task { @MainActor in
            while !Task.isCancelled {
                let now = Date()
                guard let endDate else { break }
                let remaining = endDate.timeIntervalSince(now)
                if remaining <= 0 { break }
                countDown = remaining

                let newLevel = Level.forProgress(progress)
                if newLevel != level {
                    level = newLevel
                    levelUpFlash += 1
                    if cards.count != newLevel.cardCount {
                        cards = LightItUpModel.makeCards(newLevel.cardCount)
                    }
                    nextTickAt = now
                }

                if let next = nextTickAt, now >= next {
                    tick()
                    nextTickAt = now.addingTimeInterval(level.litWindow)
                }

                do {
                    try await Task.sleep(for: .milliseconds(16))
                } catch {
                    return
                }
            }

            guard !Task.isCancelled else { return }
            countDown = 0
            isRunning = false
            for i in cards.indices { cards[i].isLit = false }
            showResults = true
        }
    }

    private func tick() {
        let missed = cards.filter(\.isLit).count
        if missed > 0 {
            score = max(0, score - missed)     // a missed card is penalised
        }
        for i in cards.indices { cards[i].isLit = false }

        for i in cards.indices.shuffled().prefix(level.litCount) {
            cards[i].isLit = true
        }
    }

    func tap(_ card: Card) {
        guard isRunning else { return }
        guard let idx = cards.firstIndex(where: { $0.id == card.id }) else { return }

        if cards[idx].isLit {
            cards[idx].isLit = false
            score += 1
        } else {
            score = max(0, score - 1)
        }
    }

    func reset() {
        gameTask?.cancel()
        isRunning = false
        showResults = false
        score = 0
        level = .l1
        countDown = roundLength
        endDate = nil
        nextTickAt = nil
        cards = LightItUpModel.makeCards(level.cardCount)
    }

    func stop() {
        gameTask?.cancel()
    }

    private static func makeCards(_ count: Int) -> [Card] {
        (0..<count).map { Card(id: $0) }
    }
}

struct LightItUpView: View {
    @State private var game = LightItUpModel()
    @AppStorage("highScore.lightItUp") private var highScore = 0
    @State private var isNewBest = false
    @State private var tapTick = 0

    var body: some View {
        VStack(spacing: 24) {
            header
            grid
            Spacer(minLength: 0)
        }
        .padding()
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if !game.isRunning && !game.showResults {
                startOverlay
            }
        }
        .overlay {
            LevelUpFlash(trigger: game.levelUpFlash,
                         color: game.level.color,
                         label: game.level.label)
        }
        .onDisappear { game.stop() }
        .sensoryFeedback(.impact, trigger: tapTick)
        .sensoryFeedback(trigger: game.showResults) { _, isShowing in
            isShowing ? .warning : nil
        }
        .onChange(of: game.showResults) { _, isShowing in
            guard isShowing else { return }
            isNewBest = game.score > highScore
            if isNewBest { highScore = game.score }
        }
        .fullScreenCover(isPresented: $game.showResults) {
            GameResultsView(score: game.score, best: highScore, isNewBest: isNewBest) {
                game.reset()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            stat("SCORE", "\(game.score)")

            Spacer()

            VStack(spacing: 4) {
                Text(game.level.label)
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(game.level.color, in: Capsule())
                Text("Best \(highScore)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            stat("TIME", String(format: "%.0f", game.countDown))
        }
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title.bold())
                .monospacedDigit()
        }
    }

    private var grid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12),
                            count: game.level.columns)
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(game.cards) { card in
                CardTile(card: card, color: game.level.color) {
                    game.tap(card)
                    tapTick += 1
                }
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.7),
                   value: game.cards.map(\.isLit))
        .animation(.easeInOut(duration: 0.2), value: game.cards.count)
    }

    private var startOverlay: some View {
        VStack(spacing: 16) {
            Text("Light It Up")
                .font(.largeTitle.bold())
            Text("Tap the glowing card before it goes dark.\nThe grid grows and speeds up.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                game.start()
            } label: {
                Text("Start")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 14)
                    .background(.blue, in: Capsule())
            }
        }
        .padding(32)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        .padding()
    }
}

private struct CardTile: View {
    let card: Card
    let color: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: 16)
                .fill(card.isLit ? color : Color(.secondarySystemBackground))
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(card.isLit ? 0.9 : 0.15), lineWidth: 2)
                )
                .shadow(color: card.isLit ? color.opacity(0.8) : .clear,
                        radius: card.isLit ? 16 : 0)
                .scaleEffect(card.isLit ? 1.06 : 1)
        }
        .buttonStyle(.plain)
    }
}

private struct LevelUpFlash: View {
    let trigger: Int
    let color: Color
    let label: String

    @State private var opacity: Double = 0

    var body: some View {
        Text("\(label)!")
            .font(.system(size: 72, weight: .heavy))
            .foregroundStyle(color)
            .shadow(color: color.opacity(0.7), radius: 20)
            .opacity(opacity)
            .allowsHitTesting(false)
            .onChange(of: trigger) { _, _ in
                opacity = 1
                withAnimation(.easeOut(duration: 0.7)) { opacity = 0 }
            }
    }
}

struct GameResultsView: View {
    var title: String = "Time's Up!"
    let score: Int
    let best: Int
    let isNewBest: Bool
    let onPlayAgain: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(title)
                .font(.largeTitle.bold())

            VStack(spacing: 8) {
                Text("YOUR SCORE")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("\(score)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(.blue)
            }

            if isNewBest {
                Label("New best!", systemImage: "trophy.fill")
                    .font(.title3.bold())
                    .foregroundStyle(.yellow)
            } else {
                Text("Best: \(best)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                dismiss()
                onPlayAgain()
            } label: {
                Text("Play Again")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    NavigationStack {
        LightItUpView()
    }
}

#Preview("Results") {
    GameResultsView(score: 42, best: 40, isNewBest: true) {}
}
