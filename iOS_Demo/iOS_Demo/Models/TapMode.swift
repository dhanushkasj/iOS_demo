//
//  TapMode.swift
//  iOS_Demo
//
//  Created by Dhanushka Jayakody on 2026-06-06.
//

import SwiftUI

enum TapMode: Equatable {
    case bonus
    case penalty

    var color: Color {
        switch self {
        case .bonus:   return .green
        case .penalty: return .gray
        }
    }

    var label: String {
        switch self {
        case .bonus:   return "BONUS"
        case .penalty: return "PENALTY"
        }
    }

    var icon: String {
        switch self {
        case .bonus:   return "bolt.fill"
        case .penalty: return "exclamationmark.triangle.fill"
        }
    }
}
