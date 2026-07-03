//
//  ReactionGameView.swift
//  iOS_Demo
//
//  Game 2: wait for the screen to turn green, then tap as fast as you can.
//

import SwiftUI

@Observable
final class ReactionGameModel {
    enum Phase {
        case idle      // blue   — waiting to start
        case waiting   // red    — armed, will turn green after a random delay
        case go        // green  — tap now, we're timing
        case tooSoon   // orange — tapped before green
        case result    // blue   — shows the reaction time
    }

    var phase: Phase = .idle
    var reactionMs = 0
    var bestMs: Int?

    private var goAt: Date?
    private var armTask: Task<Void, Never>?

    /// Single entry point for a tap anywhere on the play area.
    func handleTap() {
        switch phase {
        case .idle, .tooSoon, .result:
            arm()
        case .waiting:
            // Jumped the gun.
            armTask?.cancel()
            phase = .tooSoon
        case .go:
            if let goAt {
                let ms = Int(Date().timeIntervalSince(goAt) * 1000)
                reactionMs = ms
                if bestMs == nil || ms < bestMs! { bestMs = ms }
            }
            phase = .result
        }
    }

    private func arm() {
        phase = .waiting
        goAt = nil
        let delay = Double.random(in: 1.5...4.0)

        armTask?.cancel()
        armTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(delay))
            } catch {
                return // cancelled (tapped too soon, or left the screen)
            }
            guard !Task.isCancelled, phase == .waiting else { return }
            goAt = Date()
            phase = .go
        }
    }

    func stop() {
        armTask?.cancel()
        phase = .idle
    }

    // MARK: - Presentation

    var color: Color {
        switch phase {
        case .idle, .result: return .blue
        case .waiting:        return .red
        case .go:             return .green
        case .tooSoon:        return .orange
        }
    }

    var title: String {
        switch phase {
        case .idle:    return "Reaction Time"
        case .waiting: return "Wait for green…"
        case .go:      return "TAP!"
        case .tooSoon: return "Too soon!"
        case .result:  return "\(reactionMs) ms"
        }
    }

    var subtitle: String {
        switch phase {
        case .idle:    return "Tap anywhere to start"
        case .waiting: return "Don't tap until it turns green"
        case .go:      return "Tap now!"
        case .tooSoon: return "Tap to try again"
        case .result:  return "Tap to play again"
        }
    }
}

struct ReactionGameView: View {
    @State private var game = ReactionGameModel()

    var body: some View {
        ZStack {
            game.color
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text(game.title)
                    .font(.system(size: 48, weight: .bold))

                Text(game.subtitle)
                    .font(.title3)
                    .opacity(0.9)

                if let best = game.bestMs {
                    Text("Best: \(best) ms")
                        .font(.headline)
                        .padding(.top, 8)
                }
            }
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding()
        }
        .contentShape(Rectangle())
        .onTapGesture { game.handleTap() }
        .animation(.easeInOut(duration: 0.15), value: game.phase)
        .navigationTitle("Reaction")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { game.stop() }
    }
}

extension ReactionGameModel.Phase: Equatable {}

#Preview {
    NavigationStack {
        ReactionGameView()
    }
}
