//
//  LightItUpBoard.swift
//  iOS_Demo
//

import SwiftUI

struct Card: Identifiable {
    let id: Int
    var isLit = false
}

enum Level: Int, CaseIterable {
    case l1, l2, l3, l4

    static func forProgress(_ progress: Double) -> Level {
        switch progress {
        case ..<0.25: return .l1
        case ..<0.50: return .l2
        case ..<0.75: return .l3
        default:      return .l4
        }
    }

    var cardCount: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 6
        case .l4: return 9
        }
    }

    var columns: Int {
        switch self {
        case .l1: return 3
        case .l2: return 2
        case .l3: return 3
        case .l4: return 3
        }
    }

    var litWindow: Double {
        switch self {
        case .l1: return 1.5
        case .l2: return 1.2
        case .l3: return 1.0
        case .l4: return 0.8
        }
    }

    var litCount: Int { self == .l4 ? 2 : 1 }

    var color: Color {
        switch self {
        case .l1: return .green
        case .l2: return .blue
        case .l3: return .yellow
        case .l4: return .red
        }
    }

    var label: String { "L\(rawValue + 1)" }
}
