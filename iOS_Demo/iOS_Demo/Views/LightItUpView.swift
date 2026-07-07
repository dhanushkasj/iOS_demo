//
//  LightItUpView.swift
//  iOS_Demo
//

import SwiftUI

struct LightItUpView: View {
    @State private var game = LightItUpViewModel()
    @AppStorage("highScore.lightItUp") private var highScore = 0
    @State private var isNewBest = false
    @State private var tapTick = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var sessions
    @Environment(LocationService.self) private var location
    @Environment(AudioService.self) private var audio
    @AppStorage("settings.musicEnabled") private var musicEnabled = true
    @AppStorage("settings.hapticsEnabled") private var hapticsEnabled = true

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
        .onAppear { if musicEnabled { audio.play() } }
        .onDisappear {
            game.stop()
            audio.stop()
        }
        .sensoryFeedback(trigger: tapTick) { _, _ in
            hapticsEnabled ? .impact : nil
        }
        .sensoryFeedback(trigger: game.showResults) { _, isShowing in
            hapticsEnabled && isShowing ? .warning : nil
        }
        .onChange(of: game.showResults) { _, isShowing in
            guard isShowing else { return }
            isNewBest = game.score > highScore
            if isNewBest { highScore = game.score }
            sessions.record(mode: .lightItUp, score: game.score, coordinate: location.lastCoordinate)
        }
        .fullScreenCover(isPresented: $game.showResults) {
            GameResultsView(mode: .lightItUp, score: game.score, best: highScore, isNewBest: isNewBest,
                            shareMessage: "I just scored \(game.score) on Light It Up — beat that") {
                game.reset()
            } onHome: {
                game.stop()
                dismiss()
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

#Preview {
    NavigationStack {
        LightItUpView()
    }
    .environment(SessionStore(context: PersistenceController(inMemory: true).viewContext))
    .environment(LocationService())
    .environment(AudioService())
}
