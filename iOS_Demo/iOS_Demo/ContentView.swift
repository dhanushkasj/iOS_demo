//
//  ContentView.swift
//  iOS_Demo
//
//  Created by Dhanushka Jayakody on 2026-06-06.
//

import SwiftUI

enum TapMode: Equatable {
    case bonus
    case penalty

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

        let window = Int(Date().timeIntervalSince(startedAt) / windowLength)
        if window == currentWindow {
            multiplier += 1
        } else {
            multiplier = 1
            currentWindow = window
        }

        switch mode {
        case .bonus:
            tappedCount += multiplier * 2
        case .penalty:
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

                if let next = nextSwitchAt, now >= next {
                    mode = (mode == .bonus) ? .penalty : .bonus
                    nextSwitchAt = now.addingTimeInterval(Double.random(in: switchInterval))
                }

                if let next = nextMoveAt, now >= next {
                    buttonPosition = CGPoint(x: Double.random(in: 0...1),
                                             y: Double.random(in: 0...1))
                    nextMoveAt = now.addingTimeInterval(moveInterval)
                }

                let window = Int(now.timeIntervalSince(begin) / windowLength)
                if window != currentWindow {
                    multiplier = 1
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
    @AppStorage("highScore.tapFrenzy") private var highScore = 0
    @State private var isNewBest = false

    var body: some View {
        VStack(spacing: 0){
            VStack{
                Text("SCORE")
                    .font(.headline)

                Text("\(game.tappedCount)")
                    .font(.largeTitle.bold())

                Text("Best \(highScore)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer()

            GeometryReader { geo in
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
        .sensoryFeedback(trigger: game.showResults) { _, isShowing in
            isShowing ? .warning : nil
        }
        .onChange(of: game.showResults) { _, isShowing in
            guard isShowing else { return }
            isNewBest = game.tappedCount > highScore
            if isNewBest { highScore = game.tappedCount }
        }
        .fullScreenCover(isPresented: $game.showResults) {
            GameResultsView(score: game.tappedCount, best: highScore, isNewBest: isNewBest) {
                game.reset()
            }
        }
    }
}

#Preview {
    TapGameView()
}
