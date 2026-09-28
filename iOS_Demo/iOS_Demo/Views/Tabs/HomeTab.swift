//
//  HomeTab.swift
//  iOS_Demo
//

import SwiftUI

struct HomeTab: View {
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

                ForEach(GameMode.allCases) { mode in
                    NavigationLink {
                        destination(for: mode)
                    } label: {
                        GameCard(
                            title: mode.title,
                            subtitle: mode.subtitle,
                            systemImage: mode.systemImage,
                            color: mode.color
                        )
                    }
                }

                Spacer()
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .appBackground()
        }
    }

    @ViewBuilder
    private func destination(for mode: GameMode) -> some View {
        switch mode {
        case .tapFrenzy: TapGameView()
        case .lightItUp: LightItUpView()
        case .quizRush:  QuizRushView()
        }
    }
}

#Preview {
    HomeTab()
        .environment(SessionStore(context: PersistenceController(inMemory: true).viewContext))
        .environment(LocationService())
        .environment(AudioService())
}
