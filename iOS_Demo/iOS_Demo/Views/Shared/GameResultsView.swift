//
//  GameResultsView.swift
//  iOS_Demo
//
//  Shared results screen used by every game.
//

import SwiftUI

struct GameResultsView: View {
    var title: String = "Time's Up!"
    let score: Int
    let best: Int
    let isNewBest: Bool
    let onPlayAgain: () -> Void
    let onHome: () -> Void

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
                        .background(.blue, in: RoundedRectangle(cornerRadius: 16))
                }

                Button {
                    dismiss()
                    onHome()
                } label: {
                    Text("Home")
                        .font(.title2.bold())
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}

#Preview("Results") {
    GameResultsView(score: 42, best: 40, isNewBest: true) {} onHome: {}
}
