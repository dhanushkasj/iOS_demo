//
//  TapGameView.swift
//  iOS_Demo
//
//  Created by Dhanushka Jayakody on 2026-06-06.
//

import SwiftUI

struct TapGameView: View {
    @State private var game = TapFrenzyViewModel()
    @AppStorage("highScore.tapFrenzy") private var highScore = 0
    @State private var isNewBest = false
    @State private var tapTick = 0
    @State private var bump = false
    @Environment(\.dismiss) private var dismiss

    private var accent: Color { game.isRunning ? game.mode.color : .blue }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 20) {
                header
                Spacer(minLength: 0)
                playArea
                Spacer(minLength: 0)
                footer
            }
            .padding()
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if !game.isRunning && !game.showResults {
                startOverlay
            }
        }
        .sensoryFeedback(.impact, trigger: tapTick)
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
            } onHome: {
                dismiss()
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [accent.opacity(0.18), Color(.systemBackground)],
            startPoint: .top,
            endPoint: .center
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.3), value: game.mode)
        .animation(.easeInOut(duration: 0.3), value: game.isRunning)
    }

    private var header: some View {
        HStack(alignment: .top) {
            stat("SCORE", "\(game.tappedCount)")

            Spacer()

            VStack(spacing: 6) {
                Label(game.isRunning ? game.mode.label : "READY",
                      systemImage: game.isRunning ? game.mode.icon : "hand.tap.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(accent, in: Capsule())
                    .animation(.easeInOut(duration: 0.2), value: game.mode)

                Text("Best \(highScore)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            stat("TIME", String(format: "%.1f", game.countDown))
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
                .contentTransition(.numericText())
        }
    }

    private var playArea: some View {
        GeometryReader { geo in
            let maxSize: CGFloat = 260
            let minSize: CGFloat = 64
            let size = minSize + (maxSize - minSize) * CGFloat(game.progress)

            tapButton
                .frame(width: size, height: size)
                .scaleEffect(bump ? 0.92 : 1)
                .position(
                    x: size / 2 + game.buttonPosition.x * (geo.size.width - size),
                    y: size / 2 + game.buttonPosition.y * (geo.size.height - size)
                )
                .animation(.easeInOut(duration: 0.25), value: game.mode)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: game.buttonPosition)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var tapButton: some View {
        Button {
            game.tap()
            tapTick += 1
            withAnimation(.easeIn(duration: 0.06)) { bump = true }
            withAnimation(.easeOut(duration: 0.18).delay(0.06)) { bump = false }
        } label: {
            ZStack {
                Circle()
                    .stroke(accent.opacity(0.18), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: game.progress)
                    .stroke(accent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [accent.opacity(0.95), accent],
                            center: .center,
                            startRadius: 4,
                            endRadius: 130
                        )
                    )
                    .padding(16)
                    .shadow(color: accent.opacity(0.6), radius: 22)

                content
            }
        }
        .buttonStyle(.plain)
    }

    private var content: some View {
        VStack(spacing: 2) {
            if game.isRunning {
                Text("×\(game.multiplier)")
                    .font(.system(size: 46, weight: .heavy, design: .rounded))
                    .contentTransition(.numericText())
                Text(game.mode.label)
                    .font(.caption2.bold())
                    .opacity(0.9)
            } else {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 34, weight: .bold))
                Text("TAP")
                    .font(.headline.bold())
            }
        }
        .foregroundStyle(.white)
        .minimumScaleFactor(0.4)
        .padding(8)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: game.multiplier)
    }

    private var footer: some View {
        Text(game.isRunning
             ? "Keep the rhythm to grow your combo"
             : "Green scores double · Grey costs you")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }

    private var startOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 50))
                .foregroundStyle(.blue)

            Text("Tap Frenzy")
                .font(.largeTitle.bold())

            Text("Tap as fast as you can for 10 seconds.\nKeep the rhythm for combos — but the target shrinks, moves, and changes colour.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                game.begin()
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

#Preview {
    NavigationStack {
        TapGameView()
    }
}
