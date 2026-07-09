//
//  GameResultsView.swift
//  iOS_Demo
//
//  Shared results screen used by every game.
//

import SwiftUI

struct GameResultsView: View {
    var title: String = "Time's Up!"
    let mode: GameMode
    let score: Int
    let best: Int
    let isNewBest: Bool
    var shareMessage: String = ""
    let onPlayAgain: () -> Void
    let onHome: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var celebrate = false

    var body: some View {
        VStack(spacing: 22) {
            Spacer()

            gameBadge

            Text(title)
                .font(.largeTitle.bold())

            scoreCard

            bestLabel

            Spacer()

            actions
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
        .background(background)
        .overlay {
            if isNewBest && celebrate {
                ConfettiView()
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .onAppear {
            guard isNewBest else { return }
            withAnimation(.easeOut(duration: 0.3)) { celebrate = true }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [mode.color.opacity(0.18), Color(.systemBackground)],
            startPoint: .top,
            endPoint: .center
        )
        .ignoresSafeArea()
    }

    private var gameBadge: some View {
        Label(mode.title, systemImage: mode.systemImage)
            .font(.headline.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(mode.color, in: Capsule())
    }

    private var scoreCard: some View {
        VStack(spacing: 6) {
            Text("YOUR SCORE")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
            Text("\(score)")
                .font(.system(size: 84, weight: .heavy, design: .rounded))
                .foregroundStyle(mode.color)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(mode.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(mode.color.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 32)
    }

    @ViewBuilder
    private var bestLabel: some View {
        if isNewBest {
            Label("New Best!", systemImage: "trophy.fill")
                .font(.headline.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.yellow, in: Capsule())
                .symbolEffect(.bounce, value: isNewBest)
        } else {
            Text("Best: \(best)")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                dismiss()
                onPlayAgain()
            } label: {
                Text("Try Again")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(mode.color, in: RoundedRectangle(cornerRadius: 16))
            }

            if !shareMessage.isEmpty {
                ShareLink(item: shareMessage) {
                    Label("Share Score", systemImage: "square.and.arrow.up")
                        .font(.title2.bold())
                        .foregroundStyle(mode.color)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(mode.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
                }
            }

            Button {
                dismiss()
                onHome()
            } label: {
                Text("Home")
                    .font(.title2.bold())
                    .foregroundStyle(mode.color)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(mode.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

#Preview("Results") {
    GameResultsView(mode: .tapFrenzy, score: 42, best: 40, isNewBest: true,
                    shareMessage: "I just scored 42 on Tap Frenzy — beat that") {} onHome: {}
}
