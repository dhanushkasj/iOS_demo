//
//  StatsViewModel.swift
//  iOS_Demo
//

import Foundation

struct StatsViewModel {
    let sessions: [GameSession]

    var hasData: Bool { !sessions.isEmpty }

    var totalGames: Int { sessions.count }

    var totalScore: Int { sessions.reduce(0) { $0 + $1.score } }

    func best(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map(\.score).max() ?? 0
    }

    func gamesPlayed(_ mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.count
    }

    var recent: [GameSession] {
        Array(sessions.prefix(10))
    }

    var chronological: [GameSession] {
        sessions.reversed()
    }
}
