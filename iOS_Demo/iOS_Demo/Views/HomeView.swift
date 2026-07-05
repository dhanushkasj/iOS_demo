//
//  HomeView.swift
//  iOS_Demo

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Mini Games")
                        .font(.largeTitle.bold())
                    Text("Pick a game to play")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                NavigationLink {
                    TapGameView()
                } label: {
                    GameCard(
                        title: "Tap Frenzy",
                        subtitle: "Tap fast, chase the shrinking target",
                        systemImage: "hand.tap.fill",
                        color: .blue
                    )
                }

                NavigationLink {
                    LightItUpView()
                } label: {
                    GameCard(
                        title: "Light It Up",
                        subtitle: "Tap the glowing card before it fades",
                        systemImage: "square.grid.3x3.fill",
                        color: .orange
                    )
                }

                NavigationLink {
                    QuizRushView()
                } label: {
                    GameCard(
                        title: "Quiz Rush",
                        subtitle: "Answer live trivia, build your streak",
                        systemImage: "brain.head.profile",
                        color: .purple
                    )
                }

                Spacer()
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    HomeView()
}
