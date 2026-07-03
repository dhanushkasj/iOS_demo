//
//  ContentView.swift
//  iOS_Demo
//
//  Created by Dhanushka Jayakody on 2026-06-06.
//

import SwiftUI

enum TapMode: Equatable {
    case bonus    // green  → taps score double
    case penalty  // grey   → taps subtract points

    var color: Color {
        switch self {
        case .bonus:   return .green
        case .penalty: return .gray
        }
    }
}

@Observable
final class GameModel {
    var countDown: Double = 10
    var tappedCount = 0
    var isRunning = false
    var showResults = false
    var multiplier = 1
    var mode: TapMode = .bonus
    
    var buttonPosition = CGPoint(x: 0.5, y: 0.5)

    // Fraction of time remaining: 1 at the start, 0 when the clock runs out.
    var progress: Double { max(0, min(1, countDown / duration)) }

    private let duration: Double = 10
    private let windowLength: Double = 0.5
    private let switchInterval: ClosedRange<Double> = 1.5...3.0
    private let moveInterval: Double = 2
    private var startedAt: Date?
    private var currentWindow = -1
    private var nextSwitchAt: Date?
    private var nextMoveAt: Date?
    private var timerTask: Task<Void, Never>?

    func tap() {
        if !isRunning {
            start()
        }
        guard let startedAt else { return }

        // Which fixed 0.5s window (from game start) does this tap fall in?
        let window = Int(Date().timeIntervalSince(startedAt) / windowLength)
        if window == currentWindow {
            // Another tap in the same window → combo grows.
            multiplier += 1
        } else {
            // First tap of a new window → reset to ×1.
            multiplier = 1
            currentWindow = window
        }

        switch mode {
        case .bonus:
            // Green → reward: double the combo value.
            tappedCount += multiplier * 2
        case .penalty:
            // Grey → punish tapping: lose the combo value (never below 0).
            tappedCount = max(0, tappedCount - multiplier)
        }
    }

    private func start() {
        isRunning = true
        countDown = duration
        multiplier = 1
        currentWindow = -1
        mode = .bonus
        buttonPosition = CGPoint(x: 0.5, y: 0.5)

        let begin = Date()
        startedAt = begin
        nextSwitchAt = begin.addingTimeInterval(Double.random(in: switchInterval))
        nextMoveAt = begin.addingTimeInterval(moveInterval)
        let endDate = begin.addingTimeInterval(duration)

        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while !Task.isCancelled {
                let now = Date()
                let remaining = endDate.timeIntervalSinceNow
                if remaining <= 0 { break }
                countDown = remaining

                // Flip the button colour every few seconds (bonus ⇄ penalty).
                if let next = nextSwitchAt, now >= next {
                    mode = (mode == .bonus) ? .penalty : .bonus
                    nextSwitchAt = now.addingTimeInterval(Double.random(in: switchInterval))
                }

                // Jump the button to a random spot every 2 seconds.
                if let next = nextMoveAt, now >= next {
                    buttonPosition = CGPoint(x: Double.random(in: 0...1),
                                             y: Double.random(in: 0...1))
                    nextMoveAt = now.addingTimeInterval(moveInterval)
                }

                // Each new 0.5s window resets the multiplier, even while tapping.
                let window = Int(now.timeIntervalSince(begin) / windowLength)
                if window != currentWindow {
                    multiplier = 1
                }

                // ~60fps UI refresh; the wall clock above is authoritative.
                do {
                    try await Task.sleep(for: .milliseconds(16))
                } catch {
                    return // cancelled
                }
            }

            guard !Task.isCancelled else { return }
            countDown = 0
            isRunning = false
            showResults = true
        }
    }

    func reset() {
        timerTask?.cancel()
        tappedCount = 0
        countDown = duration
        isRunning = false
        multiplier = 1
        currentWindow = -1
        startedAt = nil
        nextSwitchAt = nil
        nextMoveAt = nil
        mode = .bonus
        buttonPosition = CGPoint(x: 0.5, y: 0.5)
    }
}

struct TapGameView: View {
    @State private var game = GameModel()

    var body: some View {
        VStack(spacing: 0){
            VStack{
                Text("SCORE")
                    .font(.headline)

                Text("\(game.tappedCount)")
                    .font(.largeTitle.bold())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer()

            GeometryReader { geo in
                // Big at start-up, shrinking to tiny as the timer runs out.
                let maxSize: CGFloat = 240
                let minSize: CGFloat = 50
                let size = minSize + (maxSize - minSize) * CGFloat(game.progress)

                ZStack{
                    Circle()
                        .stroke(game.isRunning ? game.mode.color : .blue, lineWidth: 8)

                    Button{
                        game.tap()
                    } label: {
                        Circle()
                            .fill(game.isRunning ? game.mode.color : .blue)
                            .padding(10)
                    }

                    Text(game.isRunning ? "×\(game.multiplier)" : "Tap To Start")
                        .foregroundStyle(.white)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.4)
                        .padding(8)
                }
                .frame(width: size, height: size)
                // Map the normalised position to a centre that keeps the
                // whole button inside the play area.
                .position(
                    x: size / 2 + game.buttonPosition.x * (geo.size.width - size),
                    y: size / 2 + game.buttonPosition.y * (geo.size.height - size)
                )
                .animation(.easeInOut(duration: 0.2), value: game.mode)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: game.buttonPosition)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer()

            VStack{
                Text("TIME REMAINING")
                    .font(.headline)
                Text(String(format: "%.2f", game.countDown))
                    .font(.largeTitle)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        // Buzz when the timer runs out (only on the transition to "results").
        .sensoryFeedback(trigger: game.showResults) { _, isShowing in
            isShowing ? .warning : nil
        }
        .fullScreenCover(isPresented: $game.showResults) {
            ResultsView(score: game.tappedCount) {
                game.reset()
            }
        }
    }
}

struct ResultsView: View {
    let score: Int
    let onPlayAgain: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Time's Up!")
                .font(.largeTitle.bold())

            VStack(spacing: 8) {
                Text("YOUR SCORE")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("\(score)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(.blue)
            }

            Text("You tapped \(score) \(score == 1 ? "time" : "times")!")
                .foregroundStyle(.secondary)

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
    TapGameView()
}

#Preview("Results") {
    ResultsView(score: 42) {}
}
