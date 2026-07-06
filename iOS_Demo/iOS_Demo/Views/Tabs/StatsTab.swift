//
//  StatsTab.swift
//  iOS_Demo
//

import Charts
import SwiftUI

struct StatsTab: View {
    @Environment(SessionStore.self) private var store

    var body: some View {
        let stats = StatsViewModel(sessions: store.sessions)

        NavigationStack {
            Group {
                if stats.hasData {
                    ScrollView {
                        VStack(spacing: 20) {
                            totals(stats)
                            chart(stats)
                            bests(stats)
                            recent(stats)
                        }
                        .padding()
                    }
                } else {
                    ContentUnavailableView(
                        "No games yet",
                        systemImage: "chart.bar",
                        description: Text("Play a round and your scores will show up here.")
                    )
                }
            }
            .navigationTitle("Stats")
        }
    }

    private func totals(_ stats: StatsViewModel) -> some View {
        HStack(spacing: 12) {
            summaryCard(title: "Games Played", value: "\(stats.totalGames)")
            summaryCard(title: "Total Score", value: "\(stats.totalScore)")
        }
    }

    private func summaryCard(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 40, weight: .bold))
                .monospacedDigit()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    private func chart(_ stats: StatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score History")
                .font(.headline)

            Chart(Array(stats.chronological.enumerated()), id: \.element.id) { index, session in
                BarMark(
                    x: .value("Round", index + 1),
                    y: .value("Score", session.score)
                )
                .foregroundStyle(by: .value("Game", session.mode.title))
            }
            .chartForegroundStyleScale(colorScale)
            .chartXAxis(.hidden)
            .frame(height: 220)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    private var colorScale: KeyValuePairs<String, Color> {
        [
            GameMode.tapFrenzy.title: GameMode.tapFrenzy.color,
            GameMode.lightItUp.title: GameMode.lightItUp.color,
            GameMode.quizRush.title: GameMode.quizRush.color
        ]
    }

    private func bests(_ stats: StatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personal Bests")
                .font(.headline)

            ForEach(GameMode.allCases) { mode in
                HStack(spacing: 14) {
                    Image(systemName: mode.systemImage)
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(mode.color, in: RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(mode.title)
                            .font(.headline)
                        Text("\(stats.gamesPlayed(mode)) played")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(stats.best(for: mode))")
                        .font(.title2.bold())
                        .monospacedDigit()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    private func recent(_ stats: StatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Games")
                .font(.headline)

            ForEach(stats.recent) { session in
                HStack(spacing: 14) {
                    Image(systemName: session.mode.systemImage)
                        .foregroundStyle(session.mode.color)
                        .frame(width: 28)

                    Text(session.mode.title)
                        .font(.subheadline.bold())

                    Spacer()

                    Text(session.timestamp, format: .relative(presentation: .numeric))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(session.score)")
                        .font(.headline)
                        .monospacedDigit()
                        .frame(minWidth: 40, alignment: .trailing)
                }

                if session.id != stats.recent.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    let store = SessionStore(context: PersistenceController(inMemory: true).viewContext)
    store.record(mode: .tapFrenzy, score: 42, coordinate: nil)
    store.record(mode: .quizRush, score: 80, coordinate: nil)
    store.record(mode: .lightItUp, score: 30, coordinate: nil)
    store.record(mode: .tapFrenzy, score: 55, coordinate: nil)
    return StatsTab().environment(store)
}
