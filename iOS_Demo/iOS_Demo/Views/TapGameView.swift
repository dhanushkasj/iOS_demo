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
    @Environment(\.dismiss) private var dismiss

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
                        tapTick += 1
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
}

#Preview {
    TapGameView()
}
