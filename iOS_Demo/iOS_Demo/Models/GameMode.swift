//
//  GameMode.swift
//  iOS_Demo
//

import SwiftUI

enum GameMode: String, CaseIterable, Identifiable, Codable {
    case tapFrenzy
    case lightItUp
    case quizRush

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tapFrenzy: return "Tap Frenzy"
        case .lightItUp: return "Light It Up"
        case .quizRush:  return "Quiz Rush"
        }
    }

    var subtitle: String {
        switch self {
        case .tapFrenzy: return "Tap fast, chase the shrinking target"
        case .lightItUp: return "Tap the glowing card before it fades"
        case .quizRush:  return "Answer live trivia, build your streak"
        }
    }

    var systemImage: String {
        switch self {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "square.grid.3x3.fill"
        case .quizRush:  return "brain.head.profile"
        }
    }

    var color: Color {
        switch self {
        case .tapFrenzy: return .blue
        case .lightItUp: return .orange
        case .quizRush:  return .purple
        }
    }

    var highScoreKey: String { "highScore.\(rawValue)" }
}
