//
//  LightItUpViewModel.swift
//  iOS_Demo
//

import SwiftUI

@Observable
final class LightItUpViewModel {
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
        self.cards = LightItUpViewModel.makeCards(Level.l1.cardCount)
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
        cards = LightItUpViewModel.makeCards(level.cardCount)

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
                        cards = LightItUpViewModel.makeCards(newLevel.cardCount)
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
        cards = LightItUpViewModel.makeCards(level.cardCount)
    }

    func stop() {
        gameTask?.cancel()
    }

    private static func makeCards(_ count: Int) -> [Card] {
        (0..<count).map { Card(id: $0) }
    }
}
